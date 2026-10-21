#!/usr/bin/env bash
# Generates the pydantic v2 models of lab/src/dm_lab/schema/ from schemas/ (ADR-023, DESIGN.md §17.6).
# The output is committed; ci-lab re-runs this script and fails when the tree changes.
# datamodel-code-generator runs as an isolated uvx tool on Python 3.14: its pyyaml dependency has no
# CPython 3.15 Windows wheel yet (DESIGN.md §15 D27). The generated code targets Python 3.15.
set -euo pipefail
cd "$(dirname "$0")/.."
GEN_VERSION=0.86.0
OUT=src/dm_lab/schema
SCHEMAS=(
  benchmark_cities
  bench_request
  bench_failure
  calculation_trace
  lab_reference
  discrepancy_report
  pipeline_manifest
)
for name in "${SCHEMAS[@]}"; do
  uvx --python 3.14 --from "datamodel-code-generator==${GEN_VERSION}" datamodel-codegen \
    --input "../schemas/${name}.v1.schema.json" \
    --input-file-type jsonschema \
    --output "${OUT}/${name}_v1.py" \
    --output-model-type pydantic_v2.BaseModel \
    --base-class dm_lab.schema.base.WireModel \
    --target-python-version 3.15 \
    --formatters builtin \
    --custom-file-header "# Generated from schemas/${name}.v1.schema.json by datamodel-code-generator ${GEN_VERSION}.
# Do not edit: run lab/scripts/gen_models.sh (ADR-023, DESIGN.md §17.6)." \
    --use-annotated \
    --field-constraints \
    --type-mappings "string+date=string" \
    --strict-types str int bool \
    --enum-field-as-literal all \
    --use-standard-collections \
    --use-union-operator \
    --snake-case-field \
    --extra-fields forbid \
    --use-double-quotes \
    --use-schema-description \
    --use-field-description \
    --collapse-root-models \
    --infer-union-variant-names \
    2> >(grep -v -E "Warning|warn_deprecated|_warn_naming_hint" >&2)
done
uv run --frozen ruff format --quiet "${OUT}"/*_v1.py
