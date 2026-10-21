# dm_lints

Shared analysis options and repository checks (`DESIGN.md` §12, §17.2).

| Item | Use |
|---|---|
| `package:dm_lints/analysis_options.yaml` | strict base for Flutter packages and `apps/mobile` |
| `package:dm_lints/pure.yaml` | base + `public_member_api_docs`, for the pure Dart set |
| `dart run dm_lints:arch_lint [root]` | fails when the pure Dart set touches Flutter or the platform, or a feature layer imports a layer it must not (§7.1) |
| `dart run dm_lints:req_index [root]` | fails when a `REQ-*` ID in the repository is missing from `DESIGN.md` Appendix F |

Both checks run from the repository root through `melos run lint:arch` and `melos run lint:req`.
