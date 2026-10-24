#!/usr/bin/env bash
# The release-package job, run locally against the local distribution bucket (DESIGN.md §9.2, §15 D65):
# build the profiles package, sign every role with the dev keys, verify, then publish into dist/<channel>.
# release-package runs the same steps against R2 (GSCTL_BUCKET=s3://dm-dist with the DM_S3_* variables, §15 D85).
#
# Run from the repository root:
#   tools/gsctl/scripts/local-release.sh <dev|lab> <version> <effective-from YYYY-MM-DD> "<note ar>" "<note en>"
#
# Keys: the DM_DEV_<ROLE>_KEY_<N> variables when set (source tools/gsctl/keys/dev/load-ci-env.sh), otherwise
# the PEMs in GSCTL_KEY_DIR (default tools/gsctl/keys/dev/private). The signing state of each channel lives in
# out/<channel> (gitignored) so that sequences keep increasing across releases; dist/ is the bucket.
set -euo pipefail

if [[ $# -ne 5 ]]; then
  echo "usage: $0 <dev|lab> <version> <effective-from> <note-ar> <note-en>" >&2
  exit 2
fi
channel="$1" version="$2" effective_from="$3" note_ar="$4" note_en="$5"
repo="out/$channel"
bucket="${GSCTL_BUCKET:-dist}"
keys=()
if [[ -z "${DM_DEV_TARGETS_KEY_1:-}" ]]; then
  keys=(-key-dir "${GSCTL_KEY_DIR:-tools/gsctl/keys/dev/private}")
fi

bin="$(mktemp -d)"
trap 'rm -rf "$bin"' EXIT
go build -o "$bin/gsctl" ./tools/gsctl
gsctl="$bin/gsctl"

"$gsctl" build -channel "$channel" -repo "$repo" -version "$version" -effective-from "$effective_from" \
  -note-ar "$note_ar" -note-en "$note_en"
if [[ ! -f "$repo/metadata/root.json" ]]; then
  "$gsctl" sign -repo "$repo" -role root "${keys[@]}"
fi
for role in targets snapshot timestamp; do
  "$gsctl" sign -repo "$repo" -role "$role" "${keys[@]}"
done
"$gsctl" verify -repo "$repo"
"$gsctl" publish -repo "$repo" -channel "$channel" -bucket "$bucket"
echo "serve it with: go run ./tools/gsctl serve -bucket $bucket"
