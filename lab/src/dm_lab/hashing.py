"""sha256 of files, the identity of every pipeline input and output (DESIGN.md §17.6)."""

import hashlib
from pathlib import Path

_CHUNK = 1 << 20


def sha256_file(path: Path) -> str:
    """Lowercase hex sha256 of the bytes of `path`."""
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        while chunk := stream.read(_CHUNK):
            digest.update(chunk)
    return digest.hexdigest()
