import 'package:dm_hijri/dm_hijri.dart';

import 'support/fixtures.dart';

void main() {
  roundTripValidFixtures<HijriPackageDocument>(
    'hijri_package',
    decode: (json) => HijriPackageDocument.fromJson(asJsonObject(json)),
    encode: (model) => model.toJson(),
  );
}
