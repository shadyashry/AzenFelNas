// The engine bench of the Accuracy Lab (DESIGN.md §6.1, §9.4, §15 D29):
// `dart run geo_salah_core:bench` reads `bench_request.v1` JSONL on stdin and
// writes exactly one line per request, in order, on stdout — a
// `calculation_trace.v1` or a `bench_failure.v1` document. Blank lines are
// not requests. A line that breaks the contract stops the run with exit
// status 2 and a message on stderr; the lines already written stand.
import 'dart:convert';
import 'dart:io';

import 'package:geo_salah_core/src/bench/bench_runner.dart';

Future<void> main() async {
  const runner = BenchRunner();
  final lines = stdin.transform(utf8.decoder).transform(const LineSplitter());
  var number = 0;
  await for (final line in lines) {
    number++;
    if (line.trim().isEmpty) continue;
    try {
      stdout.writeln(jsonEncode(runner.answer(_object(jsonDecode(line)))));
    } on FormatException catch (e) {
      stderr.writeln('bench: request line $number: ${e.message}');
      exitCode = 2;
      break;
    }
  }
  await stdout.flush();
}

Map<String, Object?> _object(Object? json) => switch (json) {
  final Map<String, Object?> object => object,
  _ => throw const FormatException('A request line is not a JSON object'),
};
