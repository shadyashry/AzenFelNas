import 'package:daily_muslim/features/athan/application/write_widget_snapshot.dart';
import 'package:dm_contracts/dm_contracts.dart';

/// The native snapshot store as the [WriteWidgetSnapshot] contract
/// describes it (`SnapshotStore`, §7.7): the stored snapshot is replaced
/// whole and a refusal keeps the previous one. Fake at the port only
/// (§17.7).
final class FakeWidgetHost implements WriteWidgetSnapshot {
  /// A host that stores snapshots while [accepts] is true.
  new({this.accepts = true});

  /// False makes the host refuse every snapshot, as a missing host does.
  bool accepts;

  /// The stored snapshot; null before the first one.
  Snapshot? stored;

  @override
  Future<bool> call(Snapshot snapshot) async {
    if (!accepts) return false;
    stored = snapshot;
    return true;
  }
}
