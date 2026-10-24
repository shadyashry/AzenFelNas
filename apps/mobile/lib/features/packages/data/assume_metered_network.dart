import 'package:dm_packages/dm_packages.dart';

/// [ReadNetworkKind] without a connectivity plugin (§15 D85): every network
/// is the unknown case, [NetworkKind.metered] by the port's contract, so
/// metadata and payloads up to 2 MB sync anywhere and larger ones only when
/// `urgent` (REQ-PKG-004). Offline shows as a network failure of the fetch,
/// which leaves the last-known-good data active (REQ-PKG-001).
final class AssumeMeteredNetwork implements ReadNetworkKind {
  /// The adapter.
  const new();

  @override
  Future<NetworkKind> call() async => NetworkKind.metered;
}
