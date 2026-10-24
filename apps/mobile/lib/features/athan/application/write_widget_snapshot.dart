import 'package:dm_contracts/dm_contracts.dart';

/// Hands the widget `Snapshot` to the native layer (§7.7, Appendix I,
/// pigeon `writeSnapshot`). The host replaces its stored snapshot whole
/// (write, then rename) and asks its widgets to reload, so a widget reads
/// either the old snapshot or the new one, never a mix. Widgets never
/// recalculate (REQ-WID-001).
abstract interface class WriteWidgetSnapshot {
  /// True when the host stored [snapshot]; false when it refused it or no
  /// host answered, and its previous snapshot stays. Never throws.
  Future<bool> call(Snapshot snapshot);
}
