import 'dart:convert';
import 'dart:io';

import 'package:geo_salah_core/geo_salah_core.dart';
import 'package:geo_salah_core/src/bench/bench_failure_document.dart';
import 'package:geo_salah_core/src/bench/bench_profiles.dart';
import 'package:geo_salah_core/src/bench/bench_request_document.dart';
import 'package:geo_salah_core/src/bench/bench_runner.dart';
import 'package:geo_salah_core/src/bench/bench_time_zones.dart';
import 'package:test/test.dart';

import '../support/fixtures.dart';

/// Fake [BenchTimeZones] port: Apia skipping 2011-12-30, as in the TZDB.
final class _ApiaTimeZones implements BenchTimeZones {
  static final int _switchUtcMs = DateTime.utc(
    2011,
    12,
    30,
    10,
  ).millisecondsSinceEpoch;

  @override
  String get version => '2011n';

  @override
  bool supports(String zoneId) => zoneId == 'Pacific/Apia';

  @override
  int offsetSecondsAt(String zoneId, int utcMs) =>
      (utcMs < _switchUtcMs ? -10 : 14) * 3600;
}

Map<String, Object?> _request({
  String zoneId = 'Africa/Cairo',
  String profileId = 'engine.default',
  String day = '2026-03-20',
  double lat = 30.04,
  double lon = 31.24,
}) => {
  'schemaVersion': 1,
  'observer': {
    'latitudeDeg': lat,
    'longitudeDeg': lon,
    'zoneId': zoneId,
    'source': 'BENCHMARK',
  },
  'profileId': profileId,
  'day': day,
  'hijri': {
    'dateAtDawn': {'year': 1447, 'month': 10, 'day': 1},
    'dateAtNight': {'year': 1447, 'month': 10, 'day': 2},
    'confidence': 'USER_OVERRIDE',
  },
};

String _failureCode(Map<String, Object?> answer) =>
    BenchFailureDocument.fromJson(answer).failure.code.wire;

List<File> _fixtures(String schema, String kind) =>
    Directory('../../schemas/fixtures/$schema/$kind')
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.json'))
        .toList()
      ..sort((a, b) => a.path.compareTo(b.path));

void main() {
  group('BenchRunner (§15 D29)', () {
    const runner = BenchRunner();

    test('answers a request with a calculation trace that echoes its Hijri '
        'state in inputs.hijri', () {
      final answer = runner.answer(_request());
      final trace = CalculationTraceDocument.fromJson(answer);
      expect(
        trace.inputs.hijri.toJson(),
        asJsonObject(_request()['hijri']),
      );
      expect(
        trace.provenance.hijriConfidence,
        HijriConfidenceCode.userOverride,
      );
      expect(trace.provenance.profileId, 'engine.default');
      expect(trace.times.map((t) => t.event), [
        PrayerEventCode.sunrise,
        PrayerEventCode.dhuhr,
        PrayerEventCode.maghrib,
      ]);
    });

    test('answers an unknown profile with PROFILE_NOT_FOUND (REQ-ERR-002)', () {
      expect(
        _failureCode(runner.answer(_request(profileId: 'zz.fixture.none'))),
        'PROFILE_NOT_FOUND',
      );
    });

    test('answers an unknown zone with TZ_UNRESOLVED (REQ-ERR-002)', () {
      expect(
        _failureCode(runner.answer(_request(zoneId: 'Etc/GMT-3'))),
        'TZ_UNRESOLVED',
      );
    });

    test('answers an engine failure with its Appendix J code '
        '(REQ-ERR-002)', () {
      final runner = BenchRunner(
        profiles: {
          'engine.default': BenchProfiles.engineDefault.copyWith(
            elevationPolicy: HorizonElevationPolicy.authorityTable,
          ),
        },
      );
      expect(
        _failureCode(runner.answer(_request())),
        'ENGINE_UNSUPPORTED_POLICY',
      );
    });

    test('answers a calendar day the zone skipped with TZ_UNRESOLVED '
        '(§15 D36)', () {
      final runner = BenchRunner(timeZones: _ApiaTimeZones());
      Map<String, Object?> apia(String day) => runner.answer(
        _request(zoneId: 'Pacific/Apia', day: day, lat: -13.83, lon: -171.76),
      );
      expect(_failureCode(apia('2011-12-30')), 'TZ_UNRESOLVED');
      expect(
        CalculationTraceDocument.fromJson(apia('2011-12-31')).times,
        hasLength(3),
      );
    });

    test('rejects every invalid bench_request.v1 fixture as a contract '
        'error', () {
      final files = _fixtures('bench_request', 'invalid');
      expect(files, isNotEmpty);
      for (final file in files) {
        final json = asJsonObject(jsonDecode(file.readAsStringSync()));
        expect(
          () => runner.answer(json),
          throwsFormatException,
          reason: file.path,
        );
      }
    });

    test('rejects a schemaVersion other than 1 and a day after year 5999 '
        'as contract errors', () {
      expect(
        () => runner.answer({..._request(), 'schemaVersion': 2}),
        throwsFormatException,
      );
      expect(
        () => runner.answer(_request(day: '6000-01-01')),
        throwsFormatException,
      );
    });
  });

  group('bench wire models (ADR-023)', () {
    roundTripValidFixtures<BenchRequestDocument>(
      'bench_request',
      decode: (json) => BenchRequestDocument.fromJson(asJsonObject(json)),
      encode: (model) => model.toJson(),
    );
    roundTripValidFixtures<BenchFailureDocument>(
      'bench_failure',
      decode: (json) => BenchFailureDocument.fromJson(asJsonObject(json)),
      encode: (model) => model.toJson(),
    );

    test('rejects an unknown failure code (REQ-ERR-002)', () {
      final file = File(
        '../../schemas/fixtures/bench_failure/invalid/'
        'REQ-ERR-002_unknown_failure_code.json',
      );
      expect(
        () => BenchFailureDocument.fromJson(
          asJsonObject(jsonDecode(file.readAsStringSync())),
        ),
        throwsA(anything),
      );
    });
  });
}
