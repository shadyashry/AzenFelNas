/// The engine's version (`Provenance.engineVersion`, §6.2).
///
/// It equals the `geo_salah_core` package version and is part of every
/// Calculation ID (§6.4 ¶11), so a release that can change any output bumps
/// it.
abstract final class EngineVersion {
  /// The current engine version, `MAJOR.MINOR.PATCH`.
  static const String current = '0.4.0';

  /// The profile schema the engine evaluates: a profile whose
  /// `compatibility.minEngineSchema` exceeds it cannot be loaded
  /// (REQ-PKG-006, Appendix A).
  static const int profileSchema = 1;
}
