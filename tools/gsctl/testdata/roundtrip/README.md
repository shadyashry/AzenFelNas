# Go → Dart round-trip vector (slice S09)

`dev/` is a complete `dev` channel that `gsctl` built from the seed profiles and signed with the **dev keys** (`tools/gsctl/keys/dev`, §15 D62): `metadata/{root,targets,snapshot,timestamp}.json` and one `prayer_profiles` package. It is the S09 done-test's evidence that what Go signs, Dart verifies (§13 S09, REQ-DIST-001..004):

- `packages/dm_packages/test/tuf/go_round_trip_test.dart` verifies it with the Dart verifier against `root-keys.json`, and checks that one flipped byte or a sequence regression fails.
- `tools/gsctl/main_test.go` verifies it with `gsctl verify`.

Its bytes are pinned by the signatures and hashes inside it, so `.gitattributes` marks it `-text`; never edit it by hand. The timestamp expires 7 days after signing; tests pass their own "now", and expiry is only a `PKG_EXPIRED_WARNING` (REQ-PKG-002).

It is a frozen snapshot, not a copy of the current profiles. Regenerate it only when the metadata format or the dev keys change, from the repository root, with the dev private keys:

```
GSCTL_KEY_DIR=tools/gsctl/keys/dev/private tools/gsctl/testdata/roundtrip/regenerate.sh
```
