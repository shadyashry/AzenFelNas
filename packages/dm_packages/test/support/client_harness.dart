import 'package:crypto/crypto.dart';
import 'package:dm_packages/dm_packages.dart';
import 'package:dm_packages/testing.dart';

import 'fakes.dart';
import 'test_channel.dart';

/// 2026-10-22T12:00:00Z.
const int harnessNow = 1792670400000;

/// One hour, in milliseconds.
const int hourMs = 60 * 60 * 1000;

/// The package client wired over fakes at its ports and a [TestChannel].
final class ClientHarness {
  new _(this.channel, this.fetch);

  /// A harness whose CDN answers with [serverDateUtcMs] as its `Date`.
  static Future<ClientHarness> create({int? serverDateUtcMs}) async {
    final channel = await TestChannel.create();
    return ClientHarness._(
      channel,
      FakeFetchChannel(channel, serverDateUtcMs: serverDateUtcMs),
    );
  }

  final TestChannel channel;
  final FakeFetchChannel fetch;
  final InMemoryPackageCatalog catalog = InMemoryPackageCatalog();
  final InMemoryPackageBlobs blobs = InMemoryPackageBlobs();
  final InMemoryTrustStore trust = InMemoryTrustStore();
  final RecordingApply apply = RecordingApply();
  final RecordingPackageEvents events = RecordingPackageEvents();
  final FixedNetwork network = FixedNetwork(NetworkKind.unmetered);
  final ListedSeeds seeds = ListedSeeds();

  final AppCompat app = AppCompat(
    appVersion: '1.0.0',
    engineSchema: 1,
    schemaVersions: {for (final t in PackageType.values) t: 1},
  );

  ActivateStaged get activate => ActivateStaged(
    read: catalog,
    write: catalog,
    apply: apply,
    events: events,
  );

  LoadPackagePayload get load => LoadPackagePayload(
    blobs: blobs,
    inflate: const GzipInflate(),
    seeds: seeds,
  );

  SyncPackages get sync => SyncPackages(
    network: network,
    trust: trust,
    fetch: fetch,
    verify: const VerifyMetadataChain(CryptographyEd25519()),
    embeddedRoot: channel.embeddedRoot,
    catalog: catalog,
    stage: StageTarget(
      compatibility: CheckCompatibility(app),
      fetch: fetch,
      inflate: const GzipInflate(),
      checkPayload: const PrefixCheckPayload(),
      blobs: blobs,
      catalog: catalog,
    ),
    activate: activate,
    events: events,
  );

  RollBackPackage get rollBack => RollBackPackage(
    read: catalog,
    write: catalog,
    load: load,
    apply: apply,
    events: events,
  );

  ImportBundledSeeds get importSeeds => ImportBundledSeeds(
    seeds: seeds,
    catalog: catalog,
    app: app,
    checkPayload: const PrefixCheckPayload(),
    activate: activate,
  );

  /// Bundles [payload] as [type] [version].
  BundledSeed bundle(PackageType type, String version, String payload) {
    final bytes = payload.codeUnits;
    final seed = BundledSeed(
      type: type,
      version: version,
      schemaVersion: 1,
      sha256: sha256.convert(bytes).toString(),
    );
    seeds.payloads[seed] = bytes;
    return seed;
  }

  /// Syncs at [hoursLater] hours after [harnessNow].
  Future<SyncReport> syncAt(int hoursLater) =>
      sync(nowUtcMs: harnessNow + hoursLater * hourMs);

  /// The active version of [type], or null.
  Future<String?> activeVersion(PackageType type) async =>
      (await catalog.active(type))?.version;
}
