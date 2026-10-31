import 'dart:io';

import 'package:daily_muslim/features/quran/domain/page_box.dart';

/// Reads `pages/boxes.json` of the package in [directory] (§15 D123):
/// `null` when the package has none (one built before the pages were
/// frameless) or it cannot be read, so the reader shows whole pages as
/// before.
Future<PageBoxes?> readPageBoxes(String directory, int pageCount) async {
  final file = File('$directory/pages/boxes.json');
  try {
    if (!file.existsSync()) return null;
    return PageBoxes.parse(await file.readAsString(), pageCount: pageCount);
  } on FileSystemException {
    return null;
  } on PageBoxesFormatException {
    return null;
  }
}
