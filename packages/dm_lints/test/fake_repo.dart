import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';

/// A throw-away repository checkout in the system temp directory, deleted
/// after the current test.
final class FakeRepo {
  /// Creates an empty checkout.
  new() : root = Directory.systemTemp.createTempSync('dm_lints_') {
    addTearDown(() => root.deleteSync(recursive: true));
  }

  /// The checkout's root directory.
  final Directory root;

  /// Writes [content] to the repository-relative [path].
  void write(String path, String content) {
    File(p.joinAll([root.path, ...path.split('/')]))
      ..createSync(recursive: true)
      ..writeAsStringSync(content);
  }
}
