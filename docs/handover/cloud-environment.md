# Cloud session environment (Claude Code on the web)

How a fresh cloud session installs the pinned toolchain (`.tool-versions`, `DESIGN.md` §5.4, ADR-011) and proves the baseline. Written in S10 on 2026-10-22; the container was Ubuntu 24.04 x86_64 with 4 CPUs, 15 GB RAM, Docker 29, system Go 1.24.7, system JDK 21.0.12 and uv 0.11 preinstalled.

## Network facts (this environment's policy)

- **Reachable:** `storage.googleapis.com` (Flutter), `proxy.golang.org`, `pub.dev`, `pypi.org`, `registry.npmjs.org`, GitHub release downloads and `git` over HTTPS to github.com (`git ls-remote/fetch https://github.com/eggert/tz` works).
- **Denied (HTTP 403 from the egress proxy):** `go.dev/dl`, `astral.sh`, `data.iana.org`, `www.iana.org`, the GitHub web UI for other repositories, and **`ssd.jpl.nasa.gov` / `naif.jpl.nasa.gov`**.
- Consequence: the lab cannot fetch `de440s.bsp` (§15 D28), so **44 lab tests fail/error** with `Tunnel connection failed: 403` (the same 44 before and after S10). The lab's ruff, format and mypy pass, and `lab benchmark --engine dart` still runs, because it reads the committed reference. **Owner action:** allow `ssd.jpl.nasa.gov` under the environment's Network access → Allowed domains (https://code.claude.com/docs/en/cloud-environments#network-access).

## Setup script

Run once per container, from the repository root; about 3 minutes.

```bash
#!/usr/bin/env bash
set -euo pipefail
mkdir -p /opt/sdk /root/.local/bin

# Flutter 3.47.7 (Dart 3.13.5)
curl -fsSL https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.47.7-stable.tar.xz \
  | tar xJ -C /opt/sdk
git config --global --add safe.directory /opt/sdk/flutter

# Go 1.27.3: go.dev is denied, so let the system go download the toolchain module from proxy.golang.org
(cd /tmp && GOTOOLCHAIN=go1.27.3 go version)
ln -sfn "$(ls -d /root/go/pkg/mod/golang.org/toolchain@v0.0.1-go1.27.3.linux-amd64)" /opt/sdk/go

# Environment for every later shell
cat > /root/dmenv.sh <<'EOF'
export PATH=/opt/sdk/flutter/bin:/opt/sdk/flutter/bin/cache/dart-sdk/bin:/opt/sdk/go/bin:/root/go/bin:/root/.local/bin:/root/.pub-cache/bin:$PATH
export GOTOOLCHAIN=local
export FLUTTER_SUPPRESS_ANALYTICS=true
export CI=true
EOF
source /root/dmenv.sh
flutter config --no-analytics >/dev/null; dart --disable-analytics >/dev/null
flutter --version >/dev/null   # first run unpacks the Dart SDK

# golangci-lint 2.15.0 (built with Go 1.27.3)
(cd /tmp && GOBIN=/root/go/bin go install github.com/golangci/golangci-lint/v2/cmd/golangci-lint@v2.15.0)

# uv 0.13.4 (astral.sh is denied; the GitHub release is not)
curl -fsSL https://github.com/astral-sh/uv/releases/download/0.13.4/uv-x86_64-unknown-linux-gnu.tar.gz \
  | tar xz -C /tmp && cp /tmp/uv-x86_64-unknown-linux-gnu/uv* /root/.local/bin/

dart --version; go version; golangci-lint --version; uv --version
```

Every later command: `source /root/dmenv.sh` first.

## Baseline (run before changing anything; full logs to /tmp)

```bash
source /root/dmenv.sh
dart pub get && dart run melos run ci > /tmp/melos.log 2>&1; tail -3 /tmp/melos.log
for m in tools/gsctl services/control-plane; do (cd $m && go vet ./... && go test -race ./... && golangci-lint run ./...) > /tmp/go_$(basename $m).log 2>&1; echo "$m $?"; done
for p in data-pipelines lab; do (cd $p && uv run --frozen ruff check . && uv run --frozen ruff format --check . && uv run --frozen mypy src tests && uv run --frozen pytest -q) > /tmp/py_$p.log 2>&1; echo "$p $?"; tail -1 /tmp/py_$p.log; done
bash schemas/tools/validate_fixtures.sh > /tmp/schemas.log 2>&1; echo "schemas $?"   # npx ajv from registry.npmjs.org
```

Expected on `slice/s10-tzdata`: melos SUCCESS; both Go modules green with 0 lint issues; data-pipelines 35 passed, 1 skipped (the opt-in rebuild); lab exit 1 with exactly the 44 ephemeris failures above; schemas exit 0.

S10's extra check (`make`, `cc` and `git` are preinstalled):

```bash
(cd data-pipelines && uv run --frozen dm-pipelines tzdata fetch --dest /tmp/tz && DM_TZ_SOURCE=/tmp/tz uv run --frozen pytest -q -k rebuild)
```

## Not installed yet

- **Temurin JDK 21.0.11** (`.tool-versions`): the system has OpenJDK 21.0.12. Install it and the **Android SDK (compileSdk 36)** when S19/S21 need Gradle builds.
- **Xcode**: none on Linux; `ci-ios` (macOS) builds Runner and the Darwin-only AthanKit files.

## Swift on Linux (added S22)

`download.swift.org` and `ghcr.io` blobs are denied; Docker Hub and GitHub release downloads are not. The Docker daemon is installed but not running:

```bash
(nohup dockerd > /tmp/dockerd.log 2>&1 &); sleep 8
docker pull -q swift:6.2-noble                     # Swift 6.2 toolchain
docker run --rm -v /home/user/AzenFelNas:/repo -v swiftbuild:/repo/apps/mobile/ios/AthanKit/.build \
  -w /repo/apps/mobile/ios/AthanKit swift:6.2-noble swift test      # the core; Platform/ and Spike/ are Darwin-only
mkdir -p /tmp/sl /tmp/sf
curl -fsSL -o /tmp/sl/sl.zip https://github.com/realm/SwiftLint/releases/download/0.65.1/swiftlint_linux_amd64.zip && unzip -oq /tmp/sl/sl.zip -d /tmp/sl
curl -fsSL -o /tmp/sf/sf.zip https://github.com/nicklockwood/SwiftFormat/releases/download/0.64.0/swiftformat_linux.zip && unzip -oq /tmp/sf/sf.zip -d /tmp/sf
/tmp/sl/swiftlint-static lint --strict && /tmp/sf/swiftformat_linux --lint apps/mobile/ios/AthanKit
```

The repository is mounted whole because the tests find their fixtures by walking up to `DESIGN.md`; the named volume keeps `.build` out of the checkout. SwiftLint's SourceKit-only rule (`statement_position`) is skipped on Linux; macOS CI runs it.
- **Python 3.15**: uv downloads it automatically on `uv sync`.

## Terraform and an S3 test server (added S25)

`registry.terraform.io` is denied, `releases.hashicorp.com` and GitHub release downloads are not, so the providers come from a local filesystem mirror:

```bash
mkdir -p /opt/sdk/tf /opt/sdk/tf-mirror/registry.terraform.io/hashicorp/google /opt/sdk/tf-mirror/registry.terraform.io/cloudflare/cloudflare
curl -fsSL -o /tmp/tf.zip https://releases.hashicorp.com/terraform/1.16.5/terraform_1.16.5_linux_amd64.zip && unzip -oq /tmp/tf.zip -d /opt/sdk/tf
curl -fsSL -o /opt/sdk/tf-mirror/registry.terraform.io/hashicorp/google/terraform-provider-google_8.6.0_linux_amd64.zip \
  https://releases.hashicorp.com/terraform-provider-google/8.6.0/terraform-provider-google_8.6.0_linux_amd64.zip
curl -fsSL -o /opt/sdk/tf-mirror/registry.terraform.io/cloudflare/cloudflare/terraform-provider-cloudflare_5.27.0_linux_amd64.zip \
  -L https://github.com/cloudflare/terraform-provider-cloudflare/releases/download/v5.27.0/terraform-provider-cloudflare_5.27.0_linux_amd64.zip
printf 'provider_installation {\n  filesystem_mirror {\n    path    = "/opt/sdk/tf-mirror"\n    include = ["registry.terraform.io/*/*"]\n  }\n}\n' > /root/.terraformrc
(cd infra/terraform/distribution && /opt/sdk/tf/terraform init -backend=false -input=false -lockfile=readonly && /opt/sdk/tf/terraform validate)
```

The MinIO images are gone from Docker Hub and quay.io / dl.min.io are denied; SeaweedFS works (§15 D85). Start `dockerd` as in the Swift section, then:

```bash
mkdir -p /tmp/s3cfg && printf '%s' '{"identities":[{"name":"gsctl","credentials":[{"accessKey":"gsctltest","secretKey":"gsctltestsecret"}],"actions":["Admin","Read","Write","List"]}]}' > /tmp/s3cfg/s3.json
docker run -d --name s3 -p 127.0.0.1:8333:8333 -v /tmp/s3cfg:/cfg chrislusf/seaweedfs:4.00 server -dir=/data \
  -master.volumePreallocate=false -master.volumeSizeLimitMB=16 -volume.max=200 -s3 -s3.config=/cfg/s3.json   # without these flags each bucket preallocates 1 GB
export GSCTL_S3_TEST_ENDPOINT=127.0.0.1:8333 GSCTL_S3_TEST_ACCESS_KEY_ID=gsctltest GSCTL_S3_TEST_SECRET_ACCESS_KEY=gsctltestsecret
echo 's3.bucket.create -name dm-dist-e2e' | docker exec -i s3 weed shell
GSCTL_E2E_BUCKET=s3://dm-dist-e2e DM_S3_ENDPOINT=127.0.0.1:8333 DM_S3_ACCESS_KEY_ID=gsctltest DM_S3_SECRET_ACCESS_KEY=gsctltestsecret \
  DM_S3_INSECURE=1 tools/gsctl/scripts/lab-e2e.sh
```

## Session hygiene

- Heartbeat: push a WIP commit to the slice branch, or an empty commit to `automation/heartbeat` (the only branch that may be force-pushed), at least every 30 minutes.
- In this environment the auto-mode classifier refused `git merge origin/slice/s09-gsctl-tuf` because the merge brought in a `CLAUDE.md` change that a peer session had requested (self-modification). An owner merges such updates, or approves the action in their own session.

## Control plane: Postgres and sqlc (added S26)

Docker Hub serves `postgres:16.15`; `apple.com` is denied (the App Attest root CA is owner-supplied, §15 D86). With `dockerd` running as in the Swift section:

```bash
source /root/dmenv.sh
docker run -d --name pg -p 127.0.0.1:5432:5432 -e POSTGRES_USER=cp -e POSTGRES_PASSWORD=cptest -e POSTGRES_DB=cp postgres:16.15
export DM_PG_TEST_URL='postgres://cp:cptest@127.0.0.1:5432/cp?sslmode=disable'
(cd services/control-plane && go test -race ./...)          # Postgres contract + migrate/purge commands run
(cd /tmp && GOBIN=/root/go/bin go install github.com/sqlc-dev/sqlc/cmd/sqlc@v1.31.1)   # cgo; ~2 min
(cd services/control-plane/internal/adapters/postgres && sqlc generate && git diff --exit-code .)
(cd infra/terraform/control-plane && /opt/sdk/tf/terraform init -backend=false -input=false -lockfile=readonly && /opt/sdk/tf/terraform validate)
docker build -t control-plane services/control-plane       # distroless image; `docker run ... control-plane migrate|serve|purge`
```
