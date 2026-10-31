"""`BuildQuran`: the offline Quran package (§9.5, §15 D107).

pinned 1441 Mushaf zip ─▶ pages/NNN.webp (frameless, cut to the page's content, lossless)
                       ─▶ pages/boxes.json (each page's view box, §15 D123)
pinned Hafs V3.0 zip   ─▶ verses, surahs, page and line of every verse ─┐
pinned Tanzil metadata ─▶ juz and hizb-quarter starts (checked against   ├▶ quran.sqlite
                          the KFGQPC text) ───────────────────────────────┘
                       ─▶ fonts/kfgqpc-hafs-v30.ttf (the font file, byte for byte)
  ─▶ manifest.json (quran_package.v1: every file by size and sha256; the app pins its sha256)
  ─▶ build_manifest.json (pipeline_manifest.v1: inputs, tools and outputs; not shipped)

The output directory is what the CDN serves under `<channel>/quran/<packageId>/<version>/`.
"""

import os
import sqlite3
import sys
import zipfile
from dataclasses import dataclass
from importlib.metadata import version as installed_version
from pathlib import Path

from dm_pipelines.hashing import sha256_bytes, sha256_file
from dm_pipelines.quran.config import QuranConfig, load_quran_config
from dm_pipelines.quran.juz_source import Juz, Quarter, read_juz, read_quarters
from dm_pipelines.quran.pages import (
    PageSourceError,
    PageSurvey,
    RenderedPage,
    boxes_json,
    render_pages,
)
from dm_pipelines.quran.text_source import MushafText, read_mushaf_text
from dm_pipelines.schema.pipeline_manifest_v1 import Input, Output, PipelineManifestV1
from dm_pipelines.schema.quran_package_v1 import (
    Edition,
    File,
    PageImage,
    QuranPackageManifestV1,
    Source,
)

CONFIG = "data-pipelines/config/quran.v1.toml"
MANIFEST = "manifest.json"
BUILD_MANIFEST = "build_manifest.json"
DATABASE = "quran.sqlite"
FONT = "fonts/kfgqpc-hafs-v30.ttf"
PAGE_PATTERN = "pages/{page:03}.webp"
BOXES = "pages/boxes.json"
# Marks in the KFGQPC text that have a recitation note in the margin.
SAJDAH = "\u06e9"
SMALL_HIGH_SEEN = "\u06dc"
LAYOUT_ID = "kfgqpc-hafs-1441-604"
PUBLISHER = "King Fahd Glorious Quran Printing Complex"
_SOURCES = (
    "data-pipelines/src/dm_pipelines/quran/text_source.py",
    "data-pipelines/src/dm_pipelines/quran/juz_source.py",
    "data-pipelines/src/dm_pipelines/quran/pages.py",
    "data-pipelines/src/dm_pipelines/quran/pipeline.py",
)
_SCHEMA = """
CREATE TABLE meta(key TEXT PRIMARY KEY, value TEXT NOT NULL) WITHOUT ROWID;
CREATE TABLE sura(
  number INTEGER PRIMARY KEY, header TEXT NOT NULL, start_page INTEGER NOT NULL,
  start_line INTEGER NOT NULL, verse_count INTEGER NOT NULL);
CREATE TABLE juz(
  number INTEGER PRIMARY KEY, sura INTEGER NOT NULL, aya INTEGER NOT NULL, page INTEGER NOT NULL);
CREATE TABLE verse(
  id INTEGER PRIMARY KEY, sura INTEGER NOT NULL, aya INTEGER NOT NULL, page INTEGER NOT NULL,
  line_start INTEGER NOT NULL, page_end INTEGER NOT NULL, line_end INTEGER NOT NULL,
  text TEXT NOT NULL, UNIQUE(sura, aya));
CREATE INDEX verse_page ON verse(page);
CREATE TABLE quarter(
  number INTEGER PRIMARY KEY, sura INTEGER NOT NULL, aya INTEGER NOT NULL, page INTEGER NOT NULL);
"""


class SourceHashError(ValueError):
    """A source's bytes are not the pinned ones."""


def _pinned(path: Path, sha256: str) -> bytes:
    data = path.read_bytes()
    if sha256_bytes(data) != sha256:
        message = f"{path.name}: sha256 is not the pinned {sha256}"
        raise SourceHashError(message)
    return data


def pick_medallions(
    surveys: list[PageSurvey], quarters: tuple[Quarter, ...], text: MushafText
) -> dict[int, frozenset[int]]:
    """Return the margin ornaments of each page that are hizb medallions (§15 D123).

    On the page where a quarter starts, the ornament nearest the quarter's first line, which must
    be clearly nearer than any other. Where a sajdah falls on that page and the Complex set both
    in one medallion (the page's only ornament), it stays: the sajdah note is never lost. Every
    other quarter but the first (page 1 has no margin) loses exactly one; every ornament kept is
    a recitation note on a page whose text has a sajdah (U+06E9) or a small high seen (U+06DC)
    mark, and every sajdah page keeps its note.
    """
    lines = {(v.sura, v.aya): v.line_start for v in text.verses}
    sajdah = {v.page for v in text.verses if SAJDAH in v.text}
    by_page = {s.page: s for s in surveys}
    drops: dict[int, frozenset[int]] = {}
    for q in quarters[1:]:
        s = by_page[q.page]
        if q.page in sajdah and len(s.ornaments) == 1:
            continue
        pitch = (s.core[3] - s.core[1]) / 15
        centre = s.core[3] - (lines[(q.sura, q.aya)] - 0.5) * pitch
        distance = sorted((abs((b[1] + b[3]) / 2 - centre), n) for n, b in enumerate(s.ornaments))
        if not distance or distance[0][0] > 3 * pitch:
            message = f"page {q.page}: no hizb medallion beside quarter {q.number}"
            raise PageSourceError(message)
        if len(distance) > 1 and distance[1][0] - distance[0][0] < pitch:
            message = f"page {q.page}: two margin ornaments beside quarter {q.number}"
            raise PageSourceError(message)
        if q.page in drops:
            message = f"page {q.page}: two quarters start on one page"
            raise PageSourceError(message)
        drops[q.page] = frozenset({distance[0][1]})
    marked = {v.page for v in text.verses if SAJDAH in v.text or SMALL_HIGH_SEEN in v.text}
    notes = {s.page for s in surveys if len(s.ornaments) > len(drops.get(s.page, ()))}
    if not notes <= marked or not sajdah <= notes:
        message = (
            f"margin notes on unmarked pages {sorted(notes - marked)[:5]}, "
            f"sajdah pages without a note {sorted(sajdah - notes)[:5]}"
        )
        raise PageSourceError(message)
    return drops


def write_database(
    path: Path,
    config: QuranConfig,
    text: MushafText,
    juz: tuple[Juz, ...],
    quarters: tuple[Quarter, ...],
) -> None:
    """Write `quran.sqlite`: meta, surahs, juz, verses and quarters, in a fixed order."""
    path.unlink(missing_ok=True)
    db = sqlite3.connect(path)
    try:
        db.executescript(_SCHEMA)
        db.executemany(
            "INSERT INTO meta VALUES (?, ?)",
            [
                ("packageId", config.package.id),
                ("version", config.package.version),
                ("layoutId", LAYOUT_ID),
            ],
        )
        db.executemany(
            "INSERT INTO sura VALUES (?, ?, ?, ?, ?)",
            [(s.number, s.header, s.start_page, s.start_line, s.verse_count) for s in text.suras],
        )
        db.executemany(
            "INSERT INTO juz VALUES (?, ?, ?, ?)", [(j.number, j.sura, j.aya, j.page) for j in juz]
        )
        db.executemany(
            "INSERT INTO verse VALUES (?, ?, ?, ?, ?, ?, ?, ?)",
            [
                (i + 1, v.sura, v.aya, v.page, v.line_start, v.page_end, v.line_end, v.text)
                for i, v in enumerate(text.verses)
            ],
        )
        db.executemany(
            "INSERT INTO quarter VALUES (?, ?, ?, ?)",
            [(q.number, q.sura, q.aya, q.page) for q in quarters],
        )
        db.commit()
        db.execute("VACUUM")
    finally:
        db.close()


def _file(out: Path, path: str) -> File:
    target = out / path
    return File(path=path, bytes=target.stat().st_size, sha256=sha256_file(target))


@dataclass(frozen=True)
class BuildQuran:
    """Builds the package from the three pinned sources."""

    repo: Path

    def run(self, mushaf: Path, text_zip: Path, juz_xml: Path, out: Path) -> QuranPackageManifestV1:
        """Build into `out` (created if needed) and return the package manifest written there."""
        config = load_quran_config(self.repo / CONFIG)
        pin = config.package
        text_bytes = _pinned(text_zip, config.text.sha256)
        with zipfile.ZipFile(text_zip) as archive:
            docx = archive.read(config.text.docx_member)
            font = archive.read(config.text.font_member)
        text = read_mushaf_text(docx, page_count=pin.page_count)
        juz_bytes = _pinned(juz_xml, config.juz.sha256)
        juz = read_juz(juz_bytes, text)
        quarters = read_quarters(juz_bytes, text)
        _pinned(mushaf, config.mushaf.sha256)
        out.mkdir(parents=True, exist_ok=True)
        pages = render_pages(
            mushaf,
            pin,
            out_dir=out / "pages",
            workers=os.cpu_count() or 1,
            medallions=lambda surveys: pick_medallions(surveys, quarters, text),
        )
        (out / BOXES).write_bytes(boxes_json(pages))
        write_database(out / DATABASE, config, text, juz, quarters)
        (out / FONT).parent.mkdir(parents=True, exist_ok=True)
        (out / FONT).write_bytes(font)
        manifest = self._manifest(config, text, pages, out)
        (out / MANIFEST).write_text(
            manifest.model_dump_json(by_alias=True, exclude_none=True, indent=2) + "\n",
            encoding="utf-8",
            newline="",
        )
        self._build_manifest(config, out, text_bytes, pages)
        return manifest

    def _manifest(
        self, config: QuranConfig, text: MushafText, pages: list[RenderedPage], out: Path
    ) -> QuranPackageManifestV1:
        page_paths = [PAGE_PATTERN.format(page=p.page) for p in pages]
        return QuranPackageManifestV1(
            schema_version=1,
            package_id=config.package.id,
            version=config.package.version,
            layout_id=LAYOUT_ID,
            edition=Edition(
                riwayah="hafs",
                publisher=PUBLISHER,
                print_edition=config.mushaf.version,
                page_count=len(pages),
                sura_count=len(text.suras),
                verse_count=len(text.verses),
                sources=[
                    Source(
                        role="pages",
                        url=config.mushaf.url,
                        sha256=config.mushaf.sha256,
                        version=config.mushaf.version,
                        license=config.mushaf.license,
                    ),
                    Source(
                        role="text",
                        url=config.text.url,
                        sha256=config.text.sha256,
                        version=config.text.version,
                        license=config.text.license,
                    ),
                    Source(
                        role="juz",
                        url=config.juz.url,
                        sha256=config.juz.sha256,
                        version=config.juz.version,
                        license=config.juz.license,
                    ),
                ],
            ),
            # Each page has its own view box and size (`pages/boxes.json`); these are the
            # largest, which readers of an earlier build use only as an aspect ratio.
            page_image=PageImage(
                format="webp-lossless",
                width=max(p.width for p in pages),
                height=max(p.height for p in pages),
                path_pattern=PAGE_PATTERN,
            ),
            files=[
                *(_file(out, p) for p in page_paths),
                _file(out, BOXES),
                _file(out, DATABASE),
                _file(out, FONT),
            ],
        )

    def _build_manifest(
        self, config: QuranConfig, out: Path, text_bytes: bytes, pages: list[RenderedPage]
    ) -> None:
        manifest = PipelineManifestV1(
            schema_version=1,
            pipeline="data-pipelines.quran",
            inputs=[
                Input(role="mushaf", url=config.mushaf.url, sha256=config.mushaf.sha256),
                Input(role="text", url=config.text.url, sha256=sha256_bytes(text_bytes)),
                Input(role="juz", url=config.juz.url, sha256=config.juz.sha256),
                Input(role="config", path=CONFIG, sha256=sha256_file(self.repo / CONFIG)),
                *(
                    Input(role="pipeline_source", path=path, sha256=sha256_file(self.repo / path))
                    for path in _SOURCES
                ),
            ],
            tools={
                "pillow": installed_version("pillow"),
                "pypdfium2": installed_version("pypdfium2"),
                "python": f"{sys.version_info.major}.{sys.version_info.minor}",
                "sqlite": sqlite3.sqlite_version,
            },
            parameters={
                "packageId": config.package.id,
                "version": config.package.version,
                "boxWidth": str(config.package.box_width),
                "boxMargin": str(config.package.box_margin),
                "greyLevels": str(config.package.grey_levels),
                "pagesBytes": str(sum(p.bytes for p in pages)),
            },
            outputs=[
                Output(path=MANIFEST, sha256=sha256_file(out / MANIFEST), records=len(pages) + 3)
            ],
        )
        (out / BUILD_MANIFEST).write_text(
            manifest.model_dump_json(exclude_none=True, indent=2) + "\n",
            encoding="utf-8",
            newline="",
        )
