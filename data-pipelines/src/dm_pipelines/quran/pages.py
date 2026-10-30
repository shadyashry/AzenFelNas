"""Renders the KFGQPC Illustrator pages to lossless WebP (§15 D106).

Each `.ai` file of the 1441 zip carries a PDF-compatible stream; PDFium renders the whole media box
(margins, frame, ornaments and page number included, nothing cropped) at the configured width on a
white page. The WebP is lossless: every rendered pixel is checked to decode back unchanged, so the
package image equals the render of the official vector page.
"""

import zipfile
from concurrent.futures import ProcessPoolExecutor
from dataclasses import dataclass
from io import BytesIO
from pathlib import Path

import pypdfium2 as pdfium
from PIL import Image, ImageChops

from dm_pipelines.hashing import sha256_bytes

_AI_SUFFIX = "___Hafs39__DM.ai"


class PageSourceError(ValueError):
    """The Mushaf zip does not hold the expected pages, or a page did not render faithfully."""


@dataclass(frozen=True)
class RenderedPage:
    """One page written to disk: its number, size in pixels and points, bytes and sha256."""

    page: int
    width: int
    height: int
    points: tuple[float, float]
    bytes: int
    sha256: str


def page_members(archive: zipfile.ZipFile, page_count: int) -> list[str]:
    """Return the zip members of pages 1..page_count in order; raise unless each is there once."""
    members = sorted(name for name in archive.namelist() if name.endswith(_AI_SUFFIX))
    numbers = [int(Path(name).name.removesuffix(_AI_SUFFIX)) for name in members]
    if numbers != list(range(1, page_count + 1)):
        message = f"expected pages 1..{page_count}, found {len(numbers)} page files"
        raise PageSourceError(message)
    return members


def render_page(zip_path: Path, member: str, page: int, width: int, out: Path) -> RenderedPage:
    """Render `member` (page `page`) `width` pixels wide to `out`; verify the round trip."""
    with zipfile.ZipFile(zip_path) as archive:
        data = archive.read(member)
    document = pdfium.PdfDocument(data)
    try:
        if len(document) != 1:
            message = f"page {page}: {len(document)} PDF pages in one file"
            raise PageSourceError(message)
        source = document[0]
        points = source.get_size()
        image = source.render(scale=width / points[0], fill_color=(255, 255, 255, 255)).to_pil()
    finally:
        document.close()
    image = image.convert("RGB")
    buffer = BytesIO()
    image.save(buffer, format="WEBP", lossless=True, quality=100, method=6, exact=True)
    encoded = buffer.getvalue()
    with Image.open(BytesIO(encoded)) as decoded:
        if ImageChops.difference(image, decoded.convert("RGB")).getbbox() is not None:
            message = f"page {page}: the WebP does not decode to the rendered pixels"
            raise PageSourceError(message)
    out.write_bytes(encoded)
    return RenderedPage(
        page, image.width, image.height, points, len(encoded), sha256_bytes(encoded)
    )


def render_pages(
    zip_path: Path, *, page_count: int, width: int, out_dir: Path, workers: int
) -> list[RenderedPage]:
    """Render every page into `out_dir/NNN.webp` and return them in page order."""
    with zipfile.ZipFile(zip_path) as archive:
        members = page_members(archive, page_count)
    out_dir.mkdir(parents=True, exist_ok=True)
    with ProcessPoolExecutor(max_workers=workers) as pool:
        futures = [
            pool.submit(render_page, zip_path, member, i + 1, width, out_dir / f"{i + 1:03}.webp")
            for i, member in enumerate(members)
        ]
        pages = [future.result() for future in futures]
    sizes = {(p.width, p.height, p.points) for p in pages}
    if len(sizes) != 1:
        message = f"pages differ in size: {sorted(sizes)[:3]}"
        raise PageSourceError(message)
    return pages
