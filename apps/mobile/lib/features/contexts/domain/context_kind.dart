/// Kind of a stored location context (§7.3 `location_contexts.kind`).
enum ContextKind {
  /// Follows the device location; the only kind the resolver writes.
  current('current'),

  /// A snapshot of a current context the user chose to keep.
  pinned('pinned'),

  /// A place the user chose by gazetteer search or typed coordinates.
  manual('manual');

  /// The kind stored as [wire].
  new(this.wire);

  /// Column value.
  final String wire;

  /// Whether the user chose this context, so the resolver never replaces it
  /// (ADR-014, REQ-PRIV-002).
  bool get isUserChosen => switch (this) {
    ContextKind.current => false,
    ContextKind.pinned || ContextKind.manual => true,
  };

  /// The kind stored as [wire], or `null` for an unknown value.
  static ContextKind? fromWire(String wire) => _byWire[wire];

  static final Map<String, ContextKind> _byWire = {
    for (final kind in values) kind.wire: kind,
  };
}

/// The kinds a user creates: never [ContextKind.current] (REQ-PRIV-002).
enum ChosenKind {
  /// See [ContextKind.pinned].
  pinned(ContextKind.pinned),

  /// See [ContextKind.manual].
  manual(ContextKind.manual);

  /// The chosen kind stored as [kind].
  new(this.kind);

  /// The stored kind.
  final ContextKind kind;
}
