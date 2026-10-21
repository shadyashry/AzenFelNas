"""Builders of wire records for comparator tests (shape data, never prayer profiles)."""

import json
from collections.abc import Mapping
from typing import Literal

from dm_lab.bench import request_for
from dm_lab.compare import BenchCase
from dm_lab.schema.bench_request_v1 import Hijri
from dm_lab.schema.calculation_trace_v1 import CalculationTraceV1
from dm_lab.schema.lab_reference_v1 import LabReferenceDayV1

type Origin = Literal["PRIMARY", "FALLBACK", "NO_EVENT"]

# ADR-016 tabular Hijri state of 2026-03-20 (2 and 3 Shawwal 1447); test_hijri.py checks it.
HIJRI_2026_03_20: dict[str, object] = {
    "dateAtDawn": {"year": 1447, "month": 10, "day": 2},
    "dateAtNight": {"year": 1447, "month": 10, "day": 3},
    "confidence": "EXPECTED",
}

TRANSIT_MS = 1_774_000_800_000
SUNRISE_MS = TRANSIT_MS - 21_600_000
SUNSET_MS = TRANSIT_MS + 21_600_000


def reference_day(
    *,
    sunrise: Mapping[str, object] | None = None,
    sunset: Mapping[str, object] | None = None,
) -> LabReferenceDayV1:
    """A reference line for zz_city on 2026-03-20; sunrise/sunset events can be replaced."""
    return LabReferenceDayV1.model_validate(
        {
            "schemaVersion": 1,
            "caseId": "zz_city/2026-03-20",
            "cityId": "zz_city",
            "latitudeDeg": 12.34,
            "longitudeDeg": 45.67,
            "zoneId": "Etc/GMT-3",
            "day": "2026-03-20",
            "tags": ["MARCH_EQUINOX"],
            "events": [
                sunrise
                or {
                    "kind": "PRIMARY",
                    "event": "SUNRISE",
                    "referenceUtcMs": SUNRISE_MS,
                    "toleranceMs": 300,
                    "rateDegPerS": 0.0035,
                },
                {
                    "kind": "PRIMARY",
                    "event": "TRANSIT",
                    "referenceUtcMs": TRANSIT_MS,
                    "toleranceMs": 240,
                    "rateDegPerS": 0.004167,
                },
                sunset
                or {
                    "kind": "PRIMARY",
                    "event": "SUNSET",
                    "referenceUtcMs": SUNSET_MS,
                    "toleranceMs": 300,
                    "rateDegPerS": -0.0035,
                },
            ],
        },
    )


def _time(event: str, origin: Origin, raw_ms: int | None, reason: str) -> dict[str, object]:
    time: dict[str, object] = {"event": event, "flags": [], "adjustmentTrace": []}
    if origin == "NO_EVENT":
        time["origin"] = {"kind": "NO_EVENT", "reason": reason}
        time["confidence"] = {"kind": "UNKNOWN", "reasonCode": reason}
        return time
    if origin == "FALLBACK":
        time["origin"] = {"kind": "FALLBACK", "method": "anglePortion"}
        time["confidence"] = {"kind": "ESTIMATED", "rangeMinutes": 5}
    else:
        time["origin"] = {"kind": "PRIMARY"}
        time["confidence"] = {"kind": "CALCULATED"}
    time["rawUtcMs"] = raw_ms
    time["displayedUtcMs"] = raw_ms
    time["dayOffset"] = 0
    return time


def trace_for(
    reference: LabReferenceDayV1,
    *,
    sunrise: tuple[Origin, int | None] = ("PRIMARY", SUNRISE_MS),
    dhuhr: tuple[Origin, int | None] = ("PRIMARY", TRANSIT_MS),
    maghrib: tuple[Origin, int | None] = ("PRIMARY", SUNSET_MS),
    no_event_reason: str = "POLAR_DAY",
) -> CalculationTraceV1:
    """An engine.default trace answering `reference`, with the given origins and raw instants."""
    trace_day = reference.day
    return CalculationTraceV1.model_validate(
        {
            "schemaVersion": 1,
            "calculationId": "GS-ABCDEFGHIJ234567",
            "day": trace_day,
            "inputs": {
                "lat": round(reference.latitude_deg, 6),
                "lon": round(reference.longitude_deg, 6),
                "zoneId": reference.zone_id,
                "day": trace_day,
                "profileId": "engine.default",
                "profileVersion": "2026.10.1",
                "hijri": HIJRI_2026_03_20,
            },
            "provenance": {
                "engineVersion": "0.1.0",
                "deltaTModel": "espenak-meeus-2006",
                "profileId": "engine.default",
                "profileVersion": "2026.10.1",
                "tzdbVersion": "2026e",
                "inputsHash": "e" * 64,
                "hijriConfidence": "EXPECTED",
            },
            "times": [
                _time("SUNRISE", *sunrise, no_event_reason),
                _time("DHUHR", *dhuhr, no_event_reason),
                _time("MAGHRIB", *maghrib, no_event_reason),
            ],
        },
    )


def case_for(reference: LabReferenceDayV1) -> BenchCase:
    """The case of `reference`: its engine.default request with the 2026-03-20 Hijri state."""
    return BenchCase(
        reference,
        request_for(reference, "engine.default", Hijri.model_validate(HIJRI_2026_03_20)),
    )


def with_time(
    trace: CalculationTraceV1, event: str, changes: Mapping[str, object]
) -> CalculationTraceV1:
    """`trace` with the wire fields in `changes` replaced (None deletes) in the time of `event`."""
    document = json.loads(trace.model_dump_json(exclude_none=True))
    for time in document["times"]:
        if time["event"] == event:
            for key, value in changes.items():
                if value is None:
                    time.pop(key, None)
                else:
                    time[key] = value
    return CalculationTraceV1.model_validate(document)
