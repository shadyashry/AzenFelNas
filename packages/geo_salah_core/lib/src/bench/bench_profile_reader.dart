import 'package:geo_salah_core/src/model/authority_type.dart';
import 'package:geo_salah_core/src/model/event_rule.dart';
import 'package:geo_salah_core/src/model/horizon_elevation_policy.dart';
import 'package:geo_salah_core/src/model/prayer_event.dart';
import 'package:geo_salah_core/src/model/prayer_profile.dart';
import 'package:geo_salah_core/src/model/profile_status.dart';
import 'package:geo_salah_core/src/model/rounding_mode.dart';

/// Reads a bench stand-in profile (§15 D48): an Appendix A
/// `prayer_profile.v1` document cut down to the members the S06 engine
/// reads — `profileId`, `schemaVersion`, `version`, `status`,
/// `authority.type`, `rules`, `horizon`, `rounding`, `adjustments`
/// (`perEventMinutes`, `maxAbsMinutes`; `ramadan` must be empty until S08)
/// and `evidence.benchmarkReportId`.
///
/// Every value comes from the data file (§0.2 rule 1); an absent member is
/// the Appendix A absence (no offset, no override), never an invented
/// value. Unknown members, wrong types and unknown codes throw
/// [FormatException]. Used by the bench, the golden tool and the tests only;
/// S07's `geo_salah_profiles` loader replaces it. Pure.
abstract final class BenchProfileReader {
  static const Set<String> _members = {
    'profileId',
    'schemaVersion',
    'version',
    'status',
    'authority',
    'rules',
    'horizon',
    'rounding',
    'adjustments',
    'evidence',
  };

  /// The profile of the decoded JSON document [json].
  static PrayerProfile read(Object? json) {
    final document = _object(json, 'profile');
    _onlyKnown(document, _members, 'profile');
    if (document['schemaVersion'] != 1) {
      throw const FormatException('profile schemaVersion must be 1');
    }
    final adjustments = switch (document['adjustments']) {
      null => const <String, Object?>{},
      final Object? value => _object(value, 'adjustments'),
    };
    _onlyKnown(adjustments, const {
      'perEventMinutes',
      'maxAbsMinutes',
      'ramadan',
    }, 'adjustments');
    if (_object(
      adjustments['ramadan'] ?? const <String, Object?>{},
      'ramadan',
    ).isNotEmpty) {
      throw const FormatException('Ramadan rules arrive in S08');
    }
    final rounding = _object(document['rounding'], 'rounding');
    return PrayerProfile(
      profileId: _string(document['profileId'], 'profileId'),
      version: _string(document['version'], 'version'),
      status: _status(document['status']),
      authorityType: _authority(_object(document['authority'], 'authority')),
      rules: _rules(_object(document['rules'], 'rules')),
      roundingDefault: _rounding(rounding['default']),
      roundingOverrides: {
        for (final MapEntry(:key, :value) in rounding.entries)
          if (key != 'default') _event(key): _rounding(value),
      },
      perEventMinutes: {
        for (final MapEntry(:key, :value) in _object(
          adjustments['perEventMinutes'] ?? const <String, Object?>{},
          'perEventMinutes',
        ).entries)
          _event(key): _int(value, 'perEventMinutes.$key'),
      },
      maxAbsMinutes: switch (adjustments['maxAbsMinutes']) {
        null => 0,
        final Object? value => _int(value, 'maxAbsMinutes'),
      },
      elevationPolicy: _elevationPolicy(
        _object(document['horizon'], 'horizon')['elevationPolicy'],
      ),
      benchmarkReportId: switch (document['evidence']) {
        null => null,
        final Object? value => switch (_object(
          value,
          'evidence',
        )['benchmarkReportId']) {
          null => null,
          final Object? id => _string(id, 'benchmarkReportId'),
        },
      },
    );
  }

  static Map<PrayerEvent, EventRule> _rules(Map<String, Object?> rules) => {
    for (final MapEntry(:key, :value) in rules.entries)
      if (value != null) _event(key): _rule(_object(value, 'rules.$key'), key),
  };

  static EventRule _rule(Map<String, Object?> rule, String event) =>
      switch (rule) {
        {'type': 'solarAltitude', 'degrees': final num degrees}
            when rule.length == 2 =>
          EventRule.solarAltitude(degrees: degrees.toDouble()),
        {'type': 'transit'} when rule.length == 1 => const EventRule.transit(),
        {'type': 'transit', 'offsetMinutes': final int minutes}
            when rule.length == 2 =>
          EventRule.transit(offset: Duration(minutes: minutes)),
        {'type': 'shadowFactor', 'k': final int k} when rule.length == 2 =>
          EventRule.shadowFactor(k: k),
        {'type': 'horizon'} when _horizonOnly(rule) => _horizon(rule),
        {
          'type': 'intervalAfter',
          'base': final String base,
          'minutes': final int minutes,
        }
            when rule.length == 3 =>
          EventRule.intervalAfter(
            base: _event(base),
            duration: Duration(minutes: minutes),
          ),
        {
          'type': 'intervalBefore',
          'base': final String base,
          'minutes': final int minutes,
        }
            when rule.length == 3 =>
          EventRule.intervalBefore(
            base: _event(base),
            duration: Duration(minutes: minutes),
          ),
        _ => throw FormatException('Not an Appendix A rule for $event: $rule'),
      };

  /// An absent member keeps the §6.2 [HorizonRule] default (ADR-003).
  static EventRule _horizon(Map<String, Object?> rule) {
    const defaults = HorizonRule();
    return EventRule.horizon(
      refractionArcmin:
          _optionalDouble(rule['refractionArcmin']) ??
          defaults.refractionArcmin,
      semidiameterArcmin:
          _optionalDouble(rule['semidiameterArcmin']) ??
          defaults.semidiameterArcmin,
    );
  }

  static bool _horizonOnly(Map<String, Object?> rule) => rule.keys.every(
    (key) => const {
      'type',
      'refractionArcmin',
      'semidiameterArcmin',
    }.contains(key),
  );

  static PrayerEvent _event(String name) =>
      PrayerEvent.values.asNameMap()[name] ??
      (throw FormatException('Unknown event $name'));

  static ProfileStatus _status(Object? code) => switch (code) {
    'DRAFT_UNVERIFIED' => ProfileStatus.draftUnverified,
    'CANDIDATE' => ProfileStatus.candidate,
    'APPROVED' => ProfileStatus.approved,
    'RETIRED' => ProfileStatus.retired,
    _ => throw FormatException('Unknown status $code'),
  };

  static AuthorityType _authority(Map<String, Object?> authority) =>
      switch (authority['type']) {
        'GOVERNMENT' => AuthorityType.government,
        'RECOGNIZED_BODY' => AuthorityType.recognizedBody,
        'COMMUNITY_CONVENTION' => AuthorityType.communityConvention,
        'ENGINE_DEFAULT' => AuthorityType.engineDefault,
        final Object? code => throw FormatException('Unknown authority $code'),
      };

  static RoundingMode _rounding(Object? code) => switch (code) {
    'ceil' => RoundingMode.ceil,
    'floor' => RoundingMode.floor,
    'nearest' => RoundingMode.nearest,
    _ => throw FormatException('Unknown rounding mode $code'),
  };

  static HorizonElevationPolicy _elevationPolicy(Object? code) =>
      switch (code) {
        'NONE' => HorizonElevationPolicy.none,
        'ABOVE_LOCAL_TERRAIN' => HorizonElevationPolicy.aboveLocalTerrain,
        'AUTHORITY_TABLE' => HorizonElevationPolicy.authorityTable,
        _ => throw FormatException('Unknown elevation policy $code'),
      };

  static Map<String, Object?> _object(Object? json, String what) =>
      switch (json) {
        final Map<String, Object?> object => object,
        _ => throw FormatException('$what must be a JSON object'),
      };

  static void _onlyKnown(
    Map<String, Object?> object,
    Set<String> known,
    String what,
  ) {
    for (final key in object.keys) {
      if (!known.contains(key)) {
        throw FormatException('Unknown member $what.$key');
      }
    }
  }

  static String _string(Object? json, String what) => switch (json) {
    final String text when text.isNotEmpty => text,
    _ => throw FormatException('$what must be a non-empty string'),
  };

  static int _int(Object? json, String what) => switch (json) {
    final int value => value,
    _ => throw FormatException('$what must be an integer'),
  };

  static double? _optionalDouble(Object? json) => switch (json) {
    null => null,
    final num value => value.toDouble(),
    _ => throw FormatException('Not a number: $json'),
  };
}
