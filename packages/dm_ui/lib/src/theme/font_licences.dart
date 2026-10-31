import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// The OFL notices of the faces `dm_ui` bundles (§10.4, §15 D109), added to
/// Flutter's `LicenseRegistry` so the open-source licences page lists each
/// family with its licence, as OFL-1.1 asks of every copy distributed.
abstract final class FontLicences {
  /// Each bundled family and the licence file beside it in `fonts/`.
  static const Map<String, String> files = {
    'Amiri': 'OFL-Amiri.txt',
    'DM Sans': 'OFL-DMSans.txt',
    'Gelasio': 'OFL-Gelasio.txt',
    'Inter': 'OFL-Inter.txt',
    'Lora': 'OFL-Lora.txt',
    'Noto Naskh Arabic': 'OFL-NotoNaskhArabic.txt',
    'Noto Sans Arabic': 'OFL-NotoSansArabic.txt',
  };

  /// Adds the notices, read lazily from [bundle] when the page opens.
  static void register(AssetBundle bundle) {
    LicenseRegistry.addLicense(() async* {
      for (final MapEntry(key: family, value: file) in files.entries) {
        yield LicenseEntryWithLineBreaks([
          family,
        ], await bundle.loadString('packages/dm_ui/fonts/$file'));
      }
    });
  }
}
