"""The pinned inputs of the Athan voices pipeline: `config/athan_voices.v1.toml` (§15 D111)."""

import tomllib
from pathlib import Path
from typing import Annotated, Literal

from pydantic import BaseModel, ConfigDict, Field, StrictFloat, StrictInt, StrictStr

_SHA256 = r"^[a-f0-9]{64}$"
_HTTPS = r"^https://"


class _Record(BaseModel):
    model_config = ConfigDict(
        frozen=True, extra="forbid", strict=True, validate_by_name=True, validate_by_alias=True
    )


class VoiceSource(_Record):
    """Where a recording comes from, who the source says made it and under which licence."""

    page: Annotated[StrictStr, Field(pattern=_HTTPS)]
    url: Annotated[StrictStr, Field(pattern=_HTTPS)]
    sha256: Annotated[StrictStr, Field(pattern=_SHA256)]
    retrieved: Annotated[StrictStr, Field(pattern=r"^\d{4}-\d{2}-\d{2}$")]
    creator: Annotated[StrictStr, Field(min_length=1)]
    origin: Annotated[StrictStr, Field(pattern=_HTTPS)]
    uploader: Annotated[StrictStr, Field(min_length=1)]
    recorded: Annotated[StrictStr, Field(pattern=r"^\d{4}-\d{2}-\d{2}$")]
    licence: Literal["CC0-1.0", "CC-PDM-1.0", "CC-BY-3.0", "CC-BY-4.0", "CC-BY-SA-4.0"]
    licence_url: Annotated[StrictStr, Field(alias="licenceUrl", pattern=_HTTPS)]
    licence_review: Annotated[StrictStr, Field(alias="licenceReview", pattern=_HTTPS)]
    original_extension: Annotated[
        StrictStr, Field(alias="originalExtension", pattern=r"^[a-z0-9]+$")
    ]


class VoiceProcessing(_Record):
    """The only processing allowed: a leading trim and one fixed gain, then AAC-LC."""

    trim_start_seconds: Annotated[StrictFloat, Field(alias="trimStartSeconds", ge=0, le=30)]
    gain_db: Annotated[StrictFloat, Field(alias="gainDb", ge=-20, le=6)]
    target_lufs: Annotated[StrictFloat, Field(alias="targetLufs", ge=-30, le=-10)]
    bitrate_kbps: Annotated[StrictInt, Field(alias="bitrateKbps", ge=64, le=256)]
    sample_rate: Literal[44100, 48000] = Field(alias="sampleRate")


class VoicePin(_Record):
    """One downloadable voice."""

    sound_id: Annotated[StrictStr, Field(alias="soundId", pattern=r"^[a-z0-9_]+$")]
    designation: Literal["standard", "fajr"]
    review: Literal["pending", "passed"]
    version: Annotated[StrictInt, Field(ge=1)]
    expect_sha256: Annotated[StrictStr, Field(alias="expectSha256", pattern=_SHA256)]
    ffmpeg: Annotated[StrictStr, Field(min_length=1)]
    source: VoiceSource
    processing: VoiceProcessing


class AthanVoicesConfig(_Record):
    """The whole pin file."""

    voice: list[VoicePin]

    def pin(self, sound_id: str) -> VoicePin:
        """Return the voice `sound_id`; raise `KeyError` when it is not pinned."""
        for voice in self.voice:
            if voice.sound_id == sound_id:
                return voice
        raise KeyError(sound_id)


def load_athan_voices_config(path: Path) -> AthanVoicesConfig:
    """Read and validate the pin file at `path`; raise `ValueError` when it is invalid."""
    with path.open("rb") as stream:
        document = tomllib.load(stream)
    return AthanVoicesConfig.model_validate(document, by_alias=True)
