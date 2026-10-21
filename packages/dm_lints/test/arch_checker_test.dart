import 'package:dm_lints/dm_lints.dart';
import 'package:test/test.dart';

import 'fake_repo.dart';

const _pureSet = [
  'dm_core_types',
  'geo_salah_core',
  'geo_salah_profiles',
  'dm_civil_time',
  'dm_hijri',
  'dm_packages',
];

/// A repository that satisfies every architecture rule.
FakeRepo _cleanRepo() {
  final repo = FakeRepo();
  for (final name in _pureSet) {
    repo
      ..write('packages/$name/pubspec.yaml', 'name: $name\n')
      ..write('packages/$name/lib/$name.dart', 'library;\n');
  }
  repo
    ..write('apps/mobile/pubspec.yaml', 'name: daily_muslim\n')
    ..write(
      'apps/mobile/lib/main.dart',
      "import 'package:flutter/widgets.dart';\n",
    )
    ..write(
      'apps/mobile/lib/features/home/domain/next_prayer.dart',
      "import 'package:dm_core_types/dm_core_types.dart';\n",
    )
    ..write(
      'apps/mobile/lib/features/home/application/read_next_prayer.dart',
      "import '../domain/next_prayer.dart';\n",
    )
    ..write(
      'apps/mobile/lib/features/home/data/drift_next_prayer_store.dart',
      "import 'package:daily_muslim/features/home/domain/next_prayer.dart';\n",
    )
    ..write(
      'apps/mobile/lib/features/home/presentation/home_screen.dart',
      "import 'package:flutter/widgets.dart';\n"
          "import '../application/read_next_prayer.dart';\n",
    );
  return repo;
}

List<Finding> _check(FakeRepo repo) =>
    const ArchChecker(ArchRules.dailyMuslim).check(repo.root).findings;

void main() {
  group('pure Dart set (DESIGN.md §0.2 rule 2)', () {
    test('a clean repository passes', () {
      expect(_check(_cleanRepo()), isEmpty);
    });

    test('a Flutter import in geo_salah_core lib fails with its location', () {
      // Arrange
      final repo = _cleanRepo()
        ..write(
          'packages/geo_salah_core/lib/geo_salah_core.dart',
          "library;\n\nimport 'package:flutter/foundation.dart';\n",
        );

      // Act
      final findings = _check(repo);

      // Assert
      expect(findings, hasLength(1));
      expect(findings.single.rule, 'pure-import');
      expect(
        findings.single.path,
        'packages/geo_salah_core/lib/geo_salah_core.dart',
      );
      expect(findings.single.line, 3);
    });

    test('platform libraries are rejected in lib/', () {
      final repo = _cleanRepo()
        ..write('packages/dm_hijri/lib/src/io.dart', "import 'dart:io';\n")
        ..write('packages/dm_packages/lib/src/ui.dart', "import 'dart:ui';\n")
        ..write(
          'packages/dm_civil_time/lib/src/riverpod.dart',
          "export 'package:flutter_riverpod/flutter_riverpod.dart';\n",
        );

      expect(_check(repo).map((f) => f.rule), everyElement('pure-import'));
      expect(_check(repo), hasLength(3));
    });

    test('a conditional import of a platform library is rejected', () {
      final repo = _cleanRepo()
        ..write(
          'packages/dm_hijri/lib/src/conditional.dart',
          "import 'stub.dart' if (dart.library.io) 'dart:io';\n",
        );

      expect(_check(repo).single.rule, 'pure-import');
    });

    test('dart:io is allowed in bin/ and test/, Flutter is not', () {
      final repo = _cleanRepo()
        ..write('packages/geo_salah_core/bin/bench.dart', "import 'dart:io';\n")
        ..write(
          'packages/geo_salah_core/test/golden_test.dart',
          "import 'dart:io';\nimport 'package:flutter_test/flutter_test.dart';\n",
        );

      final findings = _check(repo);

      expect(findings, hasLength(1));
      expect(
        findings.single.path,
        'packages/geo_salah_core/test/golden_test.dart',
      );
      expect(findings.single.line, 2);
    });

    test('a Flutter dependency in a pure pubspec is rejected', () {
      final repo = _cleanRepo()
        ..write(
          'packages/dm_core_types/pubspec.yaml',
          'name: dm_core_types\n'
              'environment:\n  flutter: 3.47.7\n'
              'dependencies:\n  flutter:\n    sdk: flutter\n  dm_ui: 0.1.0\n'
              'dev_dependencies:\n  flutter_test:\n    sdk: flutter\n',
        );

      final findings = _check(repo);

      expect(findings, hasLength(4));
      expect(findings.map((f) => f.rule), everyElement('pure-pubspec'));
    });

    test('a missing pure package is reported, not skipped', () {
      final repo = FakeRepo()
        ..write('apps/mobile/pubspec.yaml', 'name: daily_muslim\n');

      final findings = _check(repo);

      expect(findings.map((f) => f.rule), everyElement('pure-missing'));
      expect(findings, hasLength(_pureSet.length));
    });
  });

  group('feature layers (DESIGN.md §7.1)', () {
    test('domain must not import Flutter or the platform', () {
      final repo = _cleanRepo()
        ..write(
          'apps/mobile/lib/features/home/domain/clock_port.dart',
          "import 'package:flutter/foundation.dart';\nimport 'dart:io';\n",
        );

      final findings = _check(repo);

      expect(findings.map((f) => f.rule), [
        'layer-domain-platform',
        'layer-domain-platform',
      ]);
    });

    test('domain must not import data, relative or by package URI', () {
      final repo = _cleanRepo()
        ..write(
          'apps/mobile/lib/features/home/domain/bad.dart',
          "import '../data/drift_next_prayer_store.dart';\n"
              "import 'package:daily_muslim/features/qibla/data/x.dart';\n",
        );

      final findings = _check(repo);

      expect(findings.map((f) => f.rule), [
        'layer-direction',
        'layer-direction',
      ]);
      expect(findings.map((f) => f.line), [1, 2]);
    });

    test('presentation must not import data', () {
      final repo = _cleanRepo()
        ..write(
          'apps/mobile/lib/features/home/presentation/bad.dart',
          "import 'package:daily_muslim/features/home/data/x.dart';\n",
        );

      expect(_check(repo).single.rule, 'layer-direction');
    });

    test('application must not import presentation', () {
      final repo = _cleanRepo()
        ..write(
          'apps/mobile/lib/features/home/application/bad.dart',
          "import '../presentation/home_screen.dart';\n",
        );

      expect(_check(repo).single.rule, 'layer-direction');
    });

    test('data must not import application', () {
      final repo = _cleanRepo()
        ..write(
          'apps/mobile/lib/features/home/data/bad.dart',
          "import '../application/read_next_prayer.dart';\n",
        );

      expect(_check(repo).single.rule, 'layer-direction');
    });

    test('files outside a known layer directory are reported', () {
      final repo = _cleanRepo()
        ..write('apps/mobile/lib/features/home/home.dart', 'library;\n')
        ..write('apps/mobile/lib/features/home/utils/x.dart', 'library;\n');

      expect(_check(repo).map((f) => f.rule), [
        'layer-unknown',
        'layer-unknown',
      ]);
    });
  });
}
