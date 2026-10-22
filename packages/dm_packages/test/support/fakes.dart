import 'dart:io';

import 'package:dm_core_types/dm_core_types.dart';
import 'package:dm_packages/dm_packages.dart';

import 'test_channel.dart';

/// [FetchChannel] serving a [TestChannel]'s last signed metadata and its
/// packages. Tests change [served] or [packages] to tamper, and set
/// [offline] to fail every request with `PKG_NETWORK`.
final class FakeFetchChannel implements FetchChannel {
  new(this.channel, {this.serverDateUtcMs});

  final TestChannel channel;
  final int? serverDateUtcMs;
  Map<MetadataRole, List<int>> served = {};
  final Map<String, List<int>> packages = {};
  bool offline = false;
  final List<String> requests = [];

  /// Signs the channel at [sequence] and serves it.
  Future<void> publish({
    required int sequence,
    String expires = '2099-01-01T00:00:00Z',
  }) async {
    served = await channel.sign(sequence: sequence, expires: expires);
    for (final MapEntry(key: name, value: t) in channel.targets.entries) {
      packages[name] = t.dmpkg;
    }
  }

  @override
  Future<Result<FetchedFile, PackageFailure>> metadata(
    MetadataRole role, {
    required int maxBytes,
  }) async {
    requests.add('${role.name}.json');
    final bytes = served[role];
    if (offline || bytes == null || bytes.length > maxBytes) {
      return const Result.err(PackageFailure.network('fake: no metadata'));
    }
    return Result.ok(FetchedFile(bytes, serverDateUtcMs: serverDateUtcMs));
  }

  @override
  Future<Result<FetchedFile, PackageFailure>> package(
    PackageType type,
    String version,
    String sha256, {
    required int maxBytes,
  }) async {
    final name = '${type.wire}/$version';
    requests.add(name);
    final bytes = packages[name];
    if (offline || bytes == null || bytes.length > maxBytes) {
      return const Result.err(PackageFailure.network('fake: no package'));
    }
    return Result.ok(FetchedFile(bytes));
  }
}

/// [InflatePayload] with `dart:io` gzip, as the app adapter does.
final class GzipInflate implements InflatePayload {
  const new();

  @override
  Result<List<int>, PackageFailure> call(
    List<int> dmpkg, {
    required int maxBytes,
  }) {
    try {
      final payload = gzip.decode(dmpkg);
      return payload.length > maxBytes
          ? const Result.err(PackageFailure.hashMismatch('too large'))
          : Result.ok(payload);
    } on FormatException catch (e) {
      return Result.err(PackageFailure.hashMismatch(e.message));
    }
  }
}

/// [CheckPayload] that accepts everything except payloads starting with
/// `INVALID`.
final class PrefixCheckPayload implements CheckPayload {
  const new();

  @override
  Result<void, PackageFailure> call(
    PackageType type,
    int schemaVersion,
    List<int> payload,
  ) => String.fromCharCodes(payload.take(7)) == 'INVALID'
      ? const Result.err(PackageFailure.incompatible('payload refused'))
      : const Result.ok(null);
}

/// [ApplyPackage] that records what it applied, by type, and fails for the
/// versions in [failing].
final class RecordingApply implements ApplyPackage {
  final Map<PackageType, String> applied = {};
  final Set<String> failing = {};

  @override
  Future<Result<void, PackageFailure>> call(
    PackageType type,
    String version,
    List<int> payload,
  ) async {
    if (failing.contains(version)) {
      return const Result.err(PackageFailure.storage('apply failed'));
    }
    applied[type] = String.fromCharCodes(payload);
    return const Result.ok(null);
  }
}

/// [RecordPackageEvent] collecting the events.
final class RecordingPackageEvents implements RecordPackageEvent {
  final List<PackageEvent> events = [];

  @override
  Future<void> record(PackageEvent event) async => events.add(event);
}

/// [ReadNetworkKind] answering [kind].
final class FixedNetwork implements ReadNetworkKind {
  new(this.kind);

  NetworkKind kind;

  @override
  Future<NetworkKind> call() async => kind;
}

/// [ReadBundledSeeds] over in-memory payloads.
final class ListedSeeds implements ReadBundledSeeds {
  final Map<BundledSeed, List<int>> payloads = {};

  @override
  Future<List<BundledSeed>> seeds() async => payloads.keys.toList();

  @override
  Future<Result<List<int>, PackageFailure>> payload(BundledSeed seed) async =>
      switch (payloads[seed]) {
        final bytes? => Result.ok(bytes),
        null => const Result.err(PackageFailure.storage('not bundled')),
      };
}
