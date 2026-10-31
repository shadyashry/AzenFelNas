"""Renders the KFGQPC Illustrator pages to frameless, lossless WebP (§15 D107, D123).

Each `.ai` file of the 1441 zip carries a PDF-compatible stream drawn entirely with vector paths.
Four kinds of object are taken out, each identified from the page itself and checked:

* the frame: the one object filled only with the frame green that encloses the page's main text;
* the running header (juz and surah name) and the page number: objects lying wholly above or
  below the frame, drawn only in the text ink and white (the reader shows both itself);
* the hizb medallions: of the ornaments in the outer margin (objects wholly beside the frame,
  drawn only in the frame green, the ink and white, grouped where they touch), the one beside the
  line where a quarter of a hizb starts, chosen by the pipeline. The reader shows that quarter in
  its page details instead.

Everything else stays where the Complex placed it: every letter, dot, mark and sign, the verse
markers and their numbers, the surah heading bands, the basmalahs, and the margin notes that
guide the recitation (sajdah, and the sakt notes such as «سكتة لطيفة»). Nothing is moved, scaled
separately or recoloured. Each page is then cut to its own view box: the bounds of what is kept
plus a small margin, so the reader scales the writing itself, not the canvas. The box is
rendered on white at the scale that makes it `boxWidth` pixels wide, kept as grey rounded to
`greyLevels` evenly spaced levels (edges stay where they are; only antialiasing tones round; the
reader draws the ink in the theme's colour) and saved as lossless WebP. Checks per page: every
pixel decodes back unchanged, every kept object lies inside the box, no object straddles the
frame's side, and every ink pixel inside the box (outside a dropped medallion) is identical to
the render of the untouched page, so no letter or mark changed.
"""

import json
import zipfile
from collections.abc import Callable, Sequence
from concurrent.futures import ProcessPoolExecutor
from ctypes import c_float, c_uint
from dataclasses import dataclass
from io import BytesIO
from pathlib import Path

import pypdfium2 as pdfium
import pypdfium2.raw as pdfium_c
from PIL import Image, ImageChops, ImageDraw

from dm_pipelines.hashing import sha256_bytes
from dm_pipelines.quran.config import PackagePin

_AI_SUFFIX = "___Hafs39__DM.ai"
_FORM = 5

# The frame's fill, the text ink and white, as the 1441 files draw them (RGBA).
FRAME_FILL = (192, 226, 202, 255)
INK_FILL = (35, 31, 32, 255)
WHITE_FILL = (255, 255, 255, 255)

# Ink darker than the frame green: these pixels must survive the frame's removal unchanged.
_INK_BELOW = 200

# Pages 1 and 2 open the Mushaf: no running header and no page number.
OPENING_PAGES = 2

Bounds = tuple[float, float, float, float]  # PDF points: left, bottom, right, top
Fill = tuple[int, int, int, int] | None
_Item = tuple[pdfium_c.FPDF_PAGEOBJECT, Bounds, frozenset[Fill]]


class PageSourceError(ValueError):
    """The Mushaf zip does not hold the expected pages, or a page did not render faithfully."""


@dataclass(frozen=True)
class PageSurvey:
    """What one page holds: the frame, what is removed and the bounds of what is kept.

    `core` bounds every kept object inside the frame; `ornaments` are the margin ornaments from
    the top of the page, each by its bounds.
    """

    page: int
    size: tuple[float, float]
    frame: Bounds
    core: Bounds
    text: Bounds
    removed_above: int
    removed_below: int
    ornaments: tuple[Bounds, ...]


@dataclass(frozen=True)
class PageBox:
    """A page's view box in PDF points (left, bottom, right, top)."""

    page: int
    left: float
    bottom: float
    right: float
    top: float


@dataclass(frozen=True)
class RenderJob:
    """One page to render: its zip member, view box, scale, grey levels, output and drops."""

    member: str
    box: PageBox
    scale: float
    levels: int
    out: Path
    drop: frozenset[int]


@dataclass(frozen=True)
class RenderedPage:
    """One page written to disk: its number, view box, size in pixels, bytes and sha256."""

    page: int
    box: PageBox
    width: int
    height: int
    points: tuple[float, float]
    bytes: int
    sha256: str


@dataclass(frozen=True)
class _Parts:
    """A page's objects by role."""

    frame: _Item
    above: list[_Item]
    below: list[_Item]
    beside: list[_Item]
    core: list[_Item]
    text: Bounds


def page_members(archive: zipfile.ZipFile, page_count: int) -> list[str]:
    """Return the zip members of pages 1..page_count in order; raise unless each is there once."""
    members = sorted(name for name in archive.namelist() if name.endswith(_AI_SUFFIX))
    numbers = [int(Path(name).name.removesuffix(_AI_SUFFIX)) for name in members]
    if numbers != list(range(1, page_count + 1)):
        message = f"expected pages 1..{page_count}, found {len(numbers)} page files"
        raise PageSourceError(message)
    return members


def _fill(obj: pdfium_c.FPDF_PAGEOBJECT) -> Fill:
    r, g, b, a = c_uint(), c_uint(), c_uint(), c_uint()
    if not pdfium_c.FPDFPageObj_GetFillColor(obj, r, g, b, a):
        return None
    return (r.value, g.value, b.value, a.value)


def _fills(obj: pdfium_c.FPDF_PAGEOBJECT) -> frozenset[Fill]:
    """Return the fills of `obj`'s leaves (a form's children, recursively)."""
    if pdfium_c.FPDFPageObj_GetType(obj) != _FORM:
        return frozenset({_fill(obj)})
    count = pdfium_c.FPDFFormObj_CountObjects(obj)
    return frozenset().union(
        *(_fills(pdfium_c.FPDFFormObj_GetObject(obj, i)) for i in range(count))
    )


def _bounds(obj: pdfium_c.FPDF_PAGEOBJECT) -> Bounds:
    left, bottom, right, top = c_float(), c_float(), c_float(), c_float()
    pdfium_c.FPDFPageObj_GetBounds(obj, left, bottom, right, top)
    return (left.value, bottom.value, right.value, top.value)


def _union(bounds: Sequence[Bounds]) -> Bounds:
    return (
        min(b[0] for b in bounds),
        min(b[1] for b in bounds),
        max(b[2] for b in bounds),
        max(b[3] for b in bounds),
    )


def _encloses(outer: Bounds, inner: Bounds) -> bool:
    return (
        outer[0] <= inner[0] + 0.5
        and outer[1] <= inner[1] + 0.5
        and outer[2] >= inner[2] - 0.5
        and outer[3] >= inner[3] - 0.5
    )


def _touch(a: Bounds, b: Bounds) -> bool:
    return a[0] <= b[2] + 1 and b[0] <= a[2] + 1 and a[1] <= b[3] + 1 and b[1] <= a[3] + 1


def _groups(bounds: list[Bounds]) -> list[list[int]]:
    """Return the indexes of `bounds` grouped where they touch, from the top of the page."""
    groups: list[list[int]] = [[i] for i in range(len(bounds))]
    merged = True
    while merged:
        merged = False
        for a in range(len(groups)):
            for b in range(a + 1, len(groups)):
                if any(_touch(bounds[i], bounds[j]) for i in groups[a] for j in groups[b]):
                    groups[a] += groups.pop(b)
                    merged = True
                    break
            if merged:
                break
    return sorted(groups, key=lambda g: -max(bounds[i][3] for i in g))


def _only(page: int, items: list[_Item], allowed: set[Fill], what: str) -> None:
    for item in items:
        if not item[2] <= allowed:
            message = f"page {page}: {what} is drawn in {sorted(map(str, item[2]))}"
            raise PageSourceError(message)


def _parts(page: int, source: pdfium.PdfPage) -> _Parts:
    """Return `source`'s objects by role: frame, above, below and beside it, and the rest."""
    raw_page = source.raw
    objects = [
        pdfium_c.FPDFPage_GetObject(raw_page, i)
        for i in range(pdfium_c.FPDFPage_CountObjects(raw_page))
    ]
    info: list[_Item] = [(obj, _bounds(obj), _fills(obj)) for obj in objects]

    def area(b: Bounds) -> float:
        return (b[2] - b[0]) * (b[3] - b[1])

    inked = [x for x in info if FRAME_FILL not in x[2]]
    if not inked:
        message = f"page {page}: no text object"
        raise PageSourceError(message)
    text = max(inked, key=lambda x: area(x[1]))[1]
    frames = [x for x in info if x[2] == {FRAME_FILL} and _encloses(x[1], text)]
    if len(frames) != 1:
        message = f"page {page}: {len(frames)} frame objects around the text"
        raise PageSourceError(message)
    frame = frames[0]
    left, bottom, right, top = frame[1]
    rest = [x for x in info if x is not frame]
    above = [x for x in rest if x[1][1] >= top - 0.01]
    below = [x for x in rest if x[1][3] <= bottom + 0.01]
    inside = [x for x in rest if all(x is not y for y in (*above, *below))]
    beside = [x for x in inside if x[1][2] <= left + 0.01 or x[1][0] >= right - 0.01]
    core = [x for x in inside if all(x is not y for y in beside)]
    _only(page, [*above, *below], {INK_FILL, WHITE_FILL}, "an object above or below the frame")
    _only(page, beside, {FRAME_FILL, INK_FILL, WHITE_FILL}, "a margin object")
    if any(x[1][0] < left - 0.5 or x[1][2] > right + 0.5 for x in core):
        message = f"page {page}: an object straddles the frame's side"
        raise PageSourceError(message)
    return _Parts(frame, above, below, beside, core, text)


def _classify(
    page: int, source: pdfium.PdfPage, drop: frozenset[int] = frozenset()
) -> tuple[list[pdfium_c.FPDF_PAGEOBJECT], PageSurvey]:
    """Return the objects to remove from `source` and the page's survey.

    Removed: the frame, the header, the page number and the margin ornaments numbered in `drop`
    (from the top of the page).
    """
    parts = _parts(page, source)
    groups = _groups([x[1] for x in parts.beside])
    if any(not any(parts.beside[i][2] == {FRAME_FILL} for i in g) for g in groups):
        message = f"page {page}: a margin ornament has no medallion shape"
        raise PageSourceError(message)
    if not drop <= set(range(len(groups))):
        message = f"page {page}: no margin ornament {sorted(drop)}"
        raise PageSourceError(message)
    dropped = [parts.beside[i] for n, g in enumerate(groups) if n in drop for i in g]
    removed = [parts.frame, *parts.above, *parts.below, *dropped]
    survey = PageSurvey(
        page=page,
        size=source.get_size(),
        frame=parts.frame[1],
        core=_union([x[1] for x in parts.core]),
        text=parts.text,
        removed_above=len(parts.above),
        removed_below=len(parts.below),
        ornaments=tuple(_union([parts.beside[i][1] for i in g]) for g in groups),
    )
    return [x[0] for x in removed], survey


def _open(zip_path: Path, member: str, page: int) -> pdfium.PdfDocument:
    with zipfile.ZipFile(zip_path) as archive:
        data = archive.read(member)
    document = pdfium.PdfDocument(data)
    if len(document) != 1:
        message = f"page {page}: {len(document)} PDF pages in one file"
        document.close()
        raise PageSourceError(message)
    return document


def survey_page(zip_path: Path, member: str, page: int) -> PageSurvey:
    """Classify `member` (page `page`) without rendering it."""
    document = _open(zip_path, member, page)
    try:
        return _classify(page, document[0])[1]
    finally:
        document.close()


def plan_box(survey: PageSurvey, margin: float, drop: frozenset[int] = frozenset()) -> PageBox:
    """Return the page's view box (§15 D123).

    The bounds of everything kept on the page (every letter, mark, verse marker, heading band,
    basmalah and the margin notes not in `drop`) with `margin` points of room on every side,
    inside the page.
    """
    width, height = survey.size
    notes = [b for n, b in enumerate(survey.ornaments) if n not in drop]
    kept = _union([survey.core, *notes])
    return PageBox(
        page=survey.page,
        left=max(0.0, kept[0] - margin),
        bottom=max(0.0, kept[1] - margin),
        right=min(width, kept[2] + margin),
        top=min(height, kept[3] + margin),
    )


def _render(source: pdfium.PdfPage, box: PageBox, scale: float) -> Image.Image:
    width, height = source.get_size()
    crop = (box.left, box.bottom, width - box.right, height - box.top)
    bitmap = source.render(scale=scale, crop=crop, fill_color=(255, 255, 255, 255))
    image: Image.Image = bitmap.to_pil()
    return image.convert("L")


def _strip(page: int, source: pdfium.PdfPage, job: RenderJob) -> list[Bounds]:
    """Remove the frame, header, page number and `job.drop` from `source`, checking the box.

    Return the bounds of the dropped margin ornaments: their own ink is meant to go.
    """
    box = job.box
    removed, survey = _classify(page, source, job.drop)
    notes = [b for n, b in enumerate(survey.ornaments) if n not in job.drop]
    outer = (box.left, box.bottom, box.right, box.top)
    if not all(_encloses(outer, b) for b in (survey.core, *notes)):
        message = f"page {page}: kept objects reach outside the view box"
        raise PageSourceError(message)
    for obj in removed:
        if not pdfium_c.FPDFPage_RemoveObject(source.raw, obj):
            message = f"page {page}: an object could not be removed"
            raise PageSourceError(message)
        pdfium_c.FPDFPageObj_Destroy(obj)
    if not pdfium_c.FPDFPage_GenerateContent(source.raw):
        message = f"page {page}: the page content could not be regenerated"
        raise PageSourceError(message)
    return [b for n, b in enumerate(survey.ornaments) if n in job.drop]


def _outside(image: Image.Image, job: RenderJob, areas: list[Bounds]) -> Image.Image:
    """Return a mask of `image` that is white except over `areas` (PDF points), 1 px wider."""
    mask = Image.new("L", image.size, 255)
    draw = ImageDraw.Draw(mask)
    box, scale = job.box, job.scale
    for left, bottom, right, top in areas:
        draw.rectangle(
            (
                (left - box.left) * scale - 1,
                (box.top - top) * scale - 1,
                (right - box.left) * scale + 1,
                (box.top - bottom) * scale + 1,
            ),
            fill=0,
        )
    return mask


def _rounding(levels: int) -> list[int]:
    """Return the lookup table that rounds 0..255 to `levels` evenly spaced grey levels."""
    step = 255 / (levels - 1)
    return [round(round(v / step) * step) for v in range(256)]


def render_page(zip_path: Path, job: RenderJob) -> RenderedPage:
    """Render `job`'s page without its frame, cut to its box, to `job.out`; verify it."""
    page = job.box.page
    document = _open(zip_path, job.member, page)
    try:
        source = document[0]
        points = source.get_size()
        original = _render(source, job.box, job.scale)
        dropped = _strip(page, source, job)
        image = _render(source, job.box, job.scale)
    finally:
        document.close()
    ink = ImageChops.multiply(
        original.point(lambda v: 255 if v < _INK_BELOW else 0), _outside(original, job, dropped)
    )
    changed = ImageChops.difference(original, image).point(lambda v: 255 if v else 0)
    if ImageChops.multiply(ink, changed).getbbox() is not None:
        message = f"page {page}: removing the frame changed ink inside the view box"
        raise PageSourceError(message)
    image = image.point(_rounding(job.levels))
    buffer = BytesIO()
    image.save(buffer, format="WEBP", lossless=True, quality=100, method=6, exact=True)
    encoded = buffer.getvalue()
    with Image.open(BytesIO(encoded)) as decoded:
        if ImageChops.difference(image, decoded.convert("L")).getbbox() is not None:
            message = f"page {page}: the WebP does not decode to the rendered pixels"
            raise PageSourceError(message)
    job.out.write_bytes(encoded)
    return RenderedPage(
        page, job.box, image.width, image.height, points, len(encoded), sha256_bytes(encoded)
    )


def _check_surveys(surveys: list[PageSurvey]) -> None:
    for s in surveys:
        removed = (s.removed_above, s.removed_below)
        if s.page <= OPENING_PAGES and removed != (0, 0):
            message = f"page {s.page}: the opening pages have no header or page number"
            raise PageSourceError(message)
        if s.page > OPENING_PAGES and min(removed) < 1:
            message = f"page {s.page}: expected a running header and a page number"
            raise PageSourceError(message)
    if len({s.size for s in surveys}) != 1:
        message = "pages differ in size"
        raise PageSourceError(message)


def render_pages(
    zip_path: Path,
    pin: PackagePin,
    *,
    out_dir: Path,
    workers: int,
    medallions: Callable[[list[PageSurvey]], dict[int, frozenset[int]]],
) -> list[RenderedPage]:
    """Survey every page, plan the boxes and render into `out_dir/NNN.webp`.

    `medallions` names the margin ornaments of each page to drop. Return the pages in order.
    """
    with zipfile.ZipFile(zip_path) as archive:
        members = page_members(archive, pin.page_count)
    out_dir.mkdir(parents=True, exist_ok=True)
    pages = range(1, pin.page_count + 1)
    with ProcessPoolExecutor(max_workers=workers) as pool:
        surveys = list(pool.map(survey_page, [zip_path] * pin.page_count, members, pages))
        _check_surveys(surveys)
        drops = medallions(surveys)
        jobs = []
        for member, s in zip(members, surveys, strict=True):
            drop = drops.get(s.page, frozenset())
            box = plan_box(s, pin.box_margin, drop)
            scale = pin.box_width / (box.right - box.left)
            out = out_dir / f"{s.page:03}.webp"
            jobs.append(RenderJob(member, box, scale, pin.grey_levels, out, drop))
        return list(pool.map(render_page, [zip_path] * len(jobs), jobs))


def boxes_json(pages: Sequence[RenderedPage]) -> bytes:
    """Return `pages/boxes.json` (`quran_page_boxes.v1`).

    Each page's view box as fractions of its page (left and top from the page's top-left
    corner, as the reader measures) and its pixel size. Bookmarks, highlights and line positions
    stay in whole-page fractions, so they keep their place whatever the box.
    """
    width, height = pages[0].points
    document = {
        "schemaVersion": 1,
        "pages": [
            {
                "page": p.page,
                "left": round(p.box.left / width, 6),
                "top": round((height - p.box.top) / height, 6),
                "right": round(p.box.right / width, 6),
                "bottom": round((height - p.box.bottom) / height, 6),
                "width": p.width,
                "height": p.height,
            }
            for p in pages
        ],
    }
    return (json.dumps(document, separators=(",", ":")) + "\n").encode()
