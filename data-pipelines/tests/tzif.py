"""Hand-built TZif v1 files, so the oracle is tested without zic (RFC 8536 §3)."""

import struct
from dataclasses import dataclass


@dataclass(frozen=True)
class LocalType:
    """One `ttinfo`: UT offset in seconds, DST flag and abbreviation."""

    offset: int
    is_dst: bool
    abbreviation: str


def tzif_v1(transitions: list[tuple[int, int]], types: list[LocalType]) -> bytes:
    """Return a version-1 TZif file with the given (time, type index) transitions."""
    abbreviations = b""
    indexes: list[int] = []
    for local_type in types:
        indexes.append(len(abbreviations))
        abbreviations += local_type.abbreviation.encode("ascii") + b"\0"
    header = b"TZif" + b"\0" + b"\0" * 15
    header += struct.pack(">6l", 0, 0, 0, len(transitions), len(types), len(abbreviations))
    body = b"".join(struct.pack(">l", at) for at, _ in transitions)
    body += bytes(index for _, index in transitions)
    body += b"".join(
        struct.pack(">lBB", t.offset, int(t.is_dst), indexes[i]) for i, t in enumerate(types)
    )
    return header + body + abbreviations
