// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'أذّن في الناس';

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
    return 'بعد $hours ساعة و$minutes دقيقة';
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
  String get qiblaShadowTitle => 'القبلة بظل الشمس';

  @override
  String get qiblaShadowFootnote =>
      'من غير بوصلة: اركز عصاية أو خيط شاقول واقف. في الأوقات دي ضله بيبقى على خط القبلة.';

  @override
  String get qiblaShadowToward =>
      'اتجه للشمس. القبلة من طرف الضل لحد رجل العصاية.';

  @override
  String get qiblaShadowAway =>
      'الشمس وراك. القبلة من رجل العصاية على طول الضل لحد طرفه.';

  @override
  String qiblaShadowWindow(String start, String end) {
    return 'في حدود درجة من $start لحد $end';
  }

  @override
  String get qiblaShadowPassed => 'عدّى';

  @override
  String get qiblaShadowHighSun => 'صعب: الشمس عالية فالضل قصير.';

  @override
  String get qiblaShadowBriefWindow => 'صعب: الوقت أقل من دقيقتين.';

  @override
  String qiblaShadowNextDay(String date) {
    return 'مفيش النهارده. أقرب يوم: $date';
  }

  @override
  String get qiblaShadowNone =>
      'الشمس مش هتيجي على خط القبلة هنا في التمن أيام الجايين.';

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

  @override
  String get athanTitle => 'الأذان';

  @override
  String get settingsAthan => 'الأذان';

  @override
  String get athanHealthTitle => 'جاهزية الأذان';

  @override
  String get athanHealthEvaluating => 'جارٍ الفحص…';

  @override
  String get athanHealthReady => 'جاهز: سيُرفع الأذان';

  @override
  String get athanHealthLimited => 'محدود: قد يتأخر الأذان أو يخفت';

  @override
  String get athanHealthNotReady => 'غير جاهز: لن يُرفع الأذان';

  @override
  String get athanHealthUnknown => 'غير متاح · لا يستطيع الهاتف التحديد';

  @override
  String get athanReasonNeedsNotificationPermission =>
      'اسمح بالإشعارات لتطبيق أذّن في الناس';

  @override
  String get athanReasonNeedsExactAlarmPermission =>
      'اسمح بالمنبهات والتذكيرات';

  @override
  String get athanReasonNeedsAlarmKitAuthorization =>
      'اسمح بالمنبهات لتطبيق أذّن في الناس';

  @override
  String get athanReasonMutedChannel => 'صوت الأذان مكتوم في إعدادات النظام';

  @override
  String get athanReasonBatteryRestricted =>
      'الهاتف يقيّد أذّن في الناس في الخلفية';

  @override
  String get athanReasonStalePlan => 'افتح التطبيق لجدولة الأذان';

  @override
  String get athanReasonHorizonEnding =>
      'جدول الأذان ينتهي قريبًا؛ افتح التطبيق';

  @override
  String get athanReasonFailedTest => 'لم تسمع الاختبار الأخير';

  @override
  String get athanReasonClockSkew => 'ساعة الهاتف تبدو غير صحيحة';

  @override
  String get athanReasonNoSoundAsset => 'لا يوجد صوت أذان مثبّت';

  @override
  String get athanReasonInexactFallback =>
      'بدون إذن «المنبهات والتذكيرات» قد يتأخر الأذان حتى ساعة';

  @override
  String get athanReasonUnverifiableDelivery =>
      'لا يستطيع هذا الهاتف التأكد من رفع الأذان';

  @override
  String get athanReasonForceStoppedPreviously =>
      'أُوقف التطبيق قسرًا من قبل؛ فُقدت المنبهات حينها';

  @override
  String get athanGrantAllow => 'اسمح';

  @override
  String get athanGrantOpenSettings => 'افتح الإعدادات';

  @override
  String get athanTestTitle => 'اختبار الأذان';

  @override
  String get athanTestStart => 'شغّل أذانًا تجريبيًا بعد 60 ثانية';

  @override
  String get athanTestNeedsSound => 'اختر صوت الأذان أولًا';

  @override
  String get athanTestFired => 'يُفترض أن الأذان التجريبي يعمل الآن';

  @override
  String get athanTestAsk => 'هل سمعته؟';

  @override
  String get athanTestYes => 'نعم';

  @override
  String get athanTestNo => 'لا';

  @override
  String get athanTestHeard => 'سُجّل: سمعت الاختبار';

  @override
  String get athanTestNotHeard => 'سُجّل: لم تسمع الاختبار';

  @override
  String get athanTestNotArmed => 'لم يجدول الهاتف الاختبار';

  @override
  String get athanTestAgain => 'اختبر مرة أخرى';

  @override
  String get athanSound => 'صوت الأذان';

  @override
  String get athanNoSounds => 'لا توجد أصوات أذان مثبّتة بعد';

  @override
  String get athanSoundTest => 'أذان تجريبي (ليس للإصدار)';

  @override
  String get athanPrayersTitle => 'الأذان في';

  @override
  String get athanPreReminder => 'تذكير قبل الأذان';

  @override
  String get athanPreReminderOff => 'إيقاف';

  @override
  String athanTestScheduled(int seconds) {
    return 'الأذان التجريبي بعد $seconds ث';
  }

  @override
  String athanPreReminderMinutes(int minutes) {
    return 'قبل $minutes دقيقة';
  }

  @override
  String get settingsDiagnostics => 'التشخيص';

  @override
  String get diagnosticsTitle => 'التشخيص';

  @override
  String get diagnosticsIntro =>
      'ده كل اللي في تقرير التشخيص. مكانك متقرّب لحوالي ١ كم، ومفيش أي حاجة بتعرّف عليك أو على الجهاز. مفيش حاجة بتتبعت: انسخه والصقه في رسالة للدعم لو حابب بس.';

  @override
  String get diagnosticsCopy => 'انسخ التقرير';

  @override
  String get diagnosticsCopied => 'اتنسخ التقرير';

  @override
  String get diagnosticsUnavailable => 'ماقدرناش نجهّز التقرير.';

  @override
  String homeFastingTitle(int day) {
    return 'رمضان $day';
  }

  @override
  String homeFastingWindow(String begins, String ends) {
    return 'الصيام من $begins لحد $ends';
  }

  @override
  String homeFastingImsak(String time) {
    return 'الإمساك $time';
  }

  @override
  String get homeFastingUnknown =>
      'الفجر أو المغرب مالهمش وقت هنا النهارده؛ اتبع الجهة المحلية.';

  @override
  String get homeHijriOverride => 'اليوم الهجري';

  @override
  String get homeHijriOverrideApplied => 'معدّل منك';

  @override
  String travelPrompt(String city) {
    return 'شكلك في $city. نغيّر المواعيد؟';
  }

  @override
  String get travelSwitch => 'غيّر';

  @override
  String get travelNotNow => 'مش دلوقتي';

  @override
  String homeCountdownMinutes(String minutes) {
    return 'بعد $minutes دقيقة';
  }

  @override
  String homeCartouche(String prayer) {
    return 'صلاة $prayer';
  }

  @override
  String homeHijriDate(String day, String monthName, String year) {
    return '$day $monthName $year';
  }

  @override
  String hijriMonthName(String month) {
    String _temp0 = intl.Intl.selectLogic(
      month,
      {
        '1': 'محرم',
        '2': 'صفر',
        '3': 'ربيع الأول',
        '4': 'ربيع الآخر',
        '5': 'جمادى الأولى',
        '6': 'جمادى الآخرة',
        '7': 'رجب',
        '8': 'شعبان',
        '9': 'رمضان',
        '10': 'شوال',
        '11': 'ذو القعدة',
        '12': 'ذو الحجة',
        'other': '',
      },
    );
    return '$_temp0';
  }

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navQibla => 'القبلة';

  @override
  String get navAthan => 'الأذان';

  @override
  String get navSettings => 'الإعدادات';

  @override
  String get compassNorth => 'ش';

  @override
  String get compassEast => 'ق';

  @override
  String get compassSouth => 'ج';

  @override
  String get compassWest => 'غ';

  @override
  String qiblaDegrees(String degrees) {
    return '$degrees°';
  }

  @override
  String get settingsDisplaySection => 'العرض';

  @override
  String get settingsMoreSection => 'المزيد';
}
