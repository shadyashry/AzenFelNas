/// A Clean Architecture layer inside `apps/mobile/lib/features/<feature>/`.
///
/// Dependency direction is presentation → application → domain ← data
/// (DESIGN.md §7.1).
enum FeatureLayer {
  /// Entities, sealed types and ports. Pure Dart; never Flutter.
  domain,

  /// Use cases and orchestration.
  application,

  /// Port implementations: drift, package client, platform adapters.
  data,

  /// Widgets and Riverpod providers.
  presentation;

  /// Layers a file in this layer may import.
  Set<FeatureLayer> get allowedTargets => switch (this) {
    domain => const {domain},
    application => const {domain, application},
    data => const {domain, data},
    presentation => const {domain, application, presentation},
  };

  /// The layer whose directory is called [directoryName], or `null`.
  static FeatureLayer? tryParse(String directoryName) =>
      values.asNameMap()[directoryName];
}
