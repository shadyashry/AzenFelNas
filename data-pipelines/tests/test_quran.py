"""The Quran pipeline: Word-file parsing, juz checks and the full build (§9.5, §15 D106).

The unit tests use a synthetic Word file with placeholder words, never Quran text. The full build
runs only when `DM_QURAN_SOURCES` names a directory holding the three pinned sources.
"""

import os
import sqlite3
import zipfile
from io import BytesIO
from pathlib import Path

import pytest

from dm_pipelines.quran.juz_source import JuzSourceError, read_juz
from dm_pipelines.quran.pipeline import BuildQuran
from dm_pipelines.quran.text_source import MushafText, TextSourceError, read_mushaf_text

REPO = Path(__file__).resolve().parents[2]
HEADER = "سُورَةُ"
END = chr(0x06DD)
QUARTER = chr(0x06DE)
NBSP = chr(0x00A0)
_W = 'xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"'


def _marker(n: int) -> str:
    return END + "".join(chr(0x0660 + int(d)) for d in str(n))


def _docx(pages: list[list[str]]) -> bytes:
    """Return a Word file with one paragraph per line and a page break between pages."""
    body: list[str] = []
    for index, lines in enumerate(pages):
        for number, line in enumerate(lines):
            br = '<w:r><w:br w:type="page"/></w:r>' if index and number == 0 else ""
            body.append(f'<w:p>{br}<w:r><w:t xml:space="preserve">{line}</w:t></w:r></w:p>')
    xml = f"<w:document {_W}><w:body>{''.join(body)}</w:body></w:document>"
    buffer = BytesIO()
    with zipfile.ZipFile(buffer, "w") as archive:
        archive.writestr("word/document.xml", xml)
    return buffer.getvalue()


def _two_suras() -> list[list[str]]:
    return [
        [f"{HEADER} أولى", f"كلمة{NBSP}{_marker(1)}", f"ثانية ثالثة {_marker(2)} رابعة"],
        [f"خامسة {_marker(3)}", f"{HEADER} أخرى", "سطر البسملة", f"{QUARTER} سادسة {_marker(1)}"],
    ]


def test_req_qrn_002_verses_keep_source_text_page_and_lines() -> None:
    text = read_mushaf_text(_docx(_two_suras()), page_count=2)

    assert text.page_lines == (3, 4)
    assert [(s.number, s.start_page, s.start_line, s.verse_count) for s in text.suras] == [
        (1, 1, 1, 3),
        (2, 2, 2, 1),
    ]
    first, _, third, fourth = text.verses
    assert (first.sura, first.aya, first.page, first.line_start, first.text) == (1, 1, 1, 2, "كلمة")
    assert (third.page, third.line_start, third.page_end, third.line_end) == (1, 3, 2, 1)
    assert third.text == "رابعة خامسة"
    assert (fourth.sura, fourth.aya, fourth.text) == (2, 1, f"{QUARTER} سادسة")


def test_req_qrn_002_refuses_a_wrong_page_count() -> None:
    with pytest.raises(TextSourceError, match="2 pages, expected 3"):
        read_mushaf_text(_docx(_two_suras()), page_count=3)


def test_req_qrn_002_refuses_a_gap_in_verse_numbers() -> None:
    pages = [[f"{HEADER} أولى", f"كلمة {_marker(1)} ثانية {_marker(3)}"]]

    with pytest.raises(TextSourceError, match="verse 3 follows 1"):
        read_mushaf_text(_docx(pages), page_count=1)


def _tanzil(juz: list[tuple[int, int, int]], suras: list[tuple[int, int]]) -> bytes:
    sura_xml = "".join(f'<sura index="{i}" ayas="{n}"/>' for i, n in suras)
    juz_xml = "".join(f'<juz index="{i}" sura="{s}" aya="{a}"/>' for i, s, a in juz)
    return f"<quran><suras>{sura_xml}</suras><juzs>{juz_xml}</juzs></quran>".encode()


def _text() -> MushafText:
    return read_mushaf_text(_docx(_two_suras()), page_count=2)


def test_req_qrn_003_juz_must_match_the_quarter_marks() -> None:
    bad = [(1, 1, 1), (2, 1, 3), *((n, 2, 1) for n in range(3, 31))]

    with pytest.raises(JuzSourceError, match="no quarter mark"):
        read_juz(_tanzil(bad, [(1, 3), (2, 1)]), _text())


def test_req_qrn_003_juz_verse_counts_must_match() -> None:
    juz = [(n, 1, 1) for n in range(1, 31)]

    with pytest.raises(JuzSourceError, match="verse counts"):
        read_juz(_tanzil(juz, [(1, 4), (2, 1)]), _text())


def test_req_qrn_003_juz_page_is_the_page_of_its_first_verse() -> None:
    juz = [(1, 1, 1), (2, 2, 1), *((n, 2, 1) for n in range(3, 31))]

    result = read_juz(_tanzil(juz, [(1, 3), (2, 1)]), _text())

    assert [(j.number, j.page) for j in result[:2]] == [(1, 1), (2, 2)]


_SOURCES = os.environ.get("DM_QURAN_SOURCES")


@pytest.mark.skipif(_SOURCES is None, reason="DM_QURAN_SOURCES not set")
def test_req_qrn_001_rebuild_has_every_page_verse_and_juz(tmp_path: Path) -> None:
    sources = Path(_SOURCES or ".")

    manifest = BuildQuran(repo=REPO).run(
        sources / "1441-AI-hafs.zip",
        sources / "KFGQPC-Hafs-V30.zip",
        sources / "quran-data.xml",
        tmp_path,
    )

    assert manifest.edition.page_count == 604
    assert [f.path for f in manifest.files[:2]] == ["pages/001.webp", "pages/002.webp"]
    assert len(manifest.files) == 606
    with sqlite3.connect(tmp_path / "quran.sqlite") as db:
        assert db.execute("SELECT count(*), max(page) FROM verse").fetchone() == (6236, 604)
        pages = [row[0] for row in db.execute("SELECT page FROM juz ORDER BY number")]
    assert pages[:7] == [1, 22, 42, 62, 82, 102, 121]
    assert pages[-1] == 582
