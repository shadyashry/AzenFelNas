# Key rotation (ADR-009, Appendix C)

**Owner:** Security; two root holders present for any root signature (threshold 2 of 3).

- **Timestamp / snapshot:** these are online keys used by `refresh-timestamp.yml` and the release jobs. Rotate by adding the new key to `roles.json`, signing a new root (step "Root"), then removing the old key from the environment secrets.
- **Targets (beta/production, Cloud KMS):** create a new key version of `<channel>-targets-1` (`gcloud kms keys versions create`); put its public key in the root (`roles.json` → new `targets` keyId); sign the new root (step "Root"); point `DM_KMS_TARGETS_KEY_1` at the new version; sign targets → snapshot → timestamp; disable the old version after every client has the new root (two release cycles).
- **Root:** prepare `root.json` version N+1 with the new key set. It must be signed by **threshold of the old root keys and threshold of the new ones** (the client verifies N+1 with N's keys first). Use the offline procedure of `docs/release/key-ceremony.md` §Signing session; `gsctl sign -role root -sequence N+1`; `gsctl verify`; publish. Root expiry is 1 year (`-expires-in 8760h`); rotate or re-sign at 60 days before expiry.
- **App:** a root rotation needs no app update. A new app build embeds the newest root keys so new installs start from it.
