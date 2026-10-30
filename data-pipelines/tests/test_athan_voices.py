"""The Athan voices pipeline: pins, ffmpeg arguments and output parsing (§15 D111).

The full build runs only when `DM_ATHAN_VOICE_SOURCES` names a directory holding the pinned
recordings as `<soundId>.<ext of the url>`; it needs ffmpeg and ffprobe on PATH.
"""

import os
from pathlib import Path

import pytest

from dm_pipelines.athan_voices.config import load_athan_voices_config
from dm_pipelines.athan_voices.pipeline import (
    CONFIG,
    BuildVoice,
    VoiceBuildError,
    encode_args,
    parse_duration_ms,
    parse_loudness,
)
from dm_pipelines.commands import CapturingSubprocessRunner

REPO = Path(__file__).resolve().parents[2]
_SUMMARY = """
[Parsed_ebur128_0 @ 0x1] Summary:

  Integrated loudness:
    I:         -16.0 LUFS
    Threshold: -26.4 LUFS

  True peak:
    Peak:       -4.7 dBFS
"""


def test_every_pinned_voice_is_licensed_for_redistribution_and_reviewed_or_pending() -> None:
    config = load_athan_voices_config(REPO / CONFIG)
    assert config.voice
    for voice in config.voice:
        assert voice.source.licence in {"CC0-1.0", "CC-BY-3.0", "CC-BY-4.0", "CC-BY-SA-4.0"}
        assert voice.review in {"pending", "passed"}


def test_the_encoder_trims_only_the_start_and_applies_one_fixed_gain() -> None:
    pin = load_athan_voices_config(REPO / CONFIG).pin("malmo_fajr_2012")
    args = encode_args(pin, Path("in.opus"), Path("out.m4a"))
    assert args[args.index("-ss") + 1] == "4.5"
    assert args[args.index("-af") + 1] == "volume=-2.2dB"
    assert "-t" not in args
    assert "-to" not in args
    assert args[args.index("-c:a") + 1] == "aac"


def test_parses_ffprobe_duration_and_the_ebur128_summary() -> None:
    assert parse_duration_ms("243.053500\n") == 243054
    assert parse_loudness(_SUMMARY) == (-16.0, -4.7)
    with pytest.raises(VoiceBuildError):
        parse_loudness("no summary")


def test_an_unknown_voice_is_refused() -> None:
    with pytest.raises(KeyError):
        load_athan_voices_config(REPO / CONFIG).pin("alafasy")


@pytest.mark.skipif(
    "DM_ATHAN_VOICE_SOURCES" not in os.environ, reason="needs the pinned recordings"
)
def test_the_build_reproduces_the_pinned_file(tmp_path: Path) -> None:
    sources = Path(os.environ["DM_ATHAN_VOICE_SOURCES"])
    for voice in load_athan_voices_config(REPO / CONFIG).voice:
        source = sources / f"{voice.sound_id}{Path(voice.source.url).suffix}"
        build = BuildVoice(runner=CapturingSubprocessRunner(), repo=REPO).run(
            voice.sound_id, source, tmp_path
        )
        assert build.sha256 == voice.expect_sha256
