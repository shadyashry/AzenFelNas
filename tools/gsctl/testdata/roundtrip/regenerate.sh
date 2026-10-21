#!/usr/bin/env bash
# Regenerates the Go -> Dart round-trip vector (DESIGN.md §13 S09, §15 D62):
# gsctl builds the seed profiles into a dev channel and signs every role with
# the dev keys; dm_packages' tests verify it in Dart and gsctl's tests in Go.
#
# Run from the repository root. The dev private keys come from
# GSCTL_KEY_DIR (a directory of <name>.pem, e.g. tools/gsctl/keys/dev/private)
# or from the DM_DEV_<ROLE>_KEY_<N> variables. Nothing private is written here.
set -euo pipefail

out=tools/gsctl/testdata/roundtrip/dev
keys=()
if [[ -n "${GSCTL_KEY_DIR:-}" ]]; then keys=(-key-dir "$GSCTL_KEY_DIR"); fi

rm -rf "$out"
go build -o "${TMPDIR:-/tmp}/gsctl-roundtrip" ./tools/gsctl
gsctl="${TMPDIR:-/tmp}/gsctl-roundtrip"
"$gsctl" build -channel dev -repo "$out" -version 2026.10.1 -effective-from 2026-11-01 \
  -note-ar "ملفات مواقيت أولية للتطوير، غير معتمدة" -note-en "Seed prayer profiles for development, not approved"
for role in root targets snapshot timestamp; do
  "$gsctl" sign -repo "$out" -role "$role" "${keys[@]}"
done
"$gsctl" verify -repo "$out"
rm -f "$gsctl"
