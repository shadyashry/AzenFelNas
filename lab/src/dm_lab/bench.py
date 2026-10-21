"""The engine bench JSONL contract, lab side (DESIGN.md §6.1, §9.4, §15 D29).

stdin: one bench_request.v1 line per case, carrying the Hijri state the engine must echo.
stdout: exactly one line per request line, in order —
a calculation_trace.v1 document, or a bench_failure.v1 document for a typed failure.
"""

import json
import shutil
import subprocess
from collections.abc import Sequence
from pathlib import Path
from typing import Protocol

from pydantic import ValidationError

from dm_lab.jsonl import encode_line
from dm_lab.schema.bench_failure_v1 import BenchFailureV1
from dm_lab.schema.bench_request_v1 import BenchRequestV1, Hijri, Observer
from dm_lab.schema.calculation_trace_v1 import CalculationTraceV1
from dm_lab.schema.lab_reference_v1 import LabReferenceDayV1

type BenchResponse = CalculationTraceV1 | BenchFailureV1


class BenchContractError(Exception):
    """The engine bench broke the JSONL contract (exit status, line count or line shape)."""


class RunEngineBench(Protocol):
    """Port: answer bench requests through an engine implementation."""

    def __call__(self, requests: Sequence[BenchRequestV1]) -> list[BenchResponse]:
        """One response per request, in request order.

        Raises:
            BenchContractError: the engine broke the contract.

        """
        ...


def request_for(reference: LabReferenceDayV1, profile_id: str, hijri: Hijri) -> BenchRequestV1:
    """Build the bench request for the city and prayer day of `reference`."""
    return BenchRequestV1(
        schema_version=1,
        observer=Observer(
            latitude_deg=reference.latitude_deg,
            longitude_deg=reference.longitude_deg,
            zone_id=reference.zone_id,
            source="BENCHMARK",
        ),
        profile_id=profile_id,
        day=reference.day,
        hijri=hijri,
    )


def parse_response_line(line: str) -> BenchResponse:
    """Decode one bench stdout line.

    Raises:
        BenchContractError: the line is neither a calculation_trace.v1 nor a bench_failure.v1.

    """
    try:
        document: object = json.loads(line)
        if isinstance(document, dict) and "failure" in document:
            return BenchFailureV1.model_validate(document)
        return CalculationTraceV1.model_validate(document)
    except (json.JSONDecodeError, ValidationError) as error:
        msg = f"bench line is not a valid response: {error}"
        raise BenchContractError(msg) from error


def parse_responses(stdout: str, expected: int) -> list[BenchResponse]:
    """Decode the whole bench stdout, which must hold exactly `expected` lines.

    Raises:
        BenchContractError: wrong line count or an invalid line.

    """
    lines = [line for line in stdout.splitlines() if line.strip()]
    if len(lines) != expected:
        msg = f"bench answered {len(lines)} lines for {expected} requests"
        raise BenchContractError(msg)
    return [parse_response_line(line) for line in lines]


class DartEngineBench:
    """`RunEngineBench` over `dart run geo_salah_core:bench` (DESIGN.md §6.1)."""

    def __init__(self, package_dir: Path) -> None:
        """Run the bench of the Dart package at `package_dir`."""
        self._package_dir = package_dir

    def __call__(self, requests: Sequence[BenchRequestV1]) -> list[BenchResponse]:
        """Pipe every request through one bench process.

        Raises:
            BenchContractError: `dart` is missing, the process failed, or its output breaks the
                contract.

        """
        dart = shutil.which("dart")
        if dart is None:
            msg = "dart is not on PATH"
            raise BenchContractError(msg)
        stdin = "".join(encode_line(request) + "\n" for request in requests)
        completed = subprocess.run(  # noqa: S603 - fixed argv, no shell
            [dart, "run", "geo_salah_core:bench"],
            cwd=self._package_dir,
            input=stdin,
            capture_output=True,
            text=True,
            encoding="utf-8",
            check=False,
        )
        if completed.returncode != 0:
            msg = f"bench exited with {completed.returncode}: {completed.stderr.strip()}"
            raise BenchContractError(msg)
        return parse_responses(completed.stdout, len(requests))
