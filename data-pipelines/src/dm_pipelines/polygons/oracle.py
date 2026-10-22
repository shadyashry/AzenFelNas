"""The polygon lookup oracle: seeded points answered by shapely on the source (§13 S11, §15 D71).

Distances use the local equirectangular projection of §15 D71 around the query point P:
`k = R·π/180` metres per degree, `c = max(cos lat_P, cos 89°)`,
`x = wrap(lon − lon_P)·c·k`, `y = (lat − lat_P)·k`. Everything within `L` metres of P lies in the
box `|x|, |y| ≤ L`, so each candidate polygon is clipped to that box (in up to three copies shifted
by 0 and ±360° for the antimeridian) before shapely measures its distance to the origin.
"""

import math
import random
from dataclasses import dataclass

import numpy as np
import shapely

from dm_pipelines.polygons.config import OracleSettings
from dm_pipelines.polygons.encode import E6
from dm_pipelines.polygons.source import NamedPolygon
from dm_pipelines.schema.polygon_lookup_oracle_v1 import Point, Sample

_MIN_COS = math.cos(math.radians(89.0))
_SHIFTS = (0.0, 360.0, -360.0)
_DECIMETRE = 1


@dataclass(frozen=True)
class SourceIndex:
    """The source polygons with an STR tree over them."""

    polygons: list[NamedPolygon]
    tree: shapely.STRtree

    @classmethod
    def of(cls, polygons: list[NamedPolygon]) -> SourceIndex:
        """Index `polygons` (payload order)."""
        return cls(polygons, shapely.STRtree([item.polygon for item in polygons]))


def answer(index: SourceIndex, lon_e6: int, lat_e6: int, settings: OracleSettings) -> Point:
    """Return what shapely says about the point (`lon_e6`, `lat_e6`)."""
    lon, lat = lon_e6 / E6, lat_e6 / E6
    inside = sorted(index.tree.query(shapely.Point(lon, lat), predicate="within").tolist())
    containing = index.polygons[inside[0]].name if inside else None
    distances = _distances(index, lon, lat, settings)
    nearest: str | None = None
    nearest_m: float | None = None
    if containing is None and distances:
        polygon_id = min(distances, key=lambda i: (distances[i], i))
        nearest, nearest_m = index.polygons[polygon_id].name, distances[polygon_id]
    reference = containing or nearest
    others = [m for i, m in distances.items() if index.polygons[i].name != reference]
    return Point(
        lon_e6=lon_e6,
        lat_e6=lat_e6,
        containing=containing,
        nearest=nearest,
        nearest_distance_m=_rounded(nearest_m),
        other_distance_m=_rounded(min(others)) if reference is not None and others else None,
    )


def build_samples(index: SourceIndex, settings: OracleSettings) -> list[Sample]:
    """Return the `sphere` and `land` samples, `settings.points_per_sample` points each."""
    rng = random.Random(settings.seed)  # noqa: S311 - a reproducible sample, not a secret
    sphere = [
        answer(index, *_random_point(rng), settings) for _ in range(settings.points_per_sample)
    ]
    land: list[Point] = []
    while len(land) < settings.points_per_sample:
        point = answer(index, *_random_point(rng), settings)
        if point.containing is not None:
            land.append(point)
    return [Sample(name="sphere", points=sphere), Sample(name="land", points=land)]


def _random_point(rng: random.Random) -> tuple[int, int]:
    """Uniform on the sphere, rounded to micro-degrees."""
    lon = rng.uniform(-180.0, 180.0)
    lat = math.degrees(math.asin(rng.uniform(-1.0, 1.0)))
    return round(lon * E6), round(lat * E6)


def _distances(
    index: SourceIndex, lon: float, lat: float, settings: OracleSettings
) -> dict[int, float]:
    """Projected distance in metres of every source polygon within the limit, by polygon id."""
    k = settings.earth_radius_m * math.pi / 180.0
    c = max(math.cos(math.radians(lat)), _MIN_COS)
    limit = settings.distance_limit_m
    d_lat, d_lon = limit / k, min(limit / (c * k), 180.0)
    origin = shapely.Point(0.0, 0.0)
    found: dict[int, float] = {}
    for shift in _SHIFTS:
        box = shapely.box(lon - d_lon - shift, lat - d_lat, lon + d_lon - shift, lat + d_lat)
        for polygon_id in index.tree.query(box).tolist():
            clipped = shapely.intersection(index.polygons[polygon_id].polygon, box)
            if clipped.is_empty:
                continue

            def project(xy: np.ndarray, shift: float = shift) -> np.ndarray:
                return np.column_stack(((xy[:, 0] + shift - lon) * c * k, (xy[:, 1] - lat) * k))

            metres = float(shapely.distance(shapely.transform(clipped, project), origin))
            if metres <= limit and metres < found.get(polygon_id, math.inf):
                found[polygon_id] = metres
    return found


def _rounded(metres: float | None) -> float | None:
    return None if metres is None else round(metres, _DECIMETRE)
