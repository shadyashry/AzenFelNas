# Source this file to give the current shell the six DM_DEV_<ROLE>_KEY_<N> variables that the `dev`/`lab`
# GitHub environments will hold (README.md here, DESIGN.md §15 D62, D65). It is the local stand-in for those
# secrets, so gsctl and tools/gsctl/scripts/local-release.sh run exactly as release-package will in CI.
#
#   source tools/gsctl/keys/dev/load-ci-env.sh [private-key-dir]   (default: tools/gsctl/keys/dev/private)
#
# Each PEM is checked against its committed <name>.pub.hex first. Values live only in this shell's environment;
# nothing is written to disk and no key material is printed. `unset ${!DM_DEV_@}` removes them again.

_dm_keys_dir="tools/gsctl/keys/dev"
_dm_private_dir="${1:-$_dm_keys_dir/private}"
_dm_ok=1
for _dm_name in root-1 root-2 root-3 targets-1 snapshot-1 timestamp-1; do
  _dm_pem="$_dm_private_dir/$_dm_name.pem"
  if [[ ! -f "$_dm_pem" ]]; then
    echo "missing $_dm_pem" >&2; _dm_ok=0; break
  fi
  _dm_actual="$(openssl pkey -in "$_dm_pem" -pubout -outform DER | tail -c 32 | od -An -tx1 | tr -d ' \n')"
  _dm_expected="$(tr -d ' \r\n' < "$_dm_keys_dir/$_dm_name.pub.hex")"
  if [[ "$_dm_actual" != "$_dm_expected" ]]; then
    echo "$_dm_pem does not match $_dm_keys_dir/$_dm_name.pub.hex" >&2; _dm_ok=0; break
  fi
done
if [[ "$_dm_ok" == 1 ]]; then
  for _dm_name in root-1 root-2 root-3 targets-1 snapshot-1 timestamp-1; do
    _dm_var="DM_DEV_$(tr '[:lower:]' '[:upper:]' <<<"${_dm_name%-*}")_KEY_${_dm_name##*-}"
    export "$_dm_var=$(base64 < "$_dm_private_dir/$_dm_name.pem" | tr -d '\n')"
    echo "exported $_dm_var"
  done
fi
unset _dm_keys_dir _dm_private_dir _dm_ok _dm_name _dm_pem _dm_actual _dm_expected _dm_var
