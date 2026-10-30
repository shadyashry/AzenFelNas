"""Reads the KFGQPC Hafs Word file: pages, lines, surah headers and verses (§15 D107).

The Word file sets the whole Madinah Mushaf one Word page per Mushaf page and one line per Mushaf
line: a surah opens with a header line (`سُورَةُ …`) and, except at-Tawbah and al-Fatiha (whose
basmalah is its first verse), a basmalah line; every verse ends with U+06DD and its number in
Arabic-Indic digits. This module only splits that file at those marks: each verse's text is the
file's own characters, trimmed of the spaces around it, never edited.
"""

import re
import zipfile
from dataclasses import dataclass
from io import BytesIO
from xml.etree import ElementTree as ET

_W = "{http://schemas.openxmlformats.org/wordprocessingml/2006/main}"
_HEADER = "سُورَةُ"  # surah header word, vowelled
_END_OF_AYAH = chr(0x06DD)
_MARKER = re.compile(f"{_END_OF_AYAH}([{chr(0x0660)}-{chr(0x0669)}]+)")
_SPACES = " " + chr(0x00A0)
_NO_BASMALAH = frozenset({1, 9})
_ARABIC_INDIC_ZERO = 0x0660


class TextSourceError(ValueError):
    """The Word file does not have the layout this reader expects."""


@dataclass(frozen=True)
class Verse:
    """One verse: where it starts and ends in the Mushaf and its text as written in the source."""

    sura: int
    aya: int
    page: int
    line_start: int
    page_end: int
    line_end: int
    text: str


@dataclass(frozen=True)
class Sura:
    """One surah: its header as written in the source, its first page and its verse count."""

    number: int
    header: str
    start_page: int
    start_line: int
    verse_count: int


@dataclass(frozen=True)
class MushafText:
    """The whole source: page count, line count per page, surahs and verses in order."""

    page_lines: tuple[int, ...]
    suras: tuple[Sura, ...]
    verses: tuple[Verse, ...]


def read_pages(docx: bytes) -> list[list[str]]:
    """Return the Word file's pages, each a list of its non-empty lines."""
    with zipfile.ZipFile(BytesIO(docx)) as archive:
        document = ET.fromstring(archive.read("word/document.xml"))  # noqa: S314 - sha256-pinned
    body = document.find(f"{_W}body")
    if body is None:
        message = "word/document.xml has no body"
        raise TextSourceError(message)
    pages: list[list[str]] = [[]]
    line: list[str] = []

    def end_line() -> None:
        text = "".join(line)
        if text.strip(_SPACES):
            pages[-1].append(text)
        line.clear()

    for paragraph in body.iter(f"{_W}p"):
        for node in paragraph.iter():
            if node.tag == f"{_W}t":
                line.append(node.text or "")
            elif node.tag == f"{_W}br":
                end_line()
                if node.get(f"{_W}type") == "page":
                    pages.append([])
        end_line()
    return pages


def _number(digits: str) -> int:
    return int("".join(str(ord(c) - _ARABIC_INDIC_ZERO) for c in digits))


@dataclass
class _Reader:
    """Walks the lines in order, keeping the open surah and the open verse."""

    suras: list[Sura]
    verses: list[Verse]
    sura: int = 0
    header: str = ""
    start: tuple[int, int] = (0, 0)
    aya: int = 0
    expect_basmalah: bool = False
    pending: list[str] | None = None
    pending_from: tuple[int, int] = (0, 0)

    def close_sura(self) -> None:
        if self.sura == 0:
            return
        if self.pending is not None:
            message = f"surah {self.sura} ends inside a verse"
            raise TextSourceError(message)
        page, line = self.start
        self.suras.append(Sura(self.sura, self.header, page, line, self.aya))

    def line(self, page: int, number: int, text: str) -> None:
        if text.startswith(_HEADER):
            self.close_sura()
            self.sura += 1
            self.header = text.strip(_SPACES)
            self.start = (page, number)
            self.aya = 0
            self.expect_basmalah = self.sura not in _NO_BASMALAH
            return
        if self.sura == 0:
            message = f"page {page} line {number}: text before the first surah header"
            raise TextSourceError(message)
        if self.expect_basmalah:
            if _END_OF_AYAH in text:
                message = f"surah {self.sura}: the basmalah line carries a verse marker"
                raise TextSourceError(message)
            self.expect_basmalah = False
            return
        self.verse_parts(page, number, text)

    def verse_parts(self, page: int, number: int, text: str) -> None:
        cursor = 0
        for match in _MARKER.finditer(text):
            self.append(page, number, text[cursor : match.start()])
            if self.pending is None:
                message = f"page {page} line {number}: a verse marker with no text"
                raise TextSourceError(message)
            aya = _number(match.group(1))
            if aya != self.aya + 1:
                message = f"surah {self.sura}: verse {aya} follows {self.aya}"
                raise TextSourceError(message)
            self.aya = aya
            body = " ".join(self.pending)
            start_page, start_line = self.pending_from
            self.verses.append(Verse(self.sura, aya, start_page, start_line, page, number, body))
            self.pending = None
            cursor = match.end()
        self.append(page, number, text[cursor:])

    def append(self, page: int, number: int, fragment: str) -> None:
        trimmed = fragment.strip(_SPACES)
        if not trimmed:
            return
        if self.pending is None:
            self.pending = []
            self.pending_from = (page, number)
        self.pending.append(trimmed)


def read_mushaf_text(docx: bytes, *, page_count: int) -> MushafText:
    """Parse the Word file; raise `TextSourceError` unless it has `page_count` pages."""
    pages = read_pages(docx)
    if len(pages) != page_count:
        message = f"{len(pages)} pages, expected {page_count}"
        raise TextSourceError(message)
    reader = _Reader(suras=[], verses=[])
    for page_index, lines in enumerate(pages):
        for line_index, text in enumerate(lines):
            reader.line(page_index + 1, line_index + 1, text)
    reader.close_sura()
    page = reader.verses[-1].page_end if reader.verses else 0
    if page != page_count:
        message = f"the last verse is on page {page}, expected {page_count}"
        raise TextSourceError(message)
    return MushafText(
        page_lines=tuple(len(lines) for lines in pages),
        suras=tuple(reader.suras),
        verses=tuple(reader.verses),
    )
