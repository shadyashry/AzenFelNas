import 'package:test/test.dart';

import '../tool/bench_profile_files.dart';

void main() {
  test('the engine bench reads the current compiled seed profiles '
      '(§15 D51; regenerate with dart run tool/sync_bench_profiles.dart)', () {
    expect(benchProfileFiles, isNotEmpty);
    for (final (source, target) in benchProfileFiles) {
      expect(
        target.readAsStringSync(),
        compiledBenchProfile(source),
        reason: '${target.path} is stale',
      );
    }
  });
}
