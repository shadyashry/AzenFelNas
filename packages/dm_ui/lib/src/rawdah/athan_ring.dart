/// What the Athan tab's ring says (P2 honest alarm): never "ready" unless
/// the health state machine says so.
enum AthanRing {
  /// No evidence yet: a hollow gold ring.
  unknown,

  /// Ready: a filled gold dot.
  ready,

  /// Needs attention: a carpet-red dot.
  attention,
}
