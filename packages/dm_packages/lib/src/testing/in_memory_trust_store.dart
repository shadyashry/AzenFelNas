import 'package:dm_core_types/dm_core_types.dart';
import 'package:dm_packages/src/client/channel_trust.dart';
import 'package:dm_packages/src/client/ports/package_trust_store.dart';
import 'package:dm_packages/src/verify/package_failure.dart';

/// [PackageTrustStore] in memory, for tests.
final class InMemoryTrustStore implements PackageTrustStore {
  /// A store holding [ChannelTrust.initial].
  new();

  /// The stored state.
  ChannelTrust state = ChannelTrust.initial;

  @override
  Future<ChannelTrust> read() async => state;

  @override
  Future<Result<void, PackageFailure>> write(ChannelTrust trust) async {
    state = trust;
    return const Result.ok(null);
  }
}
