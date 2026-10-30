import 'package:dm_ui/dm_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('every bundled face lists its OFL notice on the licences page '
      '(§10.4, §15 D109)', () async {
    FontLicences.register(rootBundle);
    final entries = await LicenseRegistry.licenses.toList();
    for (final family in FontLicences.files.keys) {
      final entry = entries.singleWhere((e) => e.packages.contains(family));
      final text = entry.paragraphs.map((p) => p.text).join('\n');
      expect(text, contains('SIL OPEN FONT LICENSE Version 1.1'));
    }
  });
}
