# data-pipelines

Deterministic Python pipelines for the data packages (DESIGN.md §9.5, §17.6). Each one records its pinned inputs and its outputs by sha256 in a `pipeline_manifest.v1`.

## tzdata (S10, §15 D66–D67)

```
uv run --frozen dm-pipelines tzdata fetch --dest /tmp/tz        # clone the pinned IANA commit and verify every pinned file
uv run --frozen dm-pipelines tzdata build --source /tmp/tz      # → packages/dm_civil_time/data/tzdata/<version>/
DM_TZ_SOURCE=/tmp/tz uv run --frozen pytest -k rebuild          # the rebuild is byte-identical to the committed outputs
```

`build` needs `make`, a C compiler and `dart` on PATH, and `dart pub get` run at the repository root. It stages only the files pinned in `config/tzdata.v1.toml`, compiles `zic` from that release, runs `make rearguard.zi` and `zic -b fat`, and encodes the result with `packages/dm_civil_time/tool/encode_tzf.dart`. It also writes the DST oracle (CPython `zoneinfo` over the same zic output) for the S10 suite.

**A new IANA release** (runbook `tzdb-emergency`): update the `[release]` table and the `[files]` pins, then run `fetch` and `build`, commit the new `data/tzdata/<version>/` (and remove the old one), and package it with `gsctl build -type tzdata` (§15 D69).

## tz_polygons and country_polygons (S11, §15 D70–D71)

```
uv run --frozen dm-pipelines polygons fetch --dataset tz --dest /tmp/src/timezones.geojson.zip
uv run --frozen dm-pipelines polygons fetch --dataset country --dest /tmp/src/ne_10m_admin_0_map_units.geojson
uv run --frozen dm-pipelines polygons build --dataset tz --source /tmp/src/timezones.geojson.zip
uv run --frozen dm-pipelines polygons build --dataset country --source /tmp/src/ne_10m_admin_0_map_units.geojson
DM_POLYGON_SOURCES=/tmp/src uv run --frozen pytest -k rebuild   # byte-identical to the committed outputs
```

`fetch` downloads with `curl` and refuses (and deletes) bytes that do not match the sha256 in `config/polygons.v1.toml`. `build` writes `packages/dm_civil_time/data/<package>/<source version>/`: the payload (`<package>.bin`, layout `schemas/tz_polygons.v1.ksy`), `lookup_oracle.json` (shapely on the unsimplified source, for the S11 done-test) and `manifest.json`. Each build takes under a minute.

**A new source release**: update the dataset's table in `config/polygons.v1.toml` (version, URL, sha256), run `fetch` and `build`, and commit the new directory in place of the old one. The tz polygons should follow the IANA pin (same release name).

Models in `src/dm_pipelines/schema/` are generated from `schemas/` by `scripts/gen_models.sh`; `ci-lab` checks that they are fresh.
