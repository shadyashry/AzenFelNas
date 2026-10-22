/// In-memory fakes of the `dm_packages` storage ports, for tests in this
/// package and in the app (§17.7: fakes only at ports, run against the same
/// contract suites as the adapters).
library;

export 'package:dm_packages/src/testing/in_memory_package_blobs.dart';
export 'package:dm_packages/src/testing/in_memory_package_catalog.dart';
export 'package:dm_packages/src/testing/in_memory_trust_store.dart';
