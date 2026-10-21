/// The governance status of a prayer profile (§6.2, Appendix A, ADR-008).
enum ProfileStatus {
  /// Illustrative data, loadable on `dev`/`lab` only (Appendix E).
  draftUnverified,

  /// Proposed for approval.
  candidate,

  /// Approved by the religious and accuracy reviewers.
  approved,

  /// No longer in effect.
  retired,
}
