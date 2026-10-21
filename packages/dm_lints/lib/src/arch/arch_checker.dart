import 'dart:io';

import 'package:dm_lints/src/arch/arch_rules.dart';
import 'package:dm_lints/src/arch/feature_layer.dart';
import 'package:dm_lints/src/check_report.dart';
import 'package:dm_lints/src/finding.dart';
import 'package:dm_lints/src/source_files.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

/// Enforces [ArchRules] on a repository checkout.
///
/// * The pure Dart set imports nothing from Flutter or the platform in `lib/`
///   and nothing from Flutter in `bin/`, `test/` or elsewhere; its pubspecs
///   depend on no Flutter package (DESIGN.md §0.2 rule 2).
/// * Inside `apps/mobile/lib/features/<feature>/<layer>/`, imports follow
///   presentation → application → domain ← data, and `domain` imports nothing
///   from Flutter or the platform (§7.1).
final class ArchChecker {
  /// Creates a checker for [rules].
  const new(this.rules);

  /// The rules being enforced.
  final ArchRules rules;

  /// Checks the repository rooted at [root].
  CheckReport check(Directory root) {
    final findings = <Finding>[];
    var filesChecked = 0;
    for (final name in rules.pureSetPackages) {
      filesChecked += _checkPurePackage(root, name, findings);
    }
    filesChecked += _checkFeatureLayers(root, findings);
    return CheckReport(filesChecked: filesChecked, findings: findings);
  }

  int _checkPurePackage(Directory root, String name, List<Finding> out) {
    final dir = Directory(p.join(root.path, 'packages', name));
    if (!dir.existsSync()) {
      out.add(
        Finding(
          path: 'packages/$name',
          line: 0,
          rule: 'pure-missing',
          message: 'pure Dart set package "$name" not found',
        ),
      );
      return 0;
    }
    _checkPurePubspec(root, File(p.join(dir.path, 'pubspec.yaml')), out);
    final files = filesBelow(dir, const {'.dart'});
    final lib = p.join(dir.path, 'lib');
    for (final file in files) {
      final inLib = p.isWithin(lib, file.path);
      for (final d in readDirectiveUris(file)) {
        final forbidden = inLib
            ? rules.isFlutterOrPlatformUri(d.uri)
            : rules.isFlutterUri(d.uri);
        if (!forbidden) continue;
        final scope = inLib ? 'Flutter or platform' : 'Flutter';
        out.add(
          Finding(
            path: relativePath(file, root),
            line: d.line,
            rule: 'pure-import',
            message:
                '"$name" is in the pure Dart set and must not import '
                '"${d.uri}" ($scope) — DESIGN.md §0.2 rule 2',
          ),
        );
      }
    }
    return files.length + 1;
  }

  void _checkPurePubspec(Directory root, File pubspec, List<Finding> out) {
    final path = relativePath(pubspec, root);
    if (!pubspec.existsSync()) {
      out.add(
        Finding(
          path: path,
          line: 0,
          rule: 'pure-pubspec',
          message: 'pubspec.yaml is missing',
        ),
      );
      return;
    }
    final doc = loadYaml(pubspec.readAsStringSync());
    if (doc is! YamlMap) return;
    final environment = doc['environment'];
    if (environment is YamlMap && environment.containsKey('flutter')) {
      out.add(
        Finding(
          path: path,
          line: 0,
          rule: 'pure-pubspec',
          message: 'pure Dart set package declares a Flutter SDK constraint',
        ),
      );
    }
    for (final section in const ['dependencies', 'dev_dependencies']) {
      final deps = doc[section];
      if (deps is! YamlMap) continue;
      for (final MapEntry(:key, :value) in deps.entries) {
        final name = '$key';
        final sdkFlutter = value is YamlMap && value['sdk'] == 'flutter';
        if (!sdkFlutter && !rules.isFlutterDependencyName(name)) continue;
        out.add(
          Finding(
            path: path,
            line: 0,
            rule: 'pure-pubspec',
            message:
                '$section must not contain the Flutter package "$name" — '
                'DESIGN.md §0.2 rule 2',
          ),
        );
      }
    }
  }

  int _checkFeatureLayers(Directory root, List<Finding> out) {
    final appDir = Directory(p.join(root.path, rules.appDirectory));
    final pubspec = File(p.join(appDir.path, 'pubspec.yaml'));
    if (!pubspec.existsSync()) {
      out.add(
        Finding(
          path: '${rules.appDirectory}/pubspec.yaml',
          line: 0,
          rule: 'app-missing',
          message: 'app pubspec.yaml not found',
        ),
      );
      return 0;
    }
    final doc = loadYaml(pubspec.readAsStringSync());
    final app = _AppLayout(
      lib: p.join(appDir.path, 'lib'),
      package: doc is YamlMap ? '${doc['name']}' : '',
    );
    final files = filesBelow(Directory(app.features), const {'.dart'});
    for (final file in files) {
      final source = app.layerOf(file.path);
      if (source == null) {
        out.add(
          Finding(
            path: relativePath(file, root),
            line: 0,
            rule: 'layer-unknown',
            message:
                'feature files live in features/<feature>/<layer>/ with '
                'layer ∈ {domain, application, data, presentation} '
                '— DESIGN.md §7.1',
          ),
        );
        continue;
      }
      for (final d in readDirectiveUris(file)) {
        final message = _layerViolation(app, source, file.path, d.uri);
        if (message == null) continue;
        out.add(
          Finding(
            path: relativePath(file, root),
            line: d.line,
            rule: message.rule,
            message: message.text,
          ),
        );
      }
    }
    return files.length + 1;
  }

  ({String rule, String text})? _layerViolation(
    _AppLayout app,
    FeatureLayer source,
    String filePath,
    String uri,
  ) {
    if (source == FeatureLayer.domain && rules.isFlutterOrPlatformUri(uri)) {
      return (
        rule: 'layer-domain-platform',
        text:
            'domain must not import "$uri" (Flutter or platform) '
            '— DESIGN.md §7.1',
      );
    }
    final target = app.resolve(filePath, uri);
    final targetLayer = target == null ? null : app.layerOf(target);
    if (targetLayer == null || source.allowedTargets.contains(targetLayer)) {
      return null;
    }
    return (
      rule: 'layer-direction',
      text:
          '${source.name} must not import ${targetLayer.name} ("$uri"); '
          'allowed: presentation → application → domain ← data '
          '— DESIGN.md §7.1',
    );
  }
}

/// Paths of the app's `lib/` and `lib/features/` directories.
final class _AppLayout {
  new({required this.lib, required this.package})
    : features = p.join(lib, 'features');

  final String lib;
  final String package;
  final String features;

  /// The file [uri] refers to from [fromFile], or `null` when [uri] points
  /// outside the app package.
  String? resolve(String fromFile, String uri) {
    final prefix = 'package:$package/';
    if (uri.startsWith(prefix)) {
      return p.join(lib, uri.substring(prefix.length));
    }
    if (uri.contains(':')) return null;
    return p.normalize(p.join(p.dirname(fromFile), uri));
  }

  /// The layer of [path], or `null` if it is not inside a
  /// `features/<feature>/<layer>/` directory.
  FeatureLayer? layerOf(String path) {
    if (!p.isWithin(features, path)) return null;
    final segments = p.split(p.relative(path, from: features));
    if (segments.length < 3) return null;
    return FeatureLayer.tryParse(segments[1]);
  }
}
