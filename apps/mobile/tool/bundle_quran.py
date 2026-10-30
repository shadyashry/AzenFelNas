"""Copies the pinned Quran package into the app's assets (§15 D107, D117).

    uv run --no-project python -I tool/bundle_quran.py <package dir>

Run from apps/mobile. <package dir> is the output of
`dm-pipelines quran build` (the directory holding `manifest.json`). The copy is
refused unless `manifest.json` has the SHA-256 and size `QuranEditionPin`
pins and every file it lists has its size and SHA-256, so the app can only
carry the package it would accept from the CDN. Only the manifest and the files
it lists are copied; `assets/quran/` is emptied first and is not in git.
"""

from __future__ import annotations

import hashlib
import json
import re
import shutil
import sys
from pathlib import Path

APP = Path(__file__).resolve().parent.parent
TARGET = APP / "assets" / "quran"
PIN = APP / "lib" / "features" / "quran" / "domain" / "quran_edition_pin.dart"


def _pinned() -> tuple[str, int]:
    text = PIN.read_text(encoding="utf-8")
    sha = re.search(r"manifestSha256 =\s*'([0-9a-f]{64})'", text)
    size = re.search(r"manifestBytes = (\d+);", text)
    if sha is None or size is None:
        raise SystemExit(f"cannot read the pin in {PIN}")
    return sha.group(1), int(size.group(1))


def _sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main(source: Path) -> None:
    manifest = source / "manifest.json"
    sha, size = _pinned()
    if manifest.stat().st_size != size or _sha256(manifest) != sha:
        raise SystemExit("manifest.json is not the pinned one")
    files = json.loads(manifest.read_text(encoding="utf-8"))["files"]
    for entry in files:
        path = source / entry["path"]
        if path.stat().st_size != entry["bytes"] or _sha256(path) != entry["sha256"]:
            raise SystemExit(f"{entry['path']} does not match the manifest")
    if TARGET.exists():
        shutil.rmtree(TARGET)
    for entry in files:
        out = TARGET / entry["path"]
        out.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(source / entry["path"], out)
    shutil.copyfile(manifest, TARGET / "manifest.json")
    total = sum(entry["bytes"] for entry in files)
    print(f"bundled {len(files)} files, {total} bytes, manifest {sha[:12]}")


if __name__ == "__main__":
    if len(sys.argv) != 2:
        raise SystemExit(__doc__)
    main(Path(sys.argv[1]))
