// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'المسلم اليومي';

  @override
  String get homeTitle => 'النهارده';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get settingsLanguage => 'اللغة';

  @override
  String get languageArabic => 'العربية';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSystem => 'لغة الجهاز';

  @override
  String get settingsDigits => 'الأرقام';

  @override
  String get digitsLocale => 'زي اللغة';

  @override
  String get digitsWestern => '0123456789';

  @override
  String get digitsArabicIndic => '٠١٢٣٤٥٦٧٨٩';

  @override
  String get settingsTheme => 'المظهر';

  @override
  String get themeSky => 'السما (بتمشي مع الشمس)';

  @override
  String get themeLight => 'فاتح';

  @override
  String get themeDark => 'غامق';

  @override
  String get themeSystem => 'زي الجهاز';

  @override
  String get settingsReducedMotion => 'تقليل الحركة';

  @override
  String get settingsAttributions => 'مصادر البيانات والتراخيص';

  @override
  String get attributionsOpenSource => 'تراخيص البرمجيات المفتوحة';

  @override
  String get healthTitle => 'صحة الأذان';

  @override
  String get qiblaTitle => 'القبلة';

  @override
  String get passportTitle => 'جواز الدقة';

  @override
  String get notYetAvailable => 'الشاشة دي جاية في تحديث قريب.';

  @override
  String get needsAttentionTitle => 'محتاج انتباهك';

  @override
  String needsAttentionCode(String code) {
    return 'الكود $code';
  }

  @override
  String get startupFailedTitle => 'التطبيق مقدرش يفتح بياناته';

  @override
  String get remediationGrantLocationPermission =>
      'اسمح بالوصول للموقع، أو اختار مكانك بنفسك.';

  @override
  String get remediationTurnOnLocationServices =>
      'شغّل الموقع من إعدادات الجهاز، أو اختار مكانك بنفسك.';

  @override
  String get remediationChooseManualPlace =>
      'اختار مكانك من القائمة أو اكتب الإحداثيات.';

  @override
  String get remediationWaitForDataUpdate =>
      'مفيش حاجة تعملها دلوقتي. تحديث البيانات هيصلّح ده.';

  @override
  String get remediationRetryWhenOnline =>
      'اتصل بالإنترنت. التطبيق هيحاول تاني.';

  @override
  String get remediationFreeUpStorage => 'فضّي شوية مساحة على الجهاز.';

  @override
  String get remediationTryAgain => 'جرّب تاني.';

  @override
  String get remediationUpdateApp => 'نزّل آخر نسخة من التطبيق.';

  @override
  String get remediationGrantAlarmPermission =>
      'اسمح بالمنبّهات والإشعارات علشان الأذان يشتغل في وقته.';

  @override
  String get remediationOpenAthanHealth =>
      'افتح صحة الأذان علشان تشوف التفاصيل.';

  @override
  String get remediationCheckDeviceClock =>
      'خلّي تاريخ ووقت الجهاز يتظبطوا أوتوماتيك.';
}
