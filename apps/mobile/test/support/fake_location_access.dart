import 'package:daily_muslim/features/contexts/domain/location_access.dart';
import 'package:daily_muslim/features/contexts/domain/location_ports.dart';

/// Location access whose answer the test sets; counts requests.
final class FakeLocationAccess implements RequestLocationAccess {
  /// Answers [access].
  new([this.access = LocationAccess.denied]);

  /// What [request] answers.
  LocationAccess access;

  /// How often [request] was called.
  int requests = 0;

  @override
  Future<LocationAccess> request() async {
    requests++;
    return access;
  }
}
