"""Reads the juz and hizb-quarter starts from the Tanzil metadata, checked against the text.

The KFGQPC Word file has no juz numbers, so the 30 juz starts come from Tanzil's `quran-data.xml`.
They are accepted only when the Tanzil surah verse counts equal the KFGQPC ones and every juz that
does not open a surah starts with the quarter mark (U+06DE) in the KFGQPC text. A juz's page is the
KFGQPC page of its first verse. Tanzil's own page starts are not used: they follow an older
printing and differ from the KFGQPC 1441 layout on 25 pages.

The 240 quarters of a hizb (§15 D123) are the KFGQPC text's own: every verse it opens with U+06DE,
plus Tanzil's quarters that open a surah, where the text sets a surah header instead of the mark.
Tanzil's other quarters must be marked verses, except where its older printing differs
(`QUARTER_DIFFERENCES`, Tanzil's verse then the KFGQPC one); the KFGQPC mark is used there.
"""

from dataclasses import dataclass
from xml.etree import ElementTree as ET

from dm_pipelines.quran.text_source import MushafText

JUZ_COUNT = 30
QUARTER_COUNT = 240
# Tanzil's quarter start → the KFGQPC one, where the two printings differ.
QUARTER_DIFFERENCES = {(15, 50): (15, 49)}
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


@dataclass(frozen=True)
class Quarter:
    """One quarter of a hizb: its number (1..240) and where it starts."""

    number: int
    sura: int
    aya: int
    page: int


def read_quarters(xml: bytes, text: MushafText) -> tuple[Quarter, ...]:
    """Return the 240 quarters of the KFGQPC text; raise `JuzSourceError` on any disagreement."""
    root = ET.fromstring(xml)  # noqa: S314 - sha256-pinned
    tanzil = [(int(n.get("sura", "0")), int(n.get("aya", "0"))) for n in root.iter("quarter")]
    if len(tanzil) != QUARTER_COUNT:
        message = f"expected {QUARTER_COUNT} quarters in the metadata, found {len(tanzil)}"
        raise JuzSourceError(message)
    verses = {(verse.sura, verse.aya): verse for verse in text.verses}
    marked = {key for key, verse in verses.items() if verse.text.startswith(_QUARTER_MARK)}
    starts: set[tuple[int, int]] = set()
    for key in tanzil:
        verse = verses.get(key)
        if verse is None:
            message = f"quarter at {key}: no such verse"
            raise JuzSourceError(message)
        if key[1] == 1:
            if key in marked:
                message = f"quarter at {key} opens a surah but is marked"
                raise JuzSourceError(message)
            starts.add(key)
        elif key in marked:
            starts.add(key)
        elif QUARTER_DIFFERENCES.get(key) in marked:
            starts.add(QUARTER_DIFFERENCES[key])
        else:
            message = f"quarter at {key} has no quarter mark in the KFGQPC text"
            raise JuzSourceError(message)
    if not marked <= starts or len(starts) != QUARTER_COUNT:
        message = f"the KFGQPC marks and the metadata give {len(starts)} quarters"
        raise JuzSourceError(message)
    ordered = [verse for verse in text.verses if (verse.sura, verse.aya) in starts]
    return tuple(Quarter(i + 1, v.sura, v.aya, v.page) for i, v in enumerate(ordered))
