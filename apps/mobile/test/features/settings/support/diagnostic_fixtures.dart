import 'package:daily_muslim/features/athan/domain/read_last_test_heard.dart';
import 'package:daily_muslim/features/contexts/domain/context_kind.dart';
import 'package:daily_muslim/features/contexts/domain/context_place.dart';
import 'package:daily_muslim/features/contexts/domain/context_source.dart';
import 'package:daily_muslim/features/settings/application/assemble_diagnostic_bundle.dart';
import 'package:daily_muslim/features/settings/domain/deliver_diagnostic_text.dart';
import 'package:dm_civil_time/dm_civil_time.dart';
import 'package:dm_contracts/dm_contracts.dart';
import 'package:dm_core_types/dm_core_types.dart';
import 'package:dm_packages/dm_packages.dart';

import '../../athan/support/fake_athan_platform.dart';
import '../../athan/support/health_reports.dart';
import '../../contexts/support/fake_location_context_store.dart';

/// No Test answered yet.
final class NoTestHeard implements ReadLastTestHeard {
  @override
  Future<bool?> call() async => null;
}

/// Records every hand-over; refuses when [accept] is false.
final class FakeDeliverDiagnosticText implements DeliverDiagnosticText {
  /// The fake.
  new({this.accept = true});

  /// Whether hand-overs succeed.
  bool accept;

  /// Texts handed over.
  final delivered = <String>[];

  @override
  Future<bool> call(String text) async {
    if (!accept) return false;
    delivered.add(text);
    return true;
  }
}

/// A gazetteer package activated from the bundled seed.
const gazetteer = ActivePackage(
  type: PackageType.gazetteer,
  version: '2026.10.1',
  sequence: 3,
  sha256: 'ab',
  source: PackageSource.bundled,
  activatedUtcMs: 1,
);

/// Events with every non-coordinate attribute kind.
const sampleEvents = [
  EventLogEntry(
    utcMs: 10,
    level: EventLogLevel.info,
    code: EventCode.appStart,
    attrs: EventLogAttrs(),
  ),
  EventLogEntry(
    utcMs: 11,
    level: EventLogLevel.info,
    code: EventCode.contextChanged,
    attrs: EventLogAttrs(zoneId: 'Africa/Cairo', countryCode: 'EG'),
  ),
];

/// Stores a manual context at ([latE6], [lonE6]) labelled [label].
Future<void> addPlace(
  FakeLocationContextStore store, {
  required int latE6,
  required int lonE6,
  String label = 'Home of my aunt',
}) => store.addChosen(
  ChosenKind.manual,
  ContextPlace(
    point: GeoPointE6(latE6, lonE6),
    horizontalAccuracyM: 12.5,
    zoneId: 'Africa/Cairo',
    country: 'EG',
    label: label,
  ),
  ContextSource.gazetteer,
  utcMs: 5,
);

/// The use case over fakes at its ports.
AssembleDiagnosticBundle assembleOver(
  FakeLocationContextStore contexts, {
  FakeAthanPlatform? platform,
  List<EventLogEntry> events = sampleEvents,
}) => AssembleDiagnosticBundle(
  events: () async => events,
  platformHealth: platform ?? FakeAthanPlatform(report: androidReport()),
  lastTestHeard: NoTestHeard(),
  contexts: contexts,
  activePackages: () async => const [gazetteer],
  clock: FixedClock(1792800000000),
  os: DiagnosticOs.android,
  appVersion: '0.1.0',
);
