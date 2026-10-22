"""The polygon pipelines: config, encoder, oracle, committed outputs, CLI (§9.5, §15 D70-D71)."""

import json
import math
import os
import struct
from collections.abc import Sequence
from pathlib import Path

import pytest
import shapely

from dm_pipelines.cli import run
from dm_pipelines.hashing import sha256_file
from dm_pipelines.polygons.config import Dataset, OracleSettings, SourcePin, load_polygons_config
from dm_pipelines.polygons.encode import CELLS, cell_of, encode_index
from dm_pipelines.polygons.oracle import SourceIndex, answer
from dm_pipelines.polygons.pipeline import CONFIG, BuildPolygons, default_out, payload_name
from dm_pipelines.polygons.source import NamedPolygon, read_source
from dm_pipelines.schema.pipeline_manifest_v1 import PipelineManifestV1
from dm_pipelines.schema.polygon_lookup_oracle_v1 import PolygonLookupOracleV1
from dm_pipelines.tzdata.source import SourceMismatchError

REPO = Path(__file__).resolve().parents[2]
SETTINGS = OracleSettings(
    seed=1, points_per_sample=1, earth_radius_m=6371008.8, distance_limit_m=50000.0
)
_HEADER = 4 + 2 + 4
DATASETS: list[Dataset] = ["tz", "country"]


def _box(name: str, x0: float, y0: float, x1: float, y1: float) -> NamedPolygon:
    return NamedPolygon(name, shapely.box(x0, y0, x1, y1))


def _grid(payload: bytes, names_end: int) -> tuple[int, list[int], int]:
    """Return polygon count, the 64 801 offsets and where the polygons start."""
    (count,) = struct.unpack_from("<I", payload, names_end)
    offsets = list(struct.unpack_from(f"<{CELLS + 1}I", payload, names_end + 4))
    return count, offsets, names_end + 4 + 4 * (CELLS + 1) + 4 * offsets[-1]


def test_the_payload_follows_the_ksy_layout_with_absolute_ring_starts() -> None:
    encoded = encode_index([_box("A/B", 10.0, 10.0, 11.5, 11.0)], magic=b"TZPG", tolerance=0.001)
    payload = encoded.payload
    assert payload[:4] == b"TZPG"
    assert struct.unpack_from("<HI", payload, 4) == (1, 1)
    assert payload[_HEADER : _HEADER + 4] == b"\x03A/B"
    count, offsets, polygons = _grid(payload, _HEADER + 4)
    assert count == 1
    assert offsets[0] == 0
    assert offsets[-1] == 4  # two columns x two rows (the top edge touches row 11)
    assert (
        offsets[cell_of(10_500_000, 10_500_000) + 1] - offsets[cell_of(10_500_000, 10_500_000)] == 1
    )
    name, *bbox, rings = struct.unpack_from("<IiiiiH", payload, polygons)
    assert (name, bbox, rings) == (0, [10_000_000, 10_000_000, 11_500_000, 11_000_000], 1)
    (points,) = struct.unpack_from("<I", payload, polygons + 22)
    deltas = struct.unpack_from(f"<{2 * points}i", payload, polygons + 26)
    xs = [sum(deltas[0 : 2 * i + 1 : 2]) for i in range(points)]
    assert points == 5
    assert min(xs) == 10_000_000
    assert max(xs) == 11_500_000
    assert len(payload) == polygons + 26 + 8 * points


def test_encoding_is_deterministic_and_sorts_names() -> None:
    polygons = [_box("Z/Z", 0.0, 0.0, 1.0, 1.0), _box("A/A", 2.0, 2.0, 3.0, 3.0)]
    polygons.sort(key=lambda item: item.name)
    first = encode_index(polygons, magic=b"TZPG", tolerance=0.001)
    second = encode_index(polygons, magic=b"TZPG", tolerance=0.001)
    assert first == second
    assert first.names == ["A/A", "Z/Z"]


def test_a_polygon_simplified_below_three_points_is_left_out() -> None:
    sliver = NamedPolygon("A/A", shapely.Polygon([(0, 0), (1e-7, 0), (0, 1e-7)]))
    assert encode_index([sliver], magic=b"TZPG", tolerance=0.001).polygons == 0


def test_req_time_001_the_oracle_answers_inside_near_and_across_the_antimeridian() -> None:
    index = SourceIndex.of(
        [_box("A/East", 179.0, 10.0, 180.0, 11.0), _box("A/West", -180.0, 10.0, -179.0, 11.0)]
    )
    inside = answer(index, 179_900_000, 10_500_000, SETTINGS)
    assert inside.containing == "A/East"
    assert inside.nearest is None
    k = SETTINGS.earth_radius_m * math.pi / 180
    assert inside.other_distance_m == pytest.approx(0.1 * math.cos(math.radians(10.5)) * k, abs=0.1)
    sea = answer(index, -178_950_000, 10_500_000, SETTINGS)
    assert sea.containing is None
    assert sea.nearest == "A/West"
    assert sea.nearest_distance_m == pytest.approx(0.05 * math.cos(math.radians(10.5)) * k, abs=0.1)
    assert sea.other_distance_m is None  # A/East is 1.05° away, beyond 50 km
    far = answer(index, 0, 0, SETTINGS)
    assert (far.containing, far.nearest, far.other_distance_m) == (None, None, None)


def test_the_source_must_match_its_pin(tmp_path: Path) -> None:
    pin = load_polygons_config(REPO / CONFIG).country
    path = tmp_path / "x.geojson"
    path.write_text('{"features": []}', encoding="utf-8")
    with pytest.raises(SourceMismatchError, match="pinned"):
        read_source(path, pin, iso2=True)


def test_features_without_an_iso_code_are_left_out_and_names_sort(tmp_path: Path) -> None:
    def feature(code: str, x: float) -> dict[str, object]:
        return {
            "properties": {"ISO_A2_EH": code},
            "geometry": {"type": "Polygon", "coordinates": [[[x, 0], [x + 1, 0], [x, 1], [x, 0]]]},
        }

    path = tmp_path / "x.geojson"
    path.write_text(
        json.dumps({"features": [feature("NO", 0), feature("-99", 2), feature("EG", 4)]}),
        encoding="utf-8",
    )
    pin = SourcePin(
        version="1",
        url="https://example.invalid/x",
        sha256=sha256_file(path),
        zip_member="",
        name_property="ISO_A2_EH",
        license="test",
    )
    assert [item.name for item in read_source(path, pin, iso2=True)] == ["EG", "NO"]


@pytest.mark.parametrize("dataset", DATASETS)
def test_req_dist_003_the_committed_outputs_match_their_manifest(dataset: Dataset) -> None:
    config = load_polygons_config(REPO / CONFIG)
    out = default_out(REPO, dataset, config)
    manifest = PipelineManifestV1.model_validate_json((out / "manifest.json").read_text("utf-8"))
    for output in manifest.outputs:
        assert sha256_file(out / output.path) == output.sha256
    assert manifest.inputs[0].sha256 == config.source(dataset).sha256
    for item in manifest.inputs[1:]:
        assert item.path is not None
        assert sha256_file(REPO / item.path) == item.sha256, item.path
    oracle = PolygonLookupOracleV1.model_validate_json(
        (out / "lookup_oracle.json").read_text("utf-8")
    )
    assert [len(sample.points) for sample in oracle.samples] == [1000, 1000]


@pytest.mark.skipif(
    "DM_POLYGON_SOURCES" not in os.environ,
    reason="set DM_POLYGON_SOURCES to a directory holding both pinned sources",
)
@pytest.mark.parametrize("dataset", DATASETS)
def test_req_dist_003_a_rebuild_is_byte_identical(dataset: Dataset, tmp_path: Path) -> None:
    config = load_polygons_config(REPO / CONFIG)
    kind = dataset
    source = Path(os.environ["DM_POLYGON_SOURCES"]) / config.source(kind).url.rsplit("/", 1)[1]
    BuildPolygons(repo=REPO).run(kind, source, tmp_path)
    committed = default_out(REPO, kind, config)
    for name in (payload_name(kind), "lookup_oracle.json", "manifest.json"):
        assert (tmp_path / name).read_bytes() == (committed / name).read_bytes(), name


class WritingRunner:
    """Fake `CommandRunner` port: `curl -o FILE` writes fixed bytes instead of downloading."""

    def __init__(self, body: bytes) -> None:
        """Answer every download with `body`."""
        self.body = body
        self.calls: list[list[str]] = []

    def run(self, args: Sequence[str], cwd: Path) -> None:
        """Record the call and write the file `-o` names."""
        self.calls.append(list(args))
        (cwd / args[args.index("-o") + 1]).write_bytes(self.body)


def test_fetch_refuses_and_removes_bytes_that_do_not_match_the_pin(tmp_path: Path) -> None:
    dest = tmp_path / "countries.geojson"
    runner = WritingRunner(b"not the pinned file")
    code = run(
        ["--repo", str(REPO), "polygons", "fetch", "--dataset", "country", "--dest", str(dest)],
        runner,
    )
    assert code == 1
    assert not dest.exists()
    assert runner.calls[0][:2] == ["curl", "-fsSL"]


def test_an_unknown_dataset_is_a_usage_error(tmp_path: Path) -> None:
    args = ["polygons", "build", "--dataset", "admin1", "--source", str(tmp_path)]
    assert run(args, WritingRunner(b"")) == 2
