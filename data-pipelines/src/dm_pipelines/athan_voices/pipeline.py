"""`BuildVoice`: one downloadable Athan voice (§9.5, §15 D111).

pinned source (sha256) ─▶ originals/<soundId>.<ext>  the audio stream copied out unchanged
                       ─▶ <soundId>.m4a              leading trim + one fixed gain, AAC-LC
  checks: the .m4a decodes with no error, its integrated loudness is within 0.5 LU of the target,
  its true peak is below -1 dBTP and its sha256 is the pinned `expectSha256`
  ─▶ <soundId>.voice.json  bytes, sha256, duration and loudness for the app's voice catalog

The .m4a is what the CDN serves under `<channel>/athan/voices/<soundId>/<version>/`; the original
stays with the build so the processing can be checked against it.
"""

import json
import re
from dataclasses import asdict, dataclass
from pathlib import Path

from dm_pipelines.athan_voices.config import VoicePin, load_athan_voices_config
from dm_pipelines.commands import CapturingRunner, CommandError
from dm_pipelines.hashing import sha256_file

CONFIG = "data-pipelines/config/athan_voices.v1.toml"
_FFMPEG = ("ffmpeg", "-v", "error")
_FFPROBE = ("ffprobe", "-v", "error")
_METER = ("ffmpeg", "-hide_banner", "-nostats")
_MAX_LOUDNESS_ERROR_LU = 0.5
_MAX_PEAK_DBFS = -1.0
_INTEGRATED = re.compile(r"^\s*I:\s+(-?\d+(?:\.\d+)?) LUFS", re.MULTILINE)
_PEAK = re.compile(r"^\s*Peak:\s+(-?\d+(?:\.\d+)?|-inf) dBFS", re.MULTILINE)


class VoiceBuildError(Exception):
    """The source or the output is not what the pin file says."""


@dataclass(frozen=True)
class VoiceBuild:
    """What the app's voice catalog records of one built voice."""

    sound_id: str
    file: str
    bytes: int
    sha256: str
    duration_ms: int
    integrated_lufs: float
    peak_dbfs: float


def parse_duration_ms(ffprobe_output: str) -> int:
    """Return the duration ffprobe printed (`-show_entries format=duration -of csv=p=0`), in ms."""
    try:
        return round(float(ffprobe_output.strip().splitlines()[0]) * 1000)
    except (IndexError, ValueError) as error:
        message = f"no duration in ffprobe output: {ffprobe_output[:80]!r}"
        raise VoiceBuildError(message) from error


def parse_loudness(ebur128_output: str) -> tuple[float, float]:
    """Return the integrated loudness (LUFS) and true peak (dBTP) of ffmpeg's ebur128 summary."""
    integrated = _INTEGRATED.findall(ebur128_output)
    peak = _PEAK.findall(ebur128_output)
    if not integrated or not peak:
        message = "no ebur128 summary in ffmpeg output"
        raise VoiceBuildError(message)
    return float(integrated[-1]), float(peak[-1])


def encode_args(pin: VoicePin, original: Path, out: Path) -> list[str]:
    """Return the ffmpeg command that makes the app's file from the original: trim, gain, AAC-LC."""
    processing = pin.processing
    return [
        "ffmpeg",
        "-v",
        "error",
        "-y",
        "-ss",
        f"{processing.trim_start_seconds}",
        "-i",
        str(original),
        "-map",
        "0:a:0",
        "-af",
        f"volume={processing.gain_db}dB",
        "-c:a",
        "aac",
        "-profile:a",
        "aac_low",
        "-b:a",
        f"{processing.bitrate_kbps}k",
        "-ar",
        f"{processing.sample_rate}",
        "-ac",
        "2",
        "-map_metadata",
        "-1",
        "-fflags",
        "+bitexact",
        "-flags:a",
        "+bitexact",
        "-movflags",
        "+faststart",
        str(out),
    ]


@dataclass(frozen=True)
class BuildVoice:
    """Builds one pinned voice with ffmpeg and ffprobe through `runner`."""

    runner: CapturingRunner
    repo: Path

    def run(self, sound_id: str, source: Path, out: Path) -> VoiceBuild:
        """Build voice `sound_id` from the downloaded `source` into the directory `out`."""
        pin = load_athan_voices_config(self.repo / CONFIG).pin(sound_id)
        if (actual := sha256_file(source)) != pin.source.sha256:
            message = f"{source.name}: sha256 {actual}, pinned {pin.source.sha256}"
            raise VoiceBuildError(message)
        originals = out / "originals"
        originals.mkdir(parents=True, exist_ok=True)
        original = originals / f"{sound_id}.{pin.source.original_extension}"
        self._run(
            [
                *_FFMPEG,
                "-y",
                "-i",
                str(source),
                "-vn",
                "-map",
                "0:a:0",
                "-c:a",
                "copy",
                str(original),
            ],
            out,
        )
        target = out / f"{sound_id}.m4a"
        self._run(encode_args(pin, original, target), out)
        # A clean decode prints nothing at `-v error`.
        if decode := self.runner.capture(
            [*_FFMPEG, "-i", str(target), "-f", "null", "-"], out
        ).strip():
            message = f"{target.name} does not decode cleanly: {decode[:200]}"
            raise VoiceBuildError(message)
        duration_ms = parse_duration_ms(
            self.runner.capture(
                [*_FFPROBE, "-show_entries", "format=duration", "-of", "csv=p=0", str(target)],
                out,
            )
        )
        lufs, peak = parse_loudness(
            self.runner.capture(
                [*_METER, "-i", str(target), "-af", "ebur128=peak=true", "-f", "null", "-"],
                out,
            )
        )
        if abs(lufs - pin.processing.target_lufs) > _MAX_LOUDNESS_ERROR_LU:
            message = f"{target.name}: {lufs} LUFS, target {pin.processing.target_lufs}"
            raise VoiceBuildError(message)
        if peak > _MAX_PEAK_DBFS:
            message = f"{target.name}: peak {peak} dBFS above {_MAX_PEAK_DBFS}"
            raise VoiceBuildError(message)
        digest = sha256_file(target)
        if digest != pin.expect_sha256:
            message = (
                f"{target.name}: sha256 {digest}, pinned {pin.expect_sha256} "
                f"(pinned ffmpeg {pin.ffmpeg}); listen, then re-pin"
            )
            raise VoiceBuildError(message)
        build = VoiceBuild(
            sound_id=sound_id,
            file=f"{sound_id}.m4a",
            bytes=target.stat().st_size,
            sha256=digest,
            duration_ms=duration_ms,
            integrated_lufs=lufs,
            peak_dbfs=peak,
        )
        (out / f"{sound_id}.voice.json").write_text(
            json.dumps(asdict(build), indent=2) + "\n", encoding="utf-8"
        )
        return build

    def _run(self, args: list[str], cwd: Path) -> None:
        try:
            self.runner.capture(args, cwd)
        except CommandError as error:
            raise VoiceBuildError(str(error)) from error
