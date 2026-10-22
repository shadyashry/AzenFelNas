import 'package:dm_packages/dm_packages.dart';
import 'package:test/test.dart';

TufTarget _target(String effectiveFrom, {String? rollbackOf}) => TufTarget(
  length: 1,
  sha256: '0' * 64,
  custom: TufTargetCustom(
    schemaVersion: 1,
    payloadFormat: PayloadFormatCode.json,
    compat: const TufCompat(minApp: '1.0.0', minEngineSchema: 1),
    effectiveFrom: effectiveFrom,
    priority: TargetPriorityCode.normal,
    changeNote: const TufChangeNote(ar: 'أ', en: 'a'),
    rollbackOf: rollbackOf,
  ),
);

TufTargetsSigned _targets(Map<String, TufTarget> targets) => TufTargetsSigned(
  sequence: 1,
  expires: '2099-01-01T00:00:00Z',
  targets: targets,
);

List<String> _select(
  Map<String, TufTarget> targets, {
  Map<PackageType, ActivePackage> active = const {},
  Set<String> refused = const {},
}) => [
  for (final choice in const SelectTargets()(
    _targets(targets),
    active: active,
    refusedNames: refused,
    todayUtc: '2026-10-22',
  ))
    choice.name,
];

ActivePackage _active(PackageType type, String version) => ActivePackage(
  type: type,
  version: version,
  sequence: 1,
  sha256: 'x',
  source: PackageSource.downloaded,
  activatedUtcMs: 0,
);

void main() {
  group('target choice per type (REQ-DIST-002, §15 D74)', () {
    test('the latest effectiveFrom in effect wins', () {
      expect(
        _select({
          'hijri/2026.1.0': _target('2026-01-01'),
          'hijri/2026.2.0': _target('2026-09-01'),
          'hijri/2026.3.0': _target('2026-12-01'),
        }),
        ['hijri/2026.2.0'],
      );
    });

    test('a target effective today is in effect', () {
      expect(_select({'hijri/2026.4.0': _target('2026-10-22')}), [
        'hijri/2026.4.0',
      ]);
    });

    test('equal effectiveFrom: the greater version in byte order', () {
      expect(
        _select({
          'tzdata/2026d': _target('2026-05-01'),
          'tzdata/2026e': _target('2026-05-01'),
        }),
        ['tzdata/2026e'],
      );
    });

    test('a version another target rolls back is never chosen', () {
      expect(
        _select({
          'gazetteer/1.0.0': _target('2026-01-01'),
          'gazetteer/2.0.0': _target('2026-10-01'),
          'gazetteer/2.0.1': _target('2026-10-01', rollbackOf: '2.0.0'),
        }),
        ['gazetteer/2.0.1'],
      );
    });

    test('a refused version is skipped for an older one', () {
      expect(
        _select(
          {
            'gazetteer/1.0.0': _target('2026-01-01'),
            'gazetteer/2.0.0': _target('2026-10-01'),
          },
          refused: {'gazetteer/2.0.0'},
        ),
        ['gazetteer/1.0.0'],
      );
    });

    test('nothing is chosen when the winner is already active', () {
      expect(
        _select(
          {'gazetteer/1.0.0': _target('2026-01-01')},
          active: {
            PackageType.gazetteer: _active(PackageType.gazetteer, '1.0.0'),
          },
        ),
        isEmpty,
      );
    });

    test('unknown types are ignored; choices are ordered by type', () {
      expect(
        _select({
          'tzdata/2026e': _target('2026-01-01'),
          'future_type/1.0.0': _target('2026-01-01'),
          'gazetteer/1.0.0': _target('2026-01-01'),
        }),
        ['gazetteer/1.0.0', 'tzdata/2026e'],
      );
    });
  });
}
