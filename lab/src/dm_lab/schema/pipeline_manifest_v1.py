# Generated from schemas/pipeline_manifest.v1.schema.json by datamodel-code-generator 0.86.0.
# Do not edit: run lab/scripts/gen_models.sh (ADR-023, DESIGN.md §17.6).

from typing import Annotated, Literal

from dm_lab.schema.base import WireModel
from pydantic import ConfigDict, Field, StrictInt, StrictStr
from typing_extensions import TypeAliasType

ToolsAdditionalProperty = TypeAliasType(
    "ToolsAdditionalProperty", Annotated[StrictStr, Field(min_length=1)]
)


class Input(WireModel):
    model_config = ConfigDict(
        extra="forbid",
    )
    role: Annotated[StrictStr, Field(pattern="^[a-z][a-z0-9_]*$")]
    path: Annotated[StrictStr | None, Field(pattern="^[A-Za-z0-9_.-]+(/[A-Za-z0-9_.-]+)*$")] = None
    """
    Relative to the repository root.
    """
    url: Annotated[StrictStr | None, Field(pattern="^https://")] = None
    sha256: Annotated[StrictStr, Field(pattern="^[a-f0-9]{64}$")]


class Output(WireModel):
    model_config = ConfigDict(
        extra="forbid",
    )
    path: Annotated[StrictStr, Field(pattern="^[A-Za-z0-9_.-]+(/[A-Za-z0-9_.-]+)*$")]
    """
    Relative to the directory of the manifest.
    """
    sha256: Annotated[StrictStr, Field(pattern="^[a-f0-9]{64}$")]
    records: Annotated[StrictInt, Field(ge=0)]


class PipelineManifestV1(WireModel):
    """
    Output manifest of a deterministic Python pipeline in lab/ or data-pipelines/ (DESIGN.md §17.6): the pinned inputs by sha256, the tool versions and the outputs by sha256. Re-running the pipeline with the same inputs reproduces the outputs byte for byte. No timestamps, so the manifest is reproducible too.
    """

    model_config = ConfigDict(
        extra="forbid",
    )
    schema_version: Annotated[Literal[1], Field(alias="schemaVersion")]
    pipeline: Annotated[StrictStr, Field(pattern="^[a-z][a-z0-9_.-]*$")]
    """
    Pipeline name, e.g. lab.reference.
    """
    inputs: Annotated[list[Input], Field(min_length=1)]
    tools: Annotated[dict[str, ToolsAdditionalProperty], Field(min_length=1)]
    """
    Name → exact version of every tool or library that affects the outputs.
    """
    parameters: dict[str, StrictStr]
    """
    Name → value of every non-file input (e.g. the year range).
    """
    outputs: Annotated[list[Output], Field(min_length=1)]
