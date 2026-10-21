#!/usr/bin/env bash
# Uploads the six dev private keys as GitHub Actions secrets DM_DEV_<ROLE>_KEY_<N> on the `dev` and `lab`
# environments, creating the environments if they do not exist (README.md here, DESIGN.md §15 D62).
#
# Run once from the repository root as a repository admin, after `gh auth login`:
#   tools/gsctl/keys/dev/set-ci-secrets.sh [private-key-dir]     (default: tools/gsctl/keys/dev/private)
# GH_REPO overrides the repository (default: samehamin/daily_muslim).
#
# Each PEM is first checked against its committed <name>.pub.hex, so a wrong key is never uploaded.
# No key material is printed; the value goes to `gh secret set` on stdin only.
set -euo pipefail

repo="${GH_REPO:-samehamin/daily_muslim}"
keys_dir="tools/gsctl/keys/dev"
private_dir="${1:-$keys_dir/private}"
names=(root-1 root-2 root-3 targets-1 snapshot-1 timestamp-1)

command -v gh >/dev/null || { echo "gh (GitHub CLI) is required" >&2; exit 2; }
command -v openssl >/dev/null || { echo "openssl is required" >&2; exit 2; }

for name in "${names[@]}"; do
  pem="$private_dir/$name.pem"
  [[ -f "$pem" ]] || { echo "missing $pem" >&2; exit 1; }
  actual="$(openssl pkey -in "$pem" -pubout -outform DER | tail -c 32 | od -An -tx1 | tr -d ' \n')"
  expected="$(tr -d ' \r\n' < "$keys_dir/$name.pub.hex")"
  [[ "$actual" == "$expected" ]] || { echo "$pem does not match $keys_dir/$name.pub.hex; nothing uploaded" >&2; exit 1; }
done

for env in dev lab; do
  gh api --method PUT "repos/$repo/environments/$env" --silent
  for name in "${names[@]}"; do
    role="${name%-*}"
    n="${name##*-}"
    variable="DM_DEV_$(tr '[:lower:]' '[:upper:]' <<<"$role")_KEY_$n"
    base64 < "$private_dir/$name.pem" | tr -d '\n' | gh secret set "$variable" --repo "$repo" --env "$env"
    echo "set $variable on $env"
  done
done
