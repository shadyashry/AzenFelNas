#!/usr/bin/env bash
# Validates every schema and its fixtures with ajv-cli (DESIGN.md §12, ADR-023):
#   schemas/fixtures/<name>/valid/*.json   must validate against schemas/<name>.v1.schema.json
#   schemas/fixtures/<name>/invalid/*.json must NOT validate (one mutation each; name cites the REQ it guards)
# Usage: schemas/tools/validate_fixtures.sh [ajv command]   (default: npx --yes ajv-cli@5.0.0 with ajv-formats@3.0.1)
set -euo pipefail
cd "$(dirname "$0")/.."
AJV=${AJV:-"npx --yes --package=ajv-cli@5.0.0 --package=ajv-formats@3.0.1 ajv"}
# Strict schema keywords; strictTypes/strictRequired are off because conditional sub-schemas (if/then, allOf)
# legitimately omit "type" and re-reference properties defined at the parent, and Appendix A is normative as written.
OPTS=(--spec=draft2020 --strict=true --strict-types=false --strict-required=false --allow-union-types -c ajv-formats --all-errors)
shopt -s nullglob
status=0
for schema in *.schema.json; do
  name=${schema%.v1.schema.json}
  dir=fixtures/$name
  valid=("$dir"/valid/*.json)
  invalid=("$dir"/invalid/*.json)
  if [ ${#valid[@]} -eq 0 ]; then
    echo "FAIL $schema: no valid fixtures in $dir/valid"; status=1; continue
  fi
  $AJV compile "${OPTS[@]}" -s "$schema" >/dev/null || { echo "FAIL $schema: does not compile"; status=1; continue; }
  for f in "${valid[@]}"; do
    if $AJV validate "${OPTS[@]}" -s "$schema" -d "$f" >/dev/null 2>&1; then echo "ok   valid   $f"
    else echo "FAIL valid   $f"; $AJV validate "${OPTS[@]}" -s "$schema" -d "$f" || true; status=1; fi
  done
  for f in "${invalid[@]}"; do
    if $AJV validate "${OPTS[@]}" -s "$schema" -d "$f" >/dev/null 2>&1; then echo "FAIL invalid $f (was accepted)"; status=1
    else echo "ok   invalid $f"; fi
  done
done
exit $status
