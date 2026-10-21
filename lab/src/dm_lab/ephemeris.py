"""The JPL ephemeris file: fetched by URL, verified by sha256, cached, never committed (§15 D28)."""

import shutil
import urllib.request
from pathlib import Path
from typing import Protocol

from dm_lab.config import EphemerisConfig
from dm_lab.hashing import sha256_file

_FETCH_TIMEOUT_S = 600


class EphemerisIntegrityError(Exception):
    """The fetched ephemeris does not have the pinned sha256."""


class FetchUrl(Protocol):
    """Port: copy the bytes at an https `url` to `destination`."""

    def __call__(self, url: str, destination: Path) -> None:
        """Write the resource at `url` to `destination`, replacing it.

        Raises:
            OSError: the resource cannot be fetched or written.

        """
        ...


def urllib_fetch(url: str, destination: Path) -> None:
    """`FetchUrl` over `urllib`; accepts https URLs only."""
    if not url.startswith("https://"):
        msg = f"refusing a non-https ephemeris URL: {url}"
        raise ValueError(msg)
    with (
        urllib.request.urlopen(url, timeout=_FETCH_TIMEOUT_S) as response,  # noqa: S310 - https checked above
        destination.open("wb") as stream,
    ):
        shutil.copyfileobj(response, stream)


def ensure_ephemeris(config: EphemerisConfig, directory: Path, fetch: FetchUrl) -> Path:
    """Path of a local copy of the pinned ephemeris, fetching it when absent or altered.

    A cached file is used only if its sha256 matches `config.sha256`; a fetched file replaces the
    cache only after it matches.

    Raises:
        EphemerisIntegrityError: the fetched bytes do not match the pin.
        OSError: fetching or writing failed.

    """
    target = directory / config.file_name
    if target.is_file() and sha256_file(target) == config.sha256:
        return target
    directory.mkdir(parents=True, exist_ok=True)
    partial = target.with_name(target.name + ".partial")
    fetch(config.url, partial)
    digest = sha256_file(partial)
    if digest != config.sha256:
        partial.unlink()
        msg = f"{config.url}: sha256 {digest} does not match the pin {config.sha256}"
        raise EphemerisIntegrityError(msg)
    partial.replace(target)
    return target
