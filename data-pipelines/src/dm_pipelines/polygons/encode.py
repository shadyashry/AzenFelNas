"""Encodes named polygons as a `tz_polygons` / `country_polygons` payload (§9.5, §15 D23, D70).

Layout: `schemas/tz_polygons.v1.ksy`. Each polygon is simplified on its own (Douglas-Peucker,
topology preserved), rounded to integer micro-degrees, and listed in every 1-degree grid cell its
rounded shape intersects (closed cells, so a polygon touching a cell edge is in both cells).
Polygon order is name order, then source order; ids in a cell ascend. Deterministic.
"""

import math
import struct
from dataclasses import dataclass

import numpy as np
import shapely

from dm_pipelines.polygons.source import NamedPolygon

VERSION = 1
COLUMNS = 360
ROWS = 180
CELLS = COLUMNS * ROWS
E6 = 1_000_000
_MIN_RING_POINTS = 4  # closed: three distinct points and the first again

type Ring = list[tuple[int, int]]


@dataclass(frozen=True)
class EncodedPolygon:
    """A simplified, rounded polygon: ring 0 outer, then holes; points in micro-degrees."""

    name_index: int
    rings: list[Ring]


@dataclass(frozen=True)
class EncodedIndex:
    """The payload bytes and what they hold."""

    payload: bytes
    names: list[str]
    polygons: int
    points: int


def encode_index(polygons: list[NamedPolygon], *, magic: bytes, tolerance: float) -> EncodedIndex:
    """Simplify, round, index and serialise `polygons` (already in payload order)."""
    names = sorted({item.name for item in polygons})
    name_index = {name: i for i, name in enumerate(names)}
    encoded = [
        EncodedPolygon(name_index[item.name], rings)
        for item in polygons
        for rings in _simplified(item.polygon, tolerance)
    ]
    cells: list[list[int]] = [[] for _ in range(CELLS)]
    for polygon_id, polygon in enumerate(encoded):
        for cell in _cells(polygon.rings):
            cells[cell].append(polygon_id)
    out = bytearray(magic)
    out += struct.pack("<HI", VERSION, len(names))
    for name in names:
        raw = name.encode()
        out += struct.pack("<B", len(raw)) + raw
    out += struct.pack("<I", len(encoded))
    offsets = [0]
    for ids in cells:
        offsets.append(offsets[-1] + len(ids))
    out += struct.pack(f"<{len(offsets)}I", *offsets)
    flat = [polygon_id for ids in cells for polygon_id in ids]
    out += struct.pack(f"<{len(flat)}I", *flat)
    points = 0
    for polygon in encoded:
        out += _polygon_bytes(polygon)
        points += sum(len(ring) for ring in polygon.rings)
    return EncodedIndex(bytes(out), names, len(encoded), points)


def cell_of(lon_e6: int, lat_e6: int) -> int:
    """Return the grid cell of a point (lat 90 in row 179, lon 180 in column 359), as in the ksy."""
    row = min(math.floor(lat_e6 / E6) + 90, ROWS - 1)
    column = min(math.floor(lon_e6 / E6) + 180, COLUMNS - 1)
    return row * COLUMNS + column


def _simplified(polygon: shapely.Polygon, tolerance: float) -> list[list[Ring]]:
    result: list[list[Ring]] = []
    simplified = polygon.simplify(tolerance, preserve_topology=True)
    parts = simplified.geoms if isinstance(simplified, shapely.MultiPolygon) else [simplified]
    for part in parts:
        if not isinstance(part, shapely.Polygon) or part.is_empty:
            continue
        outer = _rounded(part.exterior.coords)
        if outer is None:
            continue
        holes = [ring for hole in part.interiors if (ring := _rounded(hole.coords)) is not None]
        result.append([outer, *holes])
    return result


def _rounded(coords: shapely.coords.CoordinateSequence) -> Ring | None:
    ring: Ring = []
    for x, y in coords:
        point = (
            min(max(round(x * E6), -180 * E6), 180 * E6),
            min(max(round(y * E6), -90 * E6), 90 * E6),
        )
        if not ring or ring[-1] != point:
            ring.append(point)
    if ring and ring[0] != ring[-1]:
        ring.append(ring[0])
    return ring if len(ring) >= _MIN_RING_POINTS else None


def _cells(rings: list[Ring]) -> list[int]:
    outer = np.array(rings[0], dtype=np.float64) / E6
    holes = [np.array(ring, dtype=np.float64) / E6 for ring in rings[1:]]
    shape = shapely.make_valid(shapely.Polygon(outer, holes))
    min_lon, min_lat = outer.min(axis=0)
    max_lon, max_lat = outer.max(axis=0)
    rows = range(max(math.floor(min_lat), -90), min(math.floor(max_lat), 89) + 1)
    columns = range(max(math.floor(min_lon), -180), min(math.floor(max_lon), 179) + 1)
    lons = np.array([c for _ in rows for c in columns], dtype=np.float64)
    lats = np.array([r for r in rows for _ in columns], dtype=np.float64)
    shapely.prepare(shape)
    hits = shapely.intersects(shape, shapely.box(lons, lats, lons + 1, lats + 1))
    return [
        (int(lat) + 90) * COLUMNS + int(lon) + 180
        for lon, lat, hit in zip(lons, lats, hits, strict=True)
        if hit
    ]


def _polygon_bytes(polygon: EncodedPolygon) -> bytes:
    lons = [x for ring in polygon.rings for x, _ in ring]
    lats = [y for ring in polygon.rings for _, y in ring]
    out = bytearray(
        struct.pack(
            "<IiiiiH",
            polygon.name_index,
            min(lons),
            min(lats),
            max(lons),
            max(lats),
            len(polygon.rings),
        )
    )
    for ring in polygon.rings:
        previous = (0, 0)  # the first point of every ring is absolute (ksy `ring`)
        deltas: list[int] = []
        for point in ring:
            deltas += (point[0] - previous[0], point[1] - previous[1])
            previous = point
        out += struct.pack(f"<I{len(deltas)}i", len(ring), *deltas)
    return bytes(out)
