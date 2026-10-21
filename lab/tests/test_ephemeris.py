"""The ephemeris is used only with its pinned sha256 (DESIGN.md §15 D28)."""

import hashlib
from pathlib import Path

import pytest

from dm_lab.config import EphemerisConfig
from dm_lab.ephemeris import EphemerisIntegrityError, ensure_ephemeris

_GOOD = b"pinned ephemeris bytes"


def _config(content: bytes) -> EphemerisConfig:
    return EphemerisConfig(
        file_name="zz.bsp",
        url="https://example.invalid/zz.bsp",
        sha256=hashlib.sha256(content).hexdigest(),
        size_bytes=len(content),
    )


class _FakeFetch:
    """Fake `FetchUrl` port serving fixed bytes and counting calls."""

    def __init__(self, content: bytes) -> None:
        self.content = content
        self.calls = 0

    def __call__(self, url: str, destination: Path) -> None:
        assert url.startswith("https://")
        self.calls += 1
        destination.write_bytes(self.content)


def test_fetches_and_caches_the_pinned_file(tmp_path: Path) -> None:
    """A missing file is fetched, verified and kept under its configured name."""
    fetch = _FakeFetch(_GOOD)

    path = ensure_ephemeris(_config(_GOOD), tmp_path, fetch)

    assert path == tmp_path / "zz.bsp"
    assert path.read_bytes() == _GOOD
    assert fetch.calls == 1


def test_reuses_a_cached_file_with_the_pinned_hash(tmp_path: Path) -> None:
    """A cached file with the right sha256 is used without fetching."""
    (tmp_path / "zz.bsp").write_bytes(_GOOD)
    fetch = _FakeFetch(b"other")

    ensure_ephemeris(_config(_GOOD), tmp_path, fetch)

    assert fetch.calls == 0


def test_refetches_an_altered_cached_file(tmp_path: Path) -> None:
    """A cached file whose bytes changed is replaced by a verified download."""
    (tmp_path / "zz.bsp").write_bytes(b"tampered")
    fetch = _FakeFetch(_GOOD)

    path = ensure_ephemeris(_config(_GOOD), tmp_path, fetch)

    assert path.read_bytes() == _GOOD
    assert fetch.calls == 1


def test_rejects_bytes_that_do_not_match_the_pin(tmp_path: Path) -> None:
    """Wrong bytes fail loudly and leave nothing behind."""
    fetch = _FakeFetch(b"wrong bytes")

    with pytest.raises(EphemerisIntegrityError):
        ensure_ephemeris(_config(_GOOD), tmp_path, fetch)

    assert list(tmp_path.iterdir()) == []
