# Production key ceremony (S27; ADR-009, Appendix C, §15 D87)

**Status: OWED — owner action.** Nothing here has been performed. No production key exists. Until it does, `beta` and `production` builds embed no root (`AppBindings._embeddedRoot` returns null) and sync nothing.

## Roles
- **Ceremony lead** (Security) runs the script.
- **Three root holders**, distinct people, each of whom keeps one hardware token.
- **Witness** (Architect or Release manager) reads every step aloud and signs the log.
- At least 3 people in the room. No key holder signs the log alone.

## Equipment (engineering default, §15 D87)
- An air-gapped laptop booted from a verified live image (checksum compared by two people). It has no network hardware enabled and is used only for the ceremony.
- Three FIDO2/PIV hardware tokens able to hold Ed25519 keys (e.g. YubiKey 5 series with firmware ≥ 5.7 supports Ed25519 in PIV), plus three spares.
- A `gsctl` binary built reproducibly from the release commit (`go build -trimpath`, the sha256 compared on two machines), and OpenSSL ≥ 3.5.
- Two new USB drives for public outputs only. Tamper-evident bags and a printed log.

## Generation session
1. Record the date, the attendees, the laptop and token serial numbers, and the `gsctl` sha256.
2. For each holder *i* ∈ {1,2,3}, generate `root-i` **on the token** (non-exportable). Export only the raw 32-byte public key (`root-i.pub.hex`) and compute `keyId` = sha256(public) (§15 D17).
3. Write `root-keys.json` (threshold **2**) and `roles.json` for the channel set. The `targets` role is the KMS key `<channel>-targets-1` (public key from `gcloud kms keys versions get-public-key`, fetched before the ceremony and brought on the USB drive). `snapshot` and `timestamp` are new online Ed25519 keys generated on the laptop and immediately moved to the environment secrets of `beta`/`production` by the lead after the ceremony (two people).
4. Sign `root.json` version 1 with root-1 and root-2 (`gsctl sign -role root -sequence 1`). Then verify with `gsctl verify`.
5. Copy only public files to the USB drives: `root-keys.json`, `roles.json`, `*.pub.hex`, `root.json`. Seal each token in its own tamper-evident bag. Each holder stores it in a separate location.
6. Everyone signs the log, which is scanned into the private governance store (not this repository).

## Outputs into the repository (PR by the lead, reviewed by Security)
- `tools/gsctl/keys/production/{root-keys.json,roles.json,*.pub.hex}`: public material only.
- `apps/mobile/lib/features/packages/data/production_root_keys.dart`: the embedded trust anchor. `_embeddedRoot()` maps `beta`/`production` to it, with a test that its keyIds equal `tools/gsctl/keys/production/root-keys.json` (as the dev keys are tested).
- `promote-package.yml` gains `beta` and `production` options, and their environments get required reviewers (dual control, §15 D85).

## Signing session (rotation, compromise, yearly root re-sign)
Use the same air-gapped laptop. Two holders bring their tokens. The lead brings the prepared unsigned `root.json` N+1 on a USB drive and the witness compares its sha256 to the value in the PR. Sign, verify and copy the result out. Log it as above.
