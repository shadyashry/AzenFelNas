"""The generated wire models round-trip the schema fixtures (ADR-023, DESIGN.md §17.6)."""

import json
from pathlib import Path

import pytest
from pydantic import BaseModel, ValidationError

from dm_pipelines.schema.gazetteer_package_v1 import GazetteerPackagePayloadV1
from dm_pipelines.schema.pipeline_manifest_v1 import PipelineManifestV1
from dm_pipelines.schema.polygon_lookup_oracle_v1 import PolygonLookupOracleV1
from dm_pipelines.schema.tz_transition_oracle_v1 import TzTransitionOracleV1

FIXTURES = Path(__file__).resolve().parents[2] / "schemas" / "fixtures"
MODELS: dict[str, type[BaseModel]] = {
    "pipeline_manifest": PipelineManifestV1,
    "tz_transition_oracle": TzTransitionOracleV1,
    "polygon_lookup_oracle": PolygonLookupOracleV1,
    "gazetteer_package": GazetteerPackagePayloadV1,
}
# Schemas whose required members may be null: the dump keeps the nulls.
NULLABLE = {"polygon_lookup_oracle"}
CASES = [(name, path) for name in MODELS for path in sorted((FIXTURES / name).glob("*/*.json"))]


@pytest.mark.parametrize(
    ("schema", "path"), CASES, ids=[f"{n}/{p.parent.name}/{p.name}" for n, p in CASES]
)
def test_valid_fixtures_round_trip_and_invalid_ones_are_refused(schema: str, path: Path) -> None:
    text = path.read_text(encoding="utf-8")
    model = MODELS[schema]
    if path.parent.name == "valid":
        decoded = model.model_validate_json(text)
        dumped = decoded.model_dump_json(exclude_none=schema not in NULLABLE)
        assert json.loads(dumped) == json.loads(text)
    else:
        with pytest.raises(ValidationError):
            model.model_validate_json(text)
