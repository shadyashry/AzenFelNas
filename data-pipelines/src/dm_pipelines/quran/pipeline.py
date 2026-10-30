"""`BuildQuran`: the offline Quran package (§9.5, §15 D107).

pinned 1441 Mushaf zip ─▶ pages/NNN.webp (lossless, verified pixel for pixel)
pinned Hafs V3.0 zip   ─▶ verses, surahs, page and line of every verse ─┐
pinned Tanzil metadata ─▶ juz starts (checked against the KFGQPC text) ──┴▶ quran.sqlite
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
from dm_pipelines.quran.juz_source import Juz, read_juz
from dm_pipelines.quran.pages import RenderedPage, render_pages
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
"""


class SourceHashError(ValueError):
    """A source's bytes are not the pinned ones."""


def _pinned(path: Path, sha256: str) -> bytes:
    data = path.read_bytes()
    if sha256_bytes(data) != sha256:
        message = f"{path.name}: sha256 is not the pinned {sha256}"
        raise SourceHashError(message)
    return data


def write_database(path: Path, config: QuranConfig, text: MushafText, juz: tuple[Juz, ...]) -> None:
    """Write `quran.sqlite`: meta, surahs, juz and verses, in a fixed order (reproducible)."""
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
        juz = read_juz(_pinned(juz_xml, config.juz.sha256), text)
        _pinned(mushaf, config.mushaf.sha256)
        out.mkdir(parents=True, exist_ok=True)
        pages = render_pages(
            mushaf,
            page_count=pin.page_count,
            width=pin.page_width,
            out_dir=out / "pages",
            workers=os.cpu_count() or 1,
        )
        write_database(out / DATABASE, config, text, juz)
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
            page_image=PageImage(
                format="webp-lossless",
                width=pages[0].width,
                height=pages[0].height,
                path_pattern=PAGE_PATTERN,
            ),
            files=[*(_file(out, p) for p in page_paths), _file(out, DATABASE), _file(out, FONT)],
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
                "pageWidth": str(config.package.page_width),
                "pagesBytes": str(sum(p.bytes for p in pages)),
            },
            outputs=[
                Output(path=MANIFEST, sha256=sha256_file(out / MANIFEST), records=len(pages) + 2)
            ],
        )
        (out / BUILD_MANIFEST).write_text(
            manifest.model_dump_json(exclude_none=True, indent=2) + "\n",
            encoding="utf-8",
            newline="",
        )
