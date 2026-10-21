/// The four TUF-lite metadata roles (Appendix C, REQ-DIST-001).
enum MetadataRole {
  /// `root.json`: trusted keys and thresholds.
  root,

  /// `targets.json`: the content-addressed packages.
  targets,

  /// `snapshot.json`: pins `targets.json`.
  snapshot,

  /// `timestamp.json`: pins `snapshot.json`; expires within 7 days.
  timestamp,
}
