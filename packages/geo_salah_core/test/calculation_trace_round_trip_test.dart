import 'package:geo_salah_core/geo_salah_core.dart';
import 'package:test/test.dart';

import 'support/fixtures.dart';

void main() {
  roundTripValidFixtures<CalculationTraceDocument>(
    'calculation_trace',
    decode: (json) => CalculationTraceDocument.fromJson(asJsonObject(json)),
    encode: (model) => model.toJson(),
  );

  group('HighLatitudeMethodDocumentConverter', () {
    const converter = HighLatitudeMethodDocumentConverter();

    test('rejects an unknown method name', () {
      expect(() => converter.fromJson('twilightMiddle'), throwsFormatException);
    });

    test('rejects a method object with extra keys', () {
      expect(
        () => converter.fromJson({
          'nearestValidDay': {'maxDays': 7, 'extra': 1},
        }),
        throwsFormatException,
      );
    });
  });
}
