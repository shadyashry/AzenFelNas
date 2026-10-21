/// What the architecture lint enforces (DESIGN.md §0.2 rule 2, §7.1, §12).
final class ArchRules {
  /// Creates a rule set.
  const new({
    required this.pureSetPackages,
    required this.flutterWorkspacePackages,
    required this.platformLibraries,
    required this.appDirectory,
  });

  /// The rules of this repository.
  static const ArchRules dailyMuslim = ArchRules(
    pureSetPackages: [
      'dm_core_types',
      'geo_salah_core',
      'geo_salah_profiles',
      'dm_civil_time',
      'dm_hijri',
      'dm_packages',
    ],
    flutterWorkspacePackages: ['dm_contracts', 'dm_ui'],
    platformLibraries: [
      'dart:ffi',
      'dart:html',
      'dart:io',
      'dart:isolate',
      'dart:js',
      'dart:js_interop',
      'dart:js_interop_unsafe',
      'dart:js_util',
      'dart:mirrors',
      'dart:ui',
    ],
    appDirectory: 'apps/mobile',
  );

  /// Packages under `packages/` that import nothing from Flutter or the
  /// platform in `lib/`, and nothing from Flutter anywhere.
  final List<String> pureSetPackages;

  /// Workspace packages that depend on Flutter.
  final List<String> flutterWorkspacePackages;

  /// `dart:` libraries the pure set's `lib/` must not import.
  final List<String> platformLibraries;

  /// Repository-relative directory of the Flutter app.
  final String appDirectory;

  /// Whether [uri] belongs to Flutter (SDK, `flutter_*` packages or Flutter
  /// workspace packages).
  bool isFlutterUri(String uri) =>
      uri == 'dart:ui' ||
      uri.startsWith('package:flutter/') ||
      uri.startsWith('package:flutter_') ||
      uri.startsWith('package:sky_engine/') ||
      flutterWorkspacePackages.any((p) => uri.startsWith('package:$p/'));

  /// Whether [uri] is a Flutter or platform library.
  bool isFlutterOrPlatformUri(String uri) =>
      isFlutterUri(uri) || platformLibraries.contains(uri);

  /// Whether a pubspec dependency called [name] is a Flutter package.
  bool isFlutterDependencyName(String name) =>
      name == 'flutter' ||
      name == 'sky_engine' ||
      name.startsWith('flutter_') ||
      flutterWorkspacePackages.contains(name);
}
