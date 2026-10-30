// Runs `integration_test/` with `flutter drive` and writes what a test
// reports to build/integration_response_data.json (§15 D107 device checks).
import 'package:integration_test/integration_test_driver.dart';

Future<void> main() => integrationDriver();
