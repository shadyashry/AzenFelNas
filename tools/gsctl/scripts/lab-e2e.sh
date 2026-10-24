#!/usr/bin/env bash
# S25 done-test: "the app syncs from lab end to end" (DESIGN.md §13, §15 D85), with ephemeral keys.
#   1. generate a throw-away key set (never the dev keys, which this script cannot read);
#   2. release 1 to lab: build, sign every role, verify, publish to the bucket;
#   3. release 2 on a fresh runner: pull lab from the bucket, build, sign, verify, publish (sequences continue);
#   The releases are built from a work copy of profiles/ whose compatibility.minAppVersion is the app's
#   pubspec version: the committed seeds say "1.0.0" and a 0.1.0 app correctly refuses them as
#   PKG_INCOMPATIBLE (REQ-PKG-006; open item in §15 D85). Nothing religious is changed.
#   4. serve the bucket with `gsctl serve` (the CDN stand-in) and run the app's sync against it
#      (apps/mobile/test/features/packages/lab_sync_end_to_end_test.dart).
#
# Run from the repository root:
#   tools/gsctl/scripts/lab-e2e.sh                       # a local bucket directory
#   GSCTL_E2E_BUCKET=s3://<bucket> DM_S3_ENDPOINT=127.0.0.1:8333 DM_S3_ACCESS_KEY_ID=... \
#     DM_S3_SECRET_ACCESS_KEY=... DM_S3_INSECURE=1 tools/gsctl/scripts/lab-e2e.sh   # an S3 test server
# The S3 bucket must exist and be empty of lab/. Needs go, openssl and flutter on PATH.
set -euo pipefail

work="$(mktemp -d)"
trap 'kill "${serve_pid:-}" 2>/dev/null || true; rm -rf "$work"' EXIT
bucket="${GSCTL_E2E_BUCKET:-$work/bucket}"
keys="$work/keys"
mkdir -p "$keys/private"

go build -o "$work/gsctl" ./tools/gsctl
gsctl="$work/gsctl"

# 1. Ephemeral key set in the tools/gsctl/keys/dev layout; keyId = sha256(raw public key) (§15 D17).
anchor=""
for name in root-1 root-2 root-3 targets-1 snapshot-1 timestamp-1; do
  openssl genpkey -algorithm ed25519 -out "$keys/private/$name.pem" 2>/dev/null
  openssl pkey -in "$keys/private/$name.pem" -pubout -outform DER | tail -c 32 > "$work/$name.raw"
  pub="$(od -An -v -tx1 "$work/$name.raw" | tr -d ' \n')"
  echo "$pub" > "$keys/$name.pub.hex"
  if [[ $name == root-* ]]; then
    id="$(sha256sum "$work/$name.raw" | cut -d' ' -f1)"
    anchor+="${anchor:+,}{\"name\":\"$name\",\"keyId\":\"$id\",\"public\":\"$pub\"}"
  fi
done
cat > "$keys/roles.json" <<JSON
{"description":"ephemeral lab-e2e key set","roles":{
  "root":{"threshold":2,"keys":["root-1","root-2","root-3"]},
  "targets":{"threshold":1,"keys":["targets-1"]},
  "snapshot":{"threshold":1,"keys":["snapshot-1"]},
  "timestamp":{"threshold":1,"keys":["timestamp-1"]}}}
JSON
echo "{\"scheme\":\"ed25519\",\"threshold\":2,\"keys\":[$anchor]}" > "$keys/root-keys.json"

app_version="$(sed -n 's/^version: \([0-9.]*\).*/\1/p' apps/mobile/pubspec.yaml)"
cp -r profiles "$work/profiles"
find "$work/profiles" -name '*.yaml' -exec sed -i "s/^  minAppVersion: \".*\"/  minAppVersion: \"$app_version\"/" {} +

release() { # <repo> <version>
  "$gsctl" build -profiles "$work/profiles" -channel lab -repo "$1" -version "$2" -effective-from 2026-10-01 \
    -note-ar "إصدار تجريبي" -note-en "lab end-to-end release"
  if [[ ! -f "$1/metadata/root.json" ]]; then
    "$gsctl" sign -repo "$1" -role root -keys "$keys" -key-dir "$keys/private"
  fi
  for role in targets snapshot timestamp; do
    "$gsctl" sign -repo "$1" -role "$role" -keys "$keys" -key-dir "$keys/private"
  done
  "$gsctl" verify -repo "$1" -root-keys "$keys/root-keys.json"
  "$gsctl" publish -repo "$1" -channel lab -bucket "$bucket" -root-keys "$keys/root-keys.json"
}

# 2. First release.
"$gsctl" pull -repo "$work/runner-1" -channel lab -bucket "$bucket" -root-keys "$keys/root-keys.json"
release "$work/runner-1" 2026.10.2
# 3. Second release on a fresh runner.
"$gsctl" pull -repo "$work/runner-2" -channel lab -bucket "$bucket" -root-keys "$keys/root-keys.json"
release "$work/runner-2" 2026.10.3

# 4. Serve and sync.
"$gsctl" serve -bucket "$bucket" -addr 127.0.0.1:0 > "$work/serve.log" &
serve_pid=$!
for _ in $(seq 50); do grep -q 'serving' "$work/serve.log" 2>/dev/null && break; sleep 0.1; done
port="$(grep -oE '127\.0\.0\.1:[0-9]+' "$work/serve.log" | head -1 | cut -d: -f2)"
(cd apps/mobile && DM_E2E_CDN_PORT="$port" DM_E2E_ROOT_KEYS="$keys/root-keys.json" DM_E2E_EXPECT_VERSION=2026.10.3 \
  flutter test test/features/packages/lab_sync_end_to_end_test.dart)
