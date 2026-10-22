import 'package:dm_core_types/dm_core_types.dart';
import 'package:geo_salah_core/src/api/calculate_day.dart';
import 'package:geo_salah_core/src/bench/bench_failure_detail_document.dart';
import 'package:geo_salah_core/src/bench/bench_failure_document.dart';
import 'package:geo_salah_core/src/bench/bench_observer_document.dart';
import 'package:geo_salah_core/src/bench/bench_request_document.dart';
import 'package:geo_salah_core/src/bench/bench_time_zones.dart';
import 'package:geo_salah_core/src/bench/observer_source_code.dart';
import 'package:geo_salah_core/src/model/hijri_confidence.dart';
import 'package:geo_salah_core/src/model/hijri_date.dart';
import 'package:geo_salah_core/src/model/hijri_state.dart';
import 'package:geo_salah_core/src/model/observer.dart';
import 'package:geo_salah_core/src/model/observer_source.dart';
import 'package:geo_salah_core/src/model/prayer_profile.dart';
import 'package:geo_salah_core/src/trace/calculation_inputs.dart';
import 'package:geo_salah_core/src/trace/calculation_trace_writer.dart';
import 'package:geo_salah_core/src/trace/hijri_confidence_code.dart';
import 'package:geo_salah_core/src/trace/hijri_date_document.dart';
import 'package:geo_salah_core/src/trace/trace_hijri_inputs_document.dart';
import 'package:json_annotation/json_annotation.dart';

/// Answers one `bench_request.v1` line of the lab bench contract (§15 D29).
///
/// The answer is a `calculation_trace.v1` object, or a `bench_failure.v1`
/// object with an Appendix J code: `PROFILE_NOT_FOUND` for an unknown
/// profile, `TZ_UNRESOLVED` for an unknown zone or a calendar day the zone
/// skipped (§15 D36), and the engine failure's code otherwise. The request's
/// Hijri state is used as given and echoed in `inputs.hijri`. A request that
/// breaks the contract (wrong shape, `schemaVersion ≠ 1`, an impossible
/// date or one outside the engine's years) is the caller's error: [answer]
/// throws [FormatException]. Pure and deterministic.
final class BenchRunner {
  /// A runner over [profiles] (by id, from the bench profile data, §15 D48)
  /// and [timeZones]: the pinned TZDB of `dm_civil_time`, which `bin/bench`
  /// loads (§15 D68).
  const new({required this.profiles, required this.timeZones});

  static const CalculateDay _calculateDay = CalculateDay();
  static const CalculationTraceWriter _writer = CalculationTraceWriter();

  /// The zones requests may name.
  final BenchTimeZones timeZones;

  /// The profiles requests may name, by id.
  final Map<String, PrayerProfile> profiles;

  /// The answer to the request [json], as a JSON object.
  Map<String, Object?> answer(Map<String, Object?> json) {
    final request = _decode(json);
    final day = _day(request.day);
    final observer = _observer(request.observer);
    final hijri = _hijri(request.hijri);
    final profile = profiles[request.profileId];
    if (profile == null) {
      return _failure(FailureCode.profileNotFound, request.profileId);
    }
    final zoneId = observer.zoneId;
    if (!timeZones.supports(zoneId)) {
      return _failure(FailureCode.tzUnresolved, 'unsupported zone $zoneId');
    }
    final result = _calculateDay(
      observer: observer,
      profile: profile,
      day: day,
      tzdb: timeZones,
      hijri: hijri,
    );
    return switch (result) {
      Err(:final failure) => _failure(failure.code, failure.detail),
      Ok(:final value) when value.times.isEmpty => _failure(
        FailureCode.tzUnresolved,
        'calendar day $day does not exist in $zoneId',
      ),
      Ok(:final value) =>
        _writer
            .write(
              value,
              CalculationInputs.of(
                observer: observer,
                profile: profile,
                day: day,
                hijri: hijri,
              ),
            )
            .toJson(),
    };
  }

  static BenchRequestDocument _decode(Map<String, Object?> json) {
    final BenchRequestDocument request;
    try {
      request = BenchRequestDocument.fromJson(json);
    } on CheckedFromJsonException catch (e) {
      throw FormatException('Not a bench_request.v1 line: ${e.message}');
    }
    if (request.schemaVersion != 1) {
      throw FormatException(
        'Unsupported schemaVersion ${request.schemaVersion}',
      );
    }
    return request;
  }

  static CivilDate _day(String text) {
    final day = CivilDate.tryParse(text);
    if (day == null || day.year > CalculateDay.lastYear) {
      throw FormatException('Day outside the engine domain: $text');
    }
    return day;
  }

  static Observer _observer(BenchObserverDocument observer) {
    final lat = observer.latitudeDeg;
    final lon = observer.longitudeDeg;
    if (!(lat >= -90 && lat <= 90 && lon >= -180 && lon <= 180)) {
      throw const FormatException('Observer coordinates out of range');
    }
    return Observer(
      latitudeDeg: lat,
      longitudeDeg: lon,
      zoneId: observer.zoneId,
      source: switch (observer.source) {
        ObserverSourceCode.device => ObserverSource.device,
        ObserverSourceCode.pinned => ObserverSource.pinned,
        ObserverSourceCode.manual => ObserverSource.manual,
        ObserverSourceCode.mosque => ObserverSource.mosque,
        ObserverSourceCode.benchmark => ObserverSource.benchmark,
      },
      horizontalAccuracyM: observer.horizontalAccuracyM,
    );
  }

  static HijriState _hijri(TraceHijriInputsDocument hijri) => HijriState(
    dateAtDawn: _hijriDate(hijri.dateAtDawn),
    dateAtNight: _hijriDate(hijri.dateAtNight),
    confidence: switch (hijri.confidence) {
      HijriConfidenceCode.confirmed => HijriConfidence.confirmed,
      HijriConfidenceCode.expected => HijriConfidence.expected,
      HijriConfidenceCode.userOverride => HijriConfidence.userOverride,
    },
  );

  static HijriDate _hijriDate(HijriDateDocument date) =>
      HijriDate(year: date.year, month: date.month, day: date.day);

  static Map<String, Object?> _failure(FailureCode code, String detail) =>
      BenchFailureDocument(
        schemaVersion: 1,
        failure: BenchFailureDetailDocument(code: code, detail: detail),
      ).toJson();
}
