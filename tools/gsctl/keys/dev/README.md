# Dev TUF root keys (`dev` / `lab` channels only)

Three Ed25519 root keys, threshold 2 (`DESIGN.md` §7.4, Appendix C). Generated in slice S01 with OpenSSL 3.5.

| File | Committed | Contents |
|---|---|---|
| `root-keys.json` | yes | `keyId` and raw public key (hex) of each key, plus the threshold |
| `root-N.pub.hex` | yes | raw 32-byte Ed25519 public key, lowercase hex |
| `private/root-N.pem` | **never** | PKCS#8 PEM private key; `private/` is gitignored |

Encoding (§15 D17): `public` is the lowercase hex of the 32 raw public-key bytes; `keyId` is the lowercase hex SHA-256 of those 32 bytes.

These keys sign nothing on `beta` or `production`. The production root is created only in the S27 key ceremony on offline hardware tokens.

## Loading the private keys into CI

1. Base64-encode each PEM: `base64 -w0 private/root-1.pem`.
2. Store them as GitHub Actions secrets `DM_DEV_ROOT_KEY_1`, `DM_DEV_ROOT_KEY_2`, `DM_DEV_ROOT_KEY_3` on the `dev` environment only.
3. Workflows decode them into a runner temp directory, use them, and delete them in an `always()` step. They are never written to the workspace or to artifacts.
4. After upload, keep the local `private/` copies on an encrypted volume or delete them; regenerate and re-publish `root-keys.json` if they leak.

## Regenerating

Regenerating replaces the dev root. Run the `openssl genpkey -algorithm ed25519` steps for all three keys, rebuild `root-keys.json` and the `.pub.hex` files, and re-sign the `dev`/`lab` metadata (S09 `gsctl`).
