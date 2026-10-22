import 'package:daily_muslim/features/settings/domain/attribution.dart';

/// The data-source attributions. Contract: never fails at run time; the list
/// is a bundled asset checked by a test.
abstract interface class ReadAttributions {
  /// Every attribution, in display order.
  Future<List<Attribution>> call();
}
