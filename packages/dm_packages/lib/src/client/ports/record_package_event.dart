import 'package:dm_packages/src/client/package_event.dart';

/// Appends package events to the event log (Appendix J). Contract: never
/// throws and never blocks the caller on a failed write.
abstract interface class RecordPackageEvent {
  /// Records [event].
  Future<void> record(PackageEvent event);
}
