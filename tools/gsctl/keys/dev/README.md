# Dev TUF keys (`dev` / `lab` channels only)

Six Ed25519 keys (`DESIGN.md` §7.4, §9.1, Appendix C, §15 D62): three root keys with threshold 2 (generated in slice S01 with OpenSSL 3.5) and one key each for `targets`, `snapshot` and `timestamp`, threshold 1 (generated in slice S09 with OpenSSL 3.5.7).

| File | Committed | Contents |
|---|---|---|
| `root-keys.json` | yes | `keyId` and raw public key (hex) of each root key, plus the threshold: the trust anchor a dev/lab app build embeds |
| `roles.json` | yes | which named key signs which role, and each role's threshold; `gsctl sign` builds `root.json` from it |
| `<name>.pub.hex` | yes | raw 32-byte Ed25519 public key, lowercase hex (`root-1..3`, `targets-1`, `snapshot-1`, `timestamp-1`) |
| `private/<name>.pem` | **never** | PKCS#8 PEM private key; `private/` is gitignored |

Encoding (§15 D17): `public` is the lowercase hex of the 32 raw public-key bytes; `keyId` is the lowercase hex SHA-256 of those 32 bytes.

These keys sign nothing on `beta` or `production`. The production root is created only in the S27 key ceremony on offline hardware tokens, and the production `targets` key lives in Cloud KMS (S25).

## Using the keys with `gsctl`

From the repository root (`go run ./tools/gsctl <command> -h` lists every flag):

```
go run ./tools/gsctl sign -repo out/dev -role root -key-dir tools/gsctl/keys/dev/private
go run ./tools/gsctl sign -repo out/dev -role targets -key-dir tools/gsctl/keys/dev/private
```

Without `-key-dir`, `gsctl sign` reads each key from the variable `DM_DEV_<ROLE>_KEY_<N>` (for example `DM_DEV_ROOT_KEY_1`, `DM_DEV_TIMESTAMP_KEY_1`), holding the base64 of the PEM. A key that is absent is skipped; signing fails unless the role's threshold of keys is present and each matches its public key here.

## Loading the private keys into CI

1. Base64-encode each PEM: `base64 -w0 private/root-1.pem`.
2. Store them as GitHub Actions secrets `DM_DEV_ROOT_KEY_1..3`, `DM_DEV_TARGETS_KEY_1`, `DM_DEV_SNAPSHOT_KEY_1`, `DM_DEV_TIMESTAMP_KEY_1` on the `dev` and `lab` environments only.
3. Workflows pass them to `gsctl` as environment variables. They are never written to the workspace or to artifacts.
4. After upload, keep the local `private/` copies on an encrypted volume or delete them; regenerate and re-publish the public files if they leak.

## Regenerating

Regenerating a key replaces it for every dev/lab client. For each key run `openssl genpkey -algorithm ed25519 -out private/<name>.pem`, then write its public hex with `openssl pkey -in private/<name>.pem -pubout -outform DER | tail -c 32 | od -An -tx1 | tr -d ' \n'`. A new root key also needs `root-keys.json` rebuilt. Then re-sign `root.json` and every role of the `dev`/`lab` metadata, and regenerate the round-trip vector (`tools/gsctl/testdata/roundtrip/README.md`).
