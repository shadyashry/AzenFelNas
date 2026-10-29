import 'package:daily_muslim/features/athan/domain/athan_grant.dart';

/// Records the grants asked for; shows nothing.
final class FakeAthanGrant implements RequestAthanGrant {
  /// The grants asked for, in order.
  final List<AthanGrant> asked = [];

  @override
  Future<void> call(AthanGrant grant) async => asked.add(grant);
}
