# Security policy

## Reporting a vulnerability

Email **security@dailymuslim.app**. Please do not open a public issue.

We follow a **90-day coordinated disclosure** window (`DESIGN.md` §25): we acknowledge within 5 working days, agree a fix timeline with you, and publish an advisory when a fix ships or at day 90, whichever comes first.

In scope: the mobile apps, the package distribution plane (`cdn.dailymuslim.app`), the control plane (`api.dailymuslim.app`), `gsctl` and this repository's CI.

## Handling rules for contributors

- No secrets, private keys or credentials in the repository (`REQ-SEC-030`). CI runs a secret scan on every PR.
- Dev TUF root private keys live only in the gitignored `tools/gsctl/keys/dev/private/` and in CI secrets; see `tools/gsctl/keys/dev/README.md`. Production keys are created only in the S27 ceremony.
- Device logs, diagnostics and test fixtures must not contain coordinates with more than 2 decimals or persistent identifiers (`REQ-PRIV-001`).
