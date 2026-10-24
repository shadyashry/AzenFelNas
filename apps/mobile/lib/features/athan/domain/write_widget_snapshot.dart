/// A `snapshot.v1` document encoded as JSON (§7.7, Appendix I), as the
/// native snapshot store receives it. Built by `RefreshWidgetSnapshot` only.
extension type const EncodedSnapshot(String json);

/// Hands the widget snapshot to the native layer (pigeon `writeSnapshot`).
/// The host validates the document, replaces its stored snapshot whole
/// (write, then rename) and asks its widgets to redraw, so a widget reads
/// either the old snapshot or the new one, never a mix. Widgets never
/// recalculate (REQ-WID-001).
abstract interface class WriteWidgetSnapshot {
  /// True when the host stored [snapshot]; false when it refused it or no
  /// host answered, and its previous snapshot stays. Never throws.
  Future<bool> call(EncodedSnapshot snapshot);
}
