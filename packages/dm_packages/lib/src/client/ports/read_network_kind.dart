import 'package:dm_packages/src/client/network_kind.dart';

/// The current network (REQ-PKG-004). Contract: never fails; an unknown
/// network is [NetworkKind.metered].
abstract interface class ReadNetworkKind {
  /// The network now.
  Future<NetworkKind> call();
}
