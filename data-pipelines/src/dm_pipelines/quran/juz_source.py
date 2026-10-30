"""Reads the juz boundaries from the Tanzil metadata and checks them against the KFGQPC text.

The KFGQPC Word file has no juz numbers, so the 30 juz starts come from Tanzil's `quran-data.xml`.
They are accepted only when the Tanzil surah verse counts equal the KFGQPC ones and every juz that
does not open a surah starts with the quarter mark (U+06DE) in the KFGQPC text. A juz's page is the
KFGQPC page of its first verse. Tanzil's own page starts are not used: they follow an older
printing and differ from the KFGQPC 1441 layout on 25 pages.
"""

from dataclasses import dataclass
from xml.etree import ElementTree as ET

from dm_pipelines.quran.text_source import MushafText

JUZ_COUNT = 30
_QUARTER_MARK = chr(0x06DE)


class JuzSourceError(ValueError):
    """The metadata disagrees with the KFGQPC text."""


@dataclass(frozen=True)
class Juz:
    """One juz: its number and where it starts."""

    number: int
    sura: int
    aya: int
    page: int


def _ints(node: ET.Element, *names: str) -> tuple[int, ...]:
    return tuple(int(node.get(name, "0")) for name in names)


def read_juz(xml: bytes, text: MushafText) -> tuple[Juz, ...]:
    """Return the 30 juz starts of `xml`; raise `JuzSourceError` on any disagreement."""
    root = ET.fromstring(xml)  # noqa: S314 - sha256-pinned
    counts = [_ints(node, "index", "ayas") for node in root.iter("sura")]
    expected = [(sura.number, sura.verse_count) for sura in text.suras]
    if counts != expected:
        message = "the Tanzil surah verse counts differ from the KFGQPC text"
        raise JuzSourceError(message)
    verses = {(verse.sura, verse.aya): verse for verse in text.verses}
    juz: list[Juz] = []
    for node in root.iter("juz"):
        number, sura, aya = _ints(node, "index", "sura", "aya")
        verse = verses.get((sura, aya))
        if verse is None:
            message = f"juz {number}: no verse {sura}:{aya}"
            raise JuzSourceError(message)
        if aya != 1 and not verse.text.startswith(_QUARTER_MARK):
            message = f"juz {number} ({sura}:{aya}) has no quarter mark in the KFGQPC text"
            raise JuzSourceError(message)
        juz.append(Juz(number, sura, aya, verse.page))
    if [j.number for j in juz] != list(range(1, JUZ_COUNT + 1)):
        message = f"expected juz 1..{JUZ_COUNT}"
        raise JuzSourceError(message)
    return tuple(juz)
