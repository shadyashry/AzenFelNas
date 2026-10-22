"""Reads a pinned GeoJSON source into named shapely geometries (§9.5, §15 D70)."""

import json
import re
import zipfile
from dataclasses import dataclass
from pathlib import Path

import shapely
from shapely.geometry import shape

from dm_pipelines.hashing import sha256_file
from dm_pipelines.polygons.config import SourcePin
from dm_pipelines.tzdata.source import SourceMismatchError

_ISO2 = re.compile(r"^[A-Z]{2}$")
_ZONE = re.compile(r"^[A-Za-z0-9_+-]+(/[A-Za-z0-9_+-]+)*$")


@dataclass(frozen=True)
class NamedPolygon:
    """One polygon of the source with the zone id or ISO 3166-1 alpha-2 code it belongs to."""

    name: str
    polygon: shapely.Polygon


def read_source(path: Path, pin: SourcePin, *, iso2: bool) -> list[NamedPolygon]:
    """Verify `path` against `pin` and return its polygons sorted by name, then source order.

    Features whose name is not a zone id (or, with `iso2`, a two-letter code) are left out; each
    MultiPolygon becomes its polygons. Invalid geometry is repaired with `shapely.make_valid`.
    """
    if (actual := sha256_file(path)) != pin.sha256:
        message = f"{path.name}: sha256 {actual}, pinned {pin.sha256}"
        raise SourceMismatchError(message)
    if pin.zip_member:
        with zipfile.ZipFile(path) as archive:
            document = json.loads(archive.read(pin.zip_member))
    else:
        document = json.loads(path.read_bytes())
    pattern = _ISO2 if iso2 else _ZONE
    polygons: list[NamedPolygon] = []
    for feature in document["features"]:
        name = feature["properties"].get(pin.name_property)
        if not isinstance(name, str) or pattern.fullmatch(name) is None:
            continue
        geometry = shapely.make_valid(shape(feature["geometry"]))
        polygons.extend(NamedPolygon(name, part) for part in _polygons(geometry))
    polygons.sort(key=lambda item: item.name)  # stable: source order within a name
    return polygons


def _polygons(geometry: shapely.Geometry) -> list[shapely.Polygon]:
    match geometry:
        case shapely.Polygon():
            return [] if geometry.is_empty else [geometry]
        case shapely.MultiPolygon() | shapely.GeometryCollection():
            return [part for item in geometry.geoms for part in _polygons(item)]
        case _:
            return []  # lines and points left over by make_valid have no area
