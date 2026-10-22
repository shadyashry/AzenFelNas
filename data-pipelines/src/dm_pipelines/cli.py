"""`dm-pipelines`: command line of the data pipelines (DESIGN.md §9.5).

    dm-pipelines tzdata fetch --dest DIR          # clone the pinned IANA commit (needs git)
    dm-pipelines tzdata build --source DIR [--out DIR]

`build` needs `make`, a C compiler and `dart` on PATH. Exit codes: 0 done, 1 refused (pins, tools),
2 usage error.
"""

import argparse
import sys
from collections.abc import Sequence
from pathlib import Path

from pydantic import ValidationError

from dm_pipelines.commands import CommandError, CommandRunner, SubprocessRunner
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
    return parser


def _fetch(runner: CommandRunner, repo: Path, dest: Path) -> None:
    config = load_tzdata_config(repo / CONFIG)
    release = config.release
    dest.mkdir(parents=True, exist_ok=False)
    runner.run(["git", "init", "-q"], dest)
    runner.run(["git", "fetch", "-q", "--depth", "1", release.git_url, release.git_commit], dest)
    runner.run(["git", "checkout", "-q", "FETCH_HEAD"], dest)
    verify_source(dest, config.files)


def run(argv: Sequence[str], runner: CommandRunner) -> int:
    """Run the command line `argv` with `runner`; return the exit code."""
    try:
        args = _parser().parse_args(argv)
    except SystemExit as exit_:
        return 0 if exit_.code == 0 else 2
    repo: Path = args.repo
    try:
        if args.command == "fetch":
            _fetch(runner, repo, args.dest)
            print(f"fetched: {args.dest}")  # noqa: T201 - the CLI reports on stdout
            return 0
        version = load_tzdata_config(repo / CONFIG).release.version
        out: Path = args.out or repo / DART_PACKAGE / "data" / "tzdata" / version
        manifest = BuildTzdata(runner=runner, repo=repo).run(args.source, out)
    except (
        SourceMismatchError,
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
