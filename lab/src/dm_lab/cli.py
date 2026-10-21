"""`lab` command line: the composition root of the Accuracy Lab (DESIGN.md §9.4).

    lab reference [--years 2026-2028]          build the frozen reference JSONL + manifest
    lab benchmark --engine dart [--years ...] [--tags DAY_OF_MONTH ...] [--dhuhr-offset-minutes N]
                                               run the engine bench, write a discrepancy report

Exit status: 0 success, 1 blocking discrepancies (promotion blocked, §6.7),
2 usage or contract error.
"""

import argparse
import re
import sys
from collections.abc import Sequence
from pathlib import Path

from pydantic import ValidationError

from dm_lab.bench import BenchContractError, DartEngineBench
from dm_lab.build_reference import BuildReference
from dm_lab.compare import CompareWithReference
from dm_lab.config import HarnessConfig, load_config
from dm_lab.dateset import TAG_ORDER, DateTag, SelectBenchmarkDays, YearRange
from dm_lab.ephemeris import EphemerisIntegrityError, ensure_ephemeris, urllib_fetch
from dm_lab.hashing import sha256_file
from dm_lab.hijri import TabularHijriCalendar
from dm_lab.jsonl import read_jsonl, write_document, write_jsonl
from dm_lab.manifest import (
    REFERENCE_SOURCES,
    build_manifest,
    file_input,
    file_output,
    source_input,
    tool_versions,
    url_input,
)
from dm_lab.paths import (
    DEFAULT_BENCHMARK_OUT,
    DEFAULT_CITIES,
    DEFAULT_CONFIG,
    DEFAULT_REFERENCE,
    ENGINE_PACKAGE_DIR,
    LAB_ROOT,
    PACKAGE_DIR,
    cache_dir,
)
from dm_lab.reference import CalculateReferenceDay, PrayerDayError
from dm_lab.run_benchmark import CaseSelection, RunBenchmark
from dm_lab.schema.benchmark_cities_v1 import BenchmarkCitiesV1
from dm_lab.schema.lab_reference_v1 import LabReferenceDayV1
from dm_lab.schema.pipeline_manifest_v1 import PipelineManifestV1
from dm_lab.sky import SkyfieldSun, TimeScaleError
from dm_lab.tzdb import PinnedTzdb

EXIT_OK = 0
EXIT_BLOCKING = 1
EXIT_ERROR = 2

_YEARS = re.compile(r"^(\d{4})-(\d{4})$")
_MANIFEST_SUFFIX = ".manifest.json"
# Appendix A bounds of a transit rule's offsetMinutes (a schema constraint, not a profile value).
_DHUHR_OFFSET_CHOICES = range(6)


def main(argv: Sequence[str] | None = None) -> int:
    """Run the `lab` command and return its exit status."""
    args = _parser().parse_args(argv)
    try:
        config = load_config(args.config)
        cities = BenchmarkCitiesV1.model_validate_json(args.cities.read_text(encoding="utf-8"))
        if args.command == "reference":
            return _reference(config, args.config, cities, args)
        return _benchmark(config, cities, args)
    except (
        BenchContractError,
        EphemerisIntegrityError,
        OSError,
        PrayerDayError,
        TimeScaleError,
        ValidationError,
        ValueError,
    ) as error:
        sys.stderr.write(f"lab {args.command}: {error}\n")
        return EXIT_ERROR


def _parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(prog="lab", description=__doc__)
    commands = parser.add_subparsers(dest="command", required=True)
    for name, help_text in (
        ("reference", "build the Skyfield/de440s reference JSONL and its manifest"),
        ("benchmark", "run an engine bench over the reference and write a discrepancy report"),
    ):
        command = commands.add_parser(name, help=help_text)
        command.add_argument("--config", type=Path, default=DEFAULT_CONFIG)
        command.add_argument("--cities", type=Path, default=DEFAULT_CITIES)
        command.add_argument("--years", type=_year_range, default=YearRange(2026, 2028))
    reference = commands.choices["reference"]
    reference.add_argument("--out", type=Path, help="reference JSONL (default: lab/reference/)")
    benchmark = commands.choices["benchmark"]
    benchmark.add_argument("--engine", choices=["dart"], required=True)
    benchmark.add_argument("--reference", type=Path, default=DEFAULT_REFERENCE)
    benchmark.add_argument("--profile", default="engine.default")
    benchmark.add_argument("--out", type=Path, default=DEFAULT_BENCHMARK_OUT)
    benchmark.add_argument(
        "--tags",
        nargs="+",
        choices=TAG_ORDER,
        help="only cases with one of these date tags (default: all)",
    )
    benchmark.add_argument(
        "--dhuhr-offset-minutes",
        type=int,
        choices=_DHUHR_OFFSET_CHOICES,
        default=0,
        help="the profile's transit offsetMinutes; 0 = no offset (Appendix A, §15 D29)",
    )
    return parser


def _year_range(text: str) -> YearRange:
    match = _YEARS.match(text)
    if match is None:
        msg = f"expected YYYY-YYYY, got {text!r}"
        raise argparse.ArgumentTypeError(msg)
    return YearRange(int(match.group(1)), int(match.group(2)))


def _reference(
    config: HarnessConfig,
    config_path: Path,
    cities: BenchmarkCitiesV1,
    args: argparse.Namespace,
) -> int:
    years: YearRange = args.years
    out: Path = args.out or (
        LAB_ROOT / "reference" / f"sun_events.{years.first}-{years.last}.v1.jsonl"
    )
    ephemeris = ensure_ephemeris(config.ephemeris, cache_dir(), urllib_fetch)
    sun = SkyfieldSun(ephemeris, config)
    tzdb = PinnedTzdb()
    build = BuildReference(
        tzdb,
        SelectBenchmarkDays(sun),
        CalculateReferenceDay(sun, tzdb, config.horizon.altitude_deg, config.tolerance),
    )
    try:
        lines = build(cities, years)
    finally:
        sun.close()
    records = write_jsonl(out, lines)
    manifest = build_manifest(
        "lab.reference",
        inputs=[
            file_input("cities", args.cities),
            file_input("config", config_path),
            url_input("ephemeris", config.ephemeris.url, config.ephemeris.sha256),
            source_input("harness_source", PACKAGE_DIR, REFERENCE_SOURCES),
        ],
        tools=tool_versions({"tzdb": tzdb.version}),
        parameters={
            "years": f"{years.first}-{years.last}",
            "deltaTSeconds": f"{config.time.delta_t_s}",
        },
        outputs=[file_output(out, records, out.parent)],
    )
    write_document(_manifest_path(out), manifest)
    sys.stdout.write(f"wrote {records} reference lines to {out}\n")
    return EXIT_OK


def _benchmark(config: HarnessConfig, cities: BenchmarkCitiesV1, args: argparse.Namespace) -> int:
    reference_path: Path = args.reference
    reference_sha256 = _verified_reference_sha256(reference_path)
    references = read_jsonl(reference_path, LabReferenceDayV1)
    run = RunBenchmark(
        DartEngineBench(ENGINE_PACKAGE_DIR),
        CompareWithReference(
            config.benchmark.event_map,
            config.tolerance,
            dhuhr_offset_minutes=args.dhuhr_offset_minutes,
        ),
        TabularHijriCalendar(config.hijri),
        config.benchmark.profiles,
    )
    tags: list[DateTag] | None = args.tags
    result = run(
        references,
        CaseSelection(
            city_ids=frozenset(city.city_id for city in cities.cities),
            years=args.years,
            tags=None if tags is None else frozenset(tags),
        ),
        profile_id=args.profile,
        reference_sha256=reference_sha256,
    )
    out: Path = args.out
    requests_path = out / "requests.jsonl"
    responses_path = out / "responses.jsonl"
    report_path = out / "discrepancy_report.json"
    write_jsonl(requests_path, result.requests)
    write_jsonl(responses_path, result.responses)
    write_document(report_path, result.report)
    manifest = build_manifest(
        "lab.benchmark",
        inputs=[
            file_input("cities", args.cities),
            file_input("config", args.config),
            file_input("reference", reference_path),
            source_input(
                "lab_source",
                PACKAGE_DIR,
                [path.relative_to(PACKAGE_DIR).as_posix() for path in PACKAGE_DIR.rglob("*.py")],
            ),
        ],
        tools=tool_versions({}),
        parameters={
            "engine": args.engine,
            "profileId": args.profile,
            "years": f"{args.years.first}-{args.years.last}",
            "tags": ",".join(tags) if tags else "ALL",
            "dhuhrOffsetMinutes": str(args.dhuhr_offset_minutes),
        },
        outputs=[
            file_output(requests_path, len(result.requests), out),
            file_output(responses_path, len(result.responses), out),
            file_output(report_path, 1, out),
        ],
    )
    write_document(out / "manifest.json", manifest)
    summary = result.report.summary
    sys.stdout.write(
        f"{summary.cases} cases, {summary.compared_events} events, {summary.agreed} agreed, "
        f"{summary.discrepancies} discrepancies ({summary.blocking} blocking), "
        f"max |residual| {summary.max_abs_delta_ms} ms; report: {report_path}\n",
    )
    return EXIT_BLOCKING if summary.blocking else EXIT_OK


def _manifest_path(jsonl: Path) -> Path:
    return jsonl.with_name(jsonl.name.removesuffix(".jsonl") + _MANIFEST_SUFFIX)


def _verified_reference_sha256(reference: Path) -> str:
    """Return the frozen reference's sha256, checked against the manifest written beside it.

    Raises:
        ValueError: the manifest does not list the file or lists another sha256.

    """
    manifest = PipelineManifestV1.model_validate_json(
        _manifest_path(reference).read_text(encoding="utf-8"),
    )
    actual = sha256_file(reference)
    listed = {output.path: output.sha256 for output in manifest.outputs}
    if listed.get(reference.name) != actual:
        msg = f"{reference} (sha256 {actual}) does not match its manifest"
        raise ValueError(msg)
    return actual
