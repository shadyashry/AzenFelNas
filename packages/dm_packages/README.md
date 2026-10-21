# dm_packages

TUF-lite package client: verify, stage, activate and roll back signed data packages (DESIGN.md §7.4, ADR-009).

Pure Dart set (DESIGN.md §0.2 rule 2): imports nothing from Flutter or the platform. Holds the `tuf_metadata.v1` wire model since S02; the package client arrives in S14.
