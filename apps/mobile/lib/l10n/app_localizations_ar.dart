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

  @override
  String get onboardingWelcomeTitle => 'مواقيت الصلاة حيث أنت';

  @override
  String get onboardingWelcomeBody =>
      'يشتغل من غير إنترنت ومن غير حساب. موقعك بيفضل على الموبايل ده.';

  @override
  String get onboardingStart => 'يلا نبدأ';

  @override
  String get onboardingLocationTitle => 'إنت فين؟';

  @override
  String get onboardingLocationBody =>
      'الموقع التقريبي كفاية لمواقيت النهارده. وممكن تختار مكان بدل كده.';

  @override
  String get onboardingUseLocation => 'استخدم الموقع التقريبي';

  @override
  String get onboardingChoosePlace => 'اختار مكان';

  @override
  String get onboardingResolving => 'بندوّر على مكانك…';

  @override
  String get onboardingFailedTitle => 'الموقع مش متاح';

  @override
  String get onboardingTryAgain => 'جرّب تاني';

  @override
  String get onboardingDoneTitle => 'مواقيتك جاهزة';

  @override
  String onboardingDoneBody(String place) {
    return 'مواقيت الصلاة في $place.';
  }

  @override
  String get onboardingShowTimes => 'اعرض مواقيت النهارده';

  @override
  String get placeTitle => 'اختار مكان';

  @override
  String get placeSearchHint => 'اسم المدينة';

  @override
  String get placeIdle => 'دوّر في قايمة المدن اللي على الموبايل.';

  @override
  String get placeSearching => 'بندوّر…';

  @override
  String get placeEmpty =>
      'مفيش مكان بالاسم ده. جرّب كتابة تانية أو دخّل الإحداثيات.';

  @override
  String placeError(String code) {
    return 'البحث ما اشتغلش (كود $code).';
  }

  @override
  String get placeEnterCoordinates => 'دخّل الإحداثيات';

  @override
  String get placeLatitude => 'خط العرض';

  @override
  String get placeLongitude => 'خط الطول';

  @override
  String get placeName => 'اسم المكان';

  @override
  String get placeCoordinatesInvalid =>
      'خط العرض من -90 لـ 90، وخط الطول من -180 لـ 180.';

  @override
  String get placeUse => 'استخدم المكان ده';

  @override
  String homeNextPrayer(String prayer) {
    return 'الجاية: $prayer';
  }

  @override
  String homeCountdown(String hours, String minutes) {
    return 'بعد $hours س $minutes د';
  }

  @override
  String get homeNoNextPrayer => 'مفيش صلاة تانية في الأيام الجاية';

  @override
  String get homeNeedsLocation => 'اختار المكان اللي عايز مواقيته.';

  @override
  String get homeNoProfile =>
      'مفيش ملف لجهة محلية هنا؛ بنستخدم الإعداد الافتراضي للمحرك.';

  @override
  String homeError(String code) {
    return 'ما قدرناش نطلع المواقيت (كود $code).';
  }

  @override
  String get homeHealthUnknown => 'الأذان: لسه ما اتظبطش';

  @override
  String homeManualPlace(String label) {
    return 'مكان يدوي · $label';
  }

  @override
  String get homeCurrentPlace => 'الموقع التقريبي';

  @override
  String homePinnedPlace(String label) {
    return 'مكان مثبّت · $label';
  }

  @override
  String get homeChangePlace => 'غيّر المكان';

  @override
  String get timelineTitle => 'الأيام السبعة الجاية';

  @override
  String timelineError(String code) {
    return 'ما قدرناش نطلع الأيام (كود $code).';
  }

  @override
  String get prayerImsak => 'الإمساك';

  @override
  String get prayerFajr => 'الفجر';

  @override
  String get prayerSunrise => 'الشروق';

  @override
  String get prayerDhuhr => 'الظهر';

  @override
  String get prayerAsr => 'العصر';

  @override
  String get prayerMaghrib => 'المغرب';

  @override
  String get prayerIsha => 'العشاء';

  @override
  String get noTimeText => '—';

  @override
  String get noTimeReason => 'مفيش وقت في اليوم ده';
}
