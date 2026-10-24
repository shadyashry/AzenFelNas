# Key compromise (SEV1; ADR-009)

**Trigger:** a private key or KMS permission is exposed or suspected exposed, or a verification canary shows a signature mismatch. **Owner:** Security; page the architect and the release manager.

1. **Contain:** disable the KMS key version, or remove the GitHub environment secret, and revoke the workload-identity binding that could use it. Freeze `release-package`, `promote-package` and `refresh-timestamp` (disable the workflows).
2. **Revoke in a new root:** root N+1 without the compromised key, with a fresh key for that role, signed by the threshold of the remaining root keys (key-ceremony.md §Signing session).
3. **Re-sign everything:** targets (new sequence), snapshot and timestamp with the new keys; `gsctl verify`; publish. Clients take the new root and refuse metadata signed by the revoked key.
4. **Force timestamp expiry** of anything the attacker could have signed: publish the new timestamp with a short lifetime, then the normal 168 h. Clients warn on expiry and never block (REQ-PKG-002).
5. **Root key compromise** (threshold reachable by the attacker): the embedded root can no longer be trusted. Ship an **app hot-fix** with a new embedded root (`docs/release/key-ceremony.md` outputs), then halt the store rollout of affected builds.
6. **Attestation keys** (D86): rotate the Play Integrity decryption keys in Play Console, or the App Attest root PEM if Apple publishes a new one, then redeploy the control plane.
7. Public note in the Passport change notes; post-incident review within 5 working days.
