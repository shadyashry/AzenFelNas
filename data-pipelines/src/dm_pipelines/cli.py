"""`dm-pipelines`: command line of the data pipelines (DESIGN.md §9.5).

    dm-pipelines tzdata fetch --dest DIR          # clone the pinned IANA commit (needs git)
    dm-pipelines tzdata build --source DIR [--out DIR]
    dm-pipelines polygons fetch --dataset tz|country --dest FILE  # the pinned source (curl)
    dm-pipelines polygons build --dataset tz|country --source FILE
        [--out DIR]
    dm-pipelines gazetteer fetch --dest FILE    # the pinned source (curl)
    dm-pipelines gazetteer build --source FILE [--out DIR]
    dm-pipelines quran fetch --source mushaf|text|juz --dest FILE  # the pinned source (curl)
    dm-pipelines quran build --mushaf FILE --text FILE --juz FILE --out DIR

`tzdata build` needs `make`, a C compiler and `dart` on PATH. Exit codes: 0 done, 1 refused
(pins, tools), 2 usage error.
"""

import argparse
import sys
from collections.abc import Sequence
from pathlib import Path

from pydantic import ValidationError

from dm_pipelines.commands import CommandError, CommandRunner, SubprocessRunner
from dm_pipelines.gazetteer.config import load_gazetteer_config
from dm_pipelines.gazetteer.pipeline import CONFIG as GAZETTEER_CONFIG
from dm_pipelines.gazetteer.pipeline import BuildGazetteer
from dm_pipelines.gazetteer.pipeline import default_out as gazetteer_out
from dm_pipelines.hashing import sha256_file
from dm_pipelines.polygons.config import Dataset, load_polygons_config
from dm_pipelines.polygons.pipeline import CONFIG as POLYGONS_CONFIG
from dm_pipelines.polygons.pipeline import BuildPolygons, default_out
from dm_pipelines.quran.config import JuzSource, MushafSource, TextSource, load_quran_config
from dm_pipelines.quran.juz_source import JuzSourceError
from dm_pipelines.quran.pages import PageSourceError
from dm_pipelines.quran.pipeline import CONFIG as QURAN_CONFIG
from dm_pipelines.quran.pipeline import BuildQuran, SourceHashError
from dm_pipelines.quran.text_source import TextSourceError
from dm_pipelines.schema.pipeline_manifest_v1 import PipelineManifestV1
from dm_pipelines.tzdata.config import load_tzdata_config
from dm_pipelines.tzdata.oracle import CorpusError
from dm_pipelines.tzdata.pipeline import CONFIG, DART_PACKAGE, BuildTzdata, PinError
from dm_pipelines.tzdata.source import SourceMismatchError, verify_source

_REPO = Path(__file__).resolve().parents[3]


def _parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(prog="dm-pipelines")
    parser.add_argument("--repo", type=Path, default=_REPO, help="repository root")
    pipelines = parser.add_subparsers(dest="pipeline", required=True)
    tzdata = pipelines.add_parser("tzdata", help="the tzdata package (§9.5)")
    commands = tzdata.add_subparsers(dest="command", required=True)
    fetch = commands.add_parser("fetch", help="clone the pinned IANA release and verify it")
    fetch.add_argument("--dest", type=Path, required=True)
    build = commands.add_parser("build", help="build tzdata.tzf, dst_oracle.json and manifest.json")
    build.add_argument("--source", type=Path, required=True, help="IANA tz source tree")
    build.add_argument("--out", type=Path, help="output directory (default: dm_civil_time data)")
    polygons = pipelines.add_parser(
        "polygons", help="the tz_polygons and country_polygons packages"
    )
    polygon_commands = polygons.add_subparsers(dest="command", required=True)
    polygon_fetch = polygon_commands.add_parser(
        "fetch", help="download the pinned source and verify"
    )
    polygon_build = polygon_commands.add_parser(
        "build", help="build <package>.bin, oracle, manifest"
    )
    for command in (polygon_fetch, polygon_build):
        command.add_argument("--dataset", choices=("tz", "country"), required=True)
    polygon_fetch.add_argument("--dest", type=Path, required=True, help="file to write")
    polygon_build.add_argument("--source", type=Path, required=True, help="pinned source file")
    polygon_build.add_argument("--out", type=Path, help="output directory (default: dm_civil_time)")
    gazetteer = pipelines.add_parser("gazetteer", help="the gazetteer package (GeoNames)")
    gazetteer_commands = gazetteer.add_subparsers(dest="command", required=True)
    gazetteer_fetch = gazetteer_commands.add_parser(
        "fetch", help="download the pinned source and verify"
    )
    gazetteer_fetch.add_argument("--dest", type=Path, required=True, help="file to write")
    gazetteer_build = gazetteer_commands.add_parser("build", help="build gazetteer.json, manifest")
    gazetteer_build.add_argument("--source", type=Path, required=True, help="pinned source file")
    gazetteer_build.add_argument("--out", type=Path, help="output directory (default: app assets)")
    quran = pipelines.add_parser("quran", help="the offline Quran package (KFGQPC, §15 D107)")
    quran_commands = quran.add_subparsers(dest="command", required=True)
    quran_fetch = quran_commands.add_parser("fetch", help="download a pinned source and verify")
    quran_fetch.add_argument("--source", choices=("mushaf", "text", "juz"), required=True)
    quran_fetch.add_argument("--dest", type=Path, required=True, help="file to write")
    quran_build = quran_commands.add_parser("build", help="build pages, quran.sqlite, manifest")
    quran_build.add_argument("--mushaf", type=Path, required=True, help="1441-AI-hafs.zip")
    quran_build.add_argument("--text", type=Path, required=True, help="KFGQPC-Hafs-V30.zip")
    quran_build.add_argument("--juz", type=Path, required=True, help="quran-data.xml")
    quran_build.add_argument("--out", type=Path, required=True, help="package directory")
    return parser


def _fetch_quran(runner: CommandRunner, repo: Path, source: str, dest: Path) -> None:
    config = load_quran_config(repo / QURAN_CONFIG)
    pin: MushafSource | TextSource | JuzSource
    match source:
        case "mushaf":
            pin = config.mushaf
        case "text":
            pin = config.text
        case _:
            pin = config.juz
    _download(runner, pin.url, pin.sha256, dest)


def _build_quran(args: argparse.Namespace) -> int:
    manifest = BuildQuran(repo=args.repo).run(args.mushaf, args.text, args.juz, args.out)
    total = sum(f.bytes for f in manifest.files)
    print(f"built: {args.out} ({len(manifest.files)} files, {total} bytes)")  # noqa: T201
    return 0


def _fetch(runner: CommandRunner, repo: Path, dest: Path) -> None:
    config = load_tzdata_config(repo / CONFIG)
    release = config.release
    dest.mkdir(parents=True, exist_ok=False)
    runner.run(["git", "init", "-q"], dest)
    runner.run(["git", "fetch", "-q", "--depth", "1", release.git_url, release.git_commit], dest)
    runner.run(["git", "checkout", "-q", "FETCH_HEAD"], dest)
    verify_source(dest, config.files)


def _fetch_polygons(runner: CommandRunner, repo: Path, dataset: Dataset, dest: Path) -> None:
    pin = load_polygons_config(repo / POLYGONS_CONFIG).source(dataset)
    _download(runner, pin.url, pin.sha256, dest)


def _download(runner: CommandRunner, url: str, sha256: str, dest: Path) -> None:
    if dest.exists():
        message = f"{dest} exists"
        raise FileExistsError(message)
    runner.run(["curl", "-fsSL", "--proto", "=https", "-o", str(dest), url], dest.parent)
    if (actual := sha256_file(dest)) != sha256:
        dest.unlink()
        message = f"{dest.name}: sha256 {actual}, pinned {sha256}"
        raise SourceMismatchError(message)


def _build(runner: CommandRunner, args: argparse.Namespace) -> tuple[Path, PipelineManifestV1]:
    repo: Path = args.repo
    if args.pipeline == "polygons":
        dataset: Dataset = args.dataset
        out: Path = args.out or default_out(
            repo, dataset, load_polygons_config(repo / POLYGONS_CONFIG)
        )
        return out, BuildPolygons(repo=repo).run(dataset, args.source, out)
    if args.pipeline == "gazetteer":
        out = args.out or gazetteer_out(repo, load_gazetteer_config(repo / GAZETTEER_CONFIG))
        return out, BuildGazetteer(repo=repo).run(args.source, out)
    version = load_tzdata_config(repo / CONFIG).release.version
    out = args.out or repo / DART_PACKAGE / "data" / "tzdata" / version
    return out, BuildTzdata(runner=runner, repo=repo).run(args.source, out)


def run(argv: Sequence[str], runner: CommandRunner) -> int:
    """Run the command line `argv` with `runner`; return the exit code."""
    try:
        args = _parser().parse_args(argv)
    except SystemExit as exit_:
        return 0 if exit_.code == 0 else 2
    repo: Path = args.repo
    try:
        if args.command == "fetch":
            if args.pipeline == "polygons":
                _fetch_polygons(runner, repo, args.dataset, args.dest)
            elif args.pipeline == "gazetteer":
                source = load_gazetteer_config(repo / GAZETTEER_CONFIG).source
                _download(runner, source.url, source.sha256, args.dest)
            elif args.pipeline == "quran":
                _fetch_quran(runner, repo, args.source, args.dest)
            else:
                _fetch(runner, repo, args.dest)
            print(f"fetched: {args.dest}")  # noqa: T201 - the CLI reports on stdout
            return 0
        if args.pipeline == "quran":
            return _build_quran(args)
        out, manifest = _build(runner, args)
    except (
        SourceMismatchError,
        SourceHashError,
        TextSourceError,
        JuzSourceError,
        PageSourceError,
        CommandError,
        CorpusError,
        PinError,
        ValidationError,
        OSError,
    ) as error:
        print(f"dm-pipelines: {error}", file=sys.stderr)  # noqa: T201
        return 1
    for output in manifest.outputs:
        print(f"built: {out / output.path} sha256 {output.sha256} ({output.records} records)")  # noqa: T201
    return 0


def main() -> None:
    """Entry point of the `dm-pipelines` script."""
    sys.exit(run(sys.argv[1:], SubprocessRunner()))
