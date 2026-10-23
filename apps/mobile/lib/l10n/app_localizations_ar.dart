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

  @override
  String get passportNotFoundTitle => 'الحساب ده مش موجود على الجهاز ده';

  @override
  String get passportNotFoundBody =>
      'رقم الحساب مش في مواعيد الأسبوع ده، واللينك مفيهوش بيانات نعيد بيها الحساب.';

  @override
  String get passportMismatchTitle => 'الجهاز ده حسبها بشكل مختلف';

  @override
  String get passportMismatchVersions =>
      'الوقت ده اتحسب بنسخة مختلفة من المحرك أو الإعدادات أو بيانات المناطق الزمنية.';

  @override
  String passportMismatchProfile(String profile, String version) {
    return 'الجهاز ده مفيهوش إعدادات $profile نسخة $version.';
  }

  @override
  String get passportMismatchZone =>
      'بيانات المناطق الزمنية على الجهاز ده مفيهاش منطقة المكان ده.';

  @override
  String passportLinkId(String id) {
    return 'في اللينك: $id';
  }

  @override
  String passportLocalId(String id) {
    return 'على الجهاز ده: $id';
  }

  @override
  String passportThisDevice(String engine, String tzdb) {
    return 'الجهاز ده: المحرك $engine، بيانات المناطق الزمنية $tzdb';
  }

  @override
  String get passportImportMatch =>
      'اتحسبت تاني على الجهاز ده: النتيجة زي اللينك.';

  @override
  String get passportCopyLink => 'انسخ اللينك';

  @override
  String get passportLinkCopied => 'اتنسخ اللينك';

  @override
  String get passportInputsTitle => 'المدخلات';

  @override
  String get passportVersionsTitle => 'النسخ';

  @override
  String get passportCoordinates => 'الإحداثيات';

  @override
  String get passportZone => 'المنطقة الزمنية';

  @override
  String get passportDay => 'اليوم';

  @override
  String get passportProfile => 'الإعدادات';

  @override
  String get passportHijri => 'التاريخ الهجري (الفجر / الليل)';

  @override
  String get passportEngine => 'المحرك';

  @override
  String get passportDeltaT => 'نموذج ΔT';

  @override
  String get passportTzdb => 'بيانات المناطق الزمنية';

  @override
  String get passportInputsHash => 'بصمة المدخلات';

  @override
  String passportRaw(String time) {
    return 'اللحظة المحسوبة $time';
  }

  @override
  String passportShown(String time) {
    return 'بتظهر $time';
  }

  @override
  String get passportRoundingCeil => 'متقربة للدقيقة اللي بعدها';

  @override
  String get passportRoundingFloor => 'متقربة للدقيقة اللي قبلها';

  @override
  String get passportRoundingNearest => 'متقربة لأقرب دقيقة';

  @override
  String get passportOriginPrimary => 'من القاعدة الفلكية';

  @override
  String passportOriginFallback(String method) {
    return 'من طريقة خطوط العرض العالية $method';
  }

  @override
  String passportOriginNoEvent(String reason) {
    return 'مفيش وقت في اليوم ده ($reason)';
  }

  @override
  String passportSensitivity(int seconds) {
    return '±١ كم بيغير ده بـ ≤ $seconds ث';
  }

  @override
  String passportAdjustment(String kind, String seconds) {
    return '$kind: $seconds ث';
  }

  @override
  String get passportAdjustOffset => 'إزاحة';

  @override
  String get passportAdjustRamadan => 'قاعدة رمضان';

  @override
  String get passportAdjustHighLatitude => 'طريقة خطوط العرض العالية';

  @override
  String get passportAdjustRounding => 'التقريب';

  @override
  String get flagNearRoundingBoundary =>
      'اللحظة المحسوبة قريبة أقل من نص ثانية من بداية دقيقة.';

  @override
  String get flagHighLatitudeFallback =>
      'طريقة خطوط العرض العالية هي اللي طلعت الوقت ده.';

  @override
  String get flagLowLocationAccuracy => 'موقعك تقريبي.';

  @override
  String get flagDstTransitionDay => 'الساعة بتتغير في اليوم ده.';

  @override
  String get flagStaleTzdb => 'بيانات المناطق الزمنية على الجهاز قديمة.';

  @override
  String get flagHijriExpected => 'التاريخ الهجري متوقع ولسه ما اتعلنش.';

  @override
  String get flagReferenceModeAuthorityPoint =>
      'محسوب عند نقطة المرجع بتاعة الجهة لمنطقتك.';

  @override
  String get flagManualCoordinateResolution => 'المكان اتختار يدوي.';

  @override
  String get flagZoneBoundaryProximity => 'انت قريب من حدود منطقة زمنية.';

  @override
  String get flagNoLocalProfile =>
      'مفيش إعدادات محلية للمكان ده؛ بنستخدم الافتراضي.';

  @override
  String get passportNoFlags => 'مفيش ملاحظات على الوقت ده.';

  @override
  String get qiblaNoHeading => 'مستنيين البوصلة…';

  @override
  String get qiblaNumericOnly =>
      'الجهاز ده مفيهوش بوصلة تنفع. اتجه للزاوية دي بخريطة أو بوصلة عادية.';

  @override
  String get qiblaCalibrating =>
      'دقة البوصلة ضعيفة. حرّك الموبايل على شكل ٨ بعيد عن المعادن.';

  @override
  String qiblaBearing(String degrees) {
    return 'القبلة: $degrees° من الشمال الحقيقي';
  }

  @override
  String qiblaDistance(String km) {
    return '$km كم للكعبة';
  }

  @override
  String qiblaAccuracy(String degrees) {
    return 'دقة البوصلة ±$degrees°';
  }

  @override
  String qiblaTurn(String degrees, String direction) {
    return 'لف $degrees° $direction';
  }

  @override
  String get qiblaRight => 'يمين';

  @override
  String get qiblaLeft => 'شمال';

  @override
  String get qiblaFacing => 'انت في اتجاه القبلة.';

  @override
  String get qiblaNeedsPlace => 'اختار مكان علشان تشوف القبلة.';

  @override
  String planAthanTitle(String prayer) {
    return 'أذان $prayer';
  }

  @override
  String planAthanBody(String prayer) {
    return 'جه وقت $prayer.';
  }

  @override
  String get planImsakTitle => 'الإمساك';

  @override
  String get planImsakBody => 'جه وقت الإمساك.';

  @override
  String planPreReminderTitle(String prayer, int minutes) {
    return '$prayer بعد $minutes دقيقة';
  }

  @override
  String planPreReminderBody(String prayer, int minutes) {
    return 'أذان $prayer بعد $minutes دقيقة.';
  }

  @override
  String get planHorizonTitle => 'جدول الأذان قرب يخلص';

  @override
  String get planHorizonBody => 'افتح التطبيق علشان الأذان يفضل متجدول.';
}
