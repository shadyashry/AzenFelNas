/// Who stands behind a prayer profile (§6.2, ADR-007). Only [government]
/// and [recognizedBody] profiles can be `Authority aligned` (REQ-DOM-050).
enum AuthorityType {
  /// A government body.
  government,

  /// A recognised religious body.
  recognizedBody,

  /// A community convention.
  communityConvention,

  /// The engine's fallback profile (`engine.default`).
  engineDefault,
}
