import 'package:dm_core_types/dm_core_types.dart';
import 'package:dm_packages/src/client/channel_trust.dart';
import 'package:dm_packages/src/verify/package_failure.dart';

/// Keeps the channel's [ChannelTrust]. Contract: `read` never fails and
/// answers [ChannelTrust.initial] when nothing is stored; `write` replaces
/// the whole state in one transaction or fails with `PKG_STORAGE`.
abstract interface class PackageTrustStore {
  /// The stored state.
  Future<ChannelTrust> read();

  /// Replaces the stored state with [trust].
  Future<Result<void, PackageFailure>> write(ChannelTrust trust);
}
