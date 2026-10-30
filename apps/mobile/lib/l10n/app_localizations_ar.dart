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
  String get homeTitle => 'اليوم';

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
  String get themeSky => 'ديناميكي (يتغيّر مع أوقات الصلاة)';

  @override
  String get themeLight => 'فاتح';

  @override
  String get themeDark => 'داكن';

  @override
  String get themeSystem => 'حسب الجهاز';

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
  String get remediationChooseManualPlace => 'اختار مدينتك من القائمة.';

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
  String get remediationActionTurnOnLocation => 'شغّل الموقع';

  @override
  String get remediationActionOpenSettings => 'افتح الإعدادات';

  @override
  String get onboardingWelcomeTitle => 'مواقيت الصلاة حيث أنت';

  @override
  String get onboardingWelcomeBody =>
      'يشتغل من غير إنترنت ومن غير حساب. موقعك بيفضل على الموبايل ده.';

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
  String get onboardingAthanPermissions =>
      'عشان الأذان يتسمع في وقته، الشاشات الجاية هتطلب السماح بالإشعارات والمنبهات.';

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
  String get placeEmpty => 'مفيش مكان بالاسم ده. جرّب كتابة تانية.';

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
  String get homeContinueQuran => 'متابعة القراءة';

  @override
  String get homeQuranResume => 'متابعة';

  @override
  String get homeQuranOffline => 'متاح دون إنترنت';

  @override
  String homeSurahNumber(String number) {
    return 'سورة $number';
  }

  @override
  String get timeAm => 'ص';

  @override
  String get timePm => 'م';

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
      'لسه مفيش جدول محلي للمنطقة دي، فالمواقيت بالطريقة العامة.';

  @override
  String get homeHealthUnknown => 'الأذان: لسه ما اتظبطش';

  @override
  String get homeCurrentPlace => 'موقعك الحالي';

  @override
  String get timelineTitle => 'الأيام السبعة الجاية';

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
  String get qiblaHoldFlat =>
      'امسك الموبايل مفرود، وبعيد عن المعادن والمغناطيس.';

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
  String get athanSoundTest => 'أذان تجريبي (ليس للإصدار)';

  @override
  String get athanVoice => 'صوت الأذان';

  @override
  String get athanFajrVoice => 'صوت أذان الفجر';

  @override
  String get athanVoiceSameAsAthan => 'نفس صوت الأذان';

  @override
  String get athanVoiceDevice => 'نغمة منبّه الموبايل';

  @override
  String get athanVoiceDeviceNote => 'موجودة على الموبايل دايمًا، من غير تحميل';

  @override
  String get athanVoiceUnavailable => 'صوت مبقاش متاح';

  @override
  String athanVoiceMissing(String missing, String fallback) {
    return '$missing مبقاش على الموبايل، فهيشتغل $fallback بداله. نزّله تاني عشان يرجع.';
  }

  @override
  String get athanVoicesDownloadable => 'أصوات للتحميل';

  @override
  String get athanVoicesOffline =>
      'الصوت اللي بتنزّله بيشتغل من الموبايل نفسه: الأذان والتجربة مش محتاجين نت.';

  @override
  String get athanVoicesPlatformNote =>
      'على أندرويد الأذان بيشتغل كامل لحد ما يخلص أو تدوس إيقاف. الأصوات المتحمّلة لسه مش متاحة على آيفون.';

  @override
  String get athanVoicesNone => 'مفيش أصوات للتحميل لسه.';

  @override
  String get athanVoiceKindFajr => 'أذان الفجر';

  @override
  String get athanVoiceKindAthan => 'أذان';

  @override
  String get athanVoiceReviewPending => 'لسه محدش سمعه كله: للتجربة بس';

  @override
  String athanVoiceCredit(String licence, String creator) {
    return '$licence · $creator';
  }

  @override
  String get athanVoiceOnPhone => 'على الموبايل';

  @override
  String get athanVoiceDownload => 'تحميل';

  @override
  String get athanVoiceDownloading => 'بيتحمّل';

  @override
  String get athanVoiceCancel => 'وقّف التحميل';

  @override
  String get athanVoiceRetry => 'جرّب تاني';

  @override
  String get athanVoicePreview => 'اسمع';

  @override
  String get athanVoiceStop => 'إيقاف';

  @override
  String get athanVoiceRemove => 'امسحه من الموبايل';

  @override
  String get athanVoiceSelected => 'مختار';

  @override
  String get athanVoiceFailOffline =>
      'مفيش نت. جرّب تاني لما تتوصل، واللي اتحمّل محفوظ.';

  @override
  String get athanVoiceFailServer =>
      'مقدرناش نحمّل الصوت دلوقتي. جرّب كمان شوية.';

  @override
  String athanVoiceFailSpace(String size) {
    return 'مفيش مساحة كفاية على الموبايل: محتاج $size.';
  }

  @override
  String get athanVoiceFailIntegrity => 'التحميل وصل بايظ واتمسح. جرّب تاني.';

  @override
  String get athanVoiceFailStorage => 'مقدرناش نحفظ الصوت على الموبايل.';

  @override
  String get athanVoiceFailCancelled => 'التحميل وقف، وهيكمّل من مكانه.';

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
  String get settingsDiagnostics => 'الإبلاغ عن مشكلة';

  @override
  String get diagnosticsTitle => 'الإبلاغ عن مشكلة';

  @override
  String get diagnosticsIntro =>
      'لو حصلت مشكلة، انسخ التقرير ده وابعته للدعم. ده كل اللي فيه: مكانك متقرّب لحوالي ١ كم، ومفيش أي حاجة بتعرّف عليك أو على الجهاز. التطبيق مش بيبعت أي حاجة لوحده.';

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

  @override
  String get onboardingChooseCity => 'اختار مدينتك';

  @override
  String get onboardingDetect => 'حدّد مكاني';

  @override
  String get onboardingChooseCityMyself => 'هختار مدينتي بنفسي';

  @override
  String get onboardingResolvingBody => 'ثواني ونحدّد مكانك.';

  @override
  String onboardingSuggestion(String place) {
    return 'توقيت موبايلك بيقول إنك غالبًا في $place.';
  }

  @override
  String onboardingUseSuggestion(String place) {
    return 'استخدم $place';
  }

  @override
  String get onboardingOtherCity => 'اختار مدينة تانية';

  @override
  String get onboardingFeatureOffline => 'من غير نت';

  @override
  String get onboardingFeatureAthan => 'الأذان في وقته';

  @override
  String get onboardingFeatureQibla => 'بوصلة القبلة';

  @override
  String get placeSuggestions => 'مدن في نفس توقيتك';

  @override
  String homePlaceChip(String place) {
    return '$place، غيّر المكان';
  }

  @override
  String get settingsDiagnosticsHint => 'انسخ تقرير تبعته للدعم لو حصلت مشكلة';

  @override
  String get navQuran => 'القرآن';

  @override
  String get quranTitle => 'القرآن الكريم';

  @override
  String get quranDownloadAction => 'نزّل المصحف للقراءة من غير إنترنت';

  @override
  String get quranDownloadBody =>
      'مصحف المدينة النبوية برواية حفص عن عاصم، زي ما نشره مجمع الملك فهد لطباعة المصحف الشريف. بعد تنزيل واحد، كل الصفحات والفهرس والبحث والعلامات والتظليل بيشتغلوا من غير إنترنت.';

  @override
  String quranDownloadSize(String size) {
    return 'حجم التنزيل: $size';
  }

  @override
  String quranInstalledSize(String size) {
    return 'المساحة بعد التثبيت: $size';
  }

  @override
  String quranRequiredSpace(String size) {
    return 'المساحة الفاضية المطلوبة للتثبيت: $size';
  }

  @override
  String get quranResume => 'كمّل التنزيل';

  @override
  String get quranCancel => 'وقّف التنزيل';

  @override
  String quranDownloading(String done, String total) {
    return 'بننزّل $done من $total';
  }

  @override
  String get quranInstalling => 'بنراجع كل الملفات ونجهّز البحث…';

  @override
  String get quranChecking => 'بنراجع المصحف المتنزّل…';

  @override
  String get quranPaused => 'التنزيل واقف. اللي اتنزّل محفوظ.';

  @override
  String get quranFailOffline => 'مفيش إنترنت. اتصل وجرّب تاني.';

  @override
  String quranFailServer(String code) {
    return 'سيرفر التنزيل مردّش (HTTP $code). جرّب بعدين.';
  }

  @override
  String quranFailSpace(String needed, String available) {
    return 'المساحة مش كفاية: محتاج $needed والفاضي $available.';
  }

  @override
  String get quranFailSpaceFull =>
      'مساحة الجهاز خلصت. فضّي شوية مساحة وجرّب تاني.';

  @override
  String get quranFailIntegrity => 'ملف ماعداش فحص السلامة واتمسح. جرّب تاني.';

  @override
  String get quranFailStorage => 'التطبيق مقدرش يكتب على التخزين. جرّب تاني.';

  @override
  String get quranFailSearch => 'البحث من غير إنترنت ماتجهّزش. جرّب تاني.';

  @override
  String get quranFailCancelled => 'التنزيل وقف. اللي اتنزّل محفوظ.';

  @override
  String get quranDamagedTitle => 'في ملفات من المصحف ناقصة أو بايظة';

  @override
  String quranDamagedBody(int count, String shown) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$shown ملف محتاجين يتنزّلوا تاني.',
      two: 'ملفين محتاجين يتنزّلوا تاني.',
      one: 'ملف واحد محتاج يتنزّل تاني.',
    );
    return '$_temp0 القراءة واقفة لحد ما يتصلّحوا.';
  }

  @override
  String get quranRepair => 'صلّح';

  @override
  String get quranReadyOffline => 'جاهز من غير إنترنت';

  @override
  String get quranUninstallNote =>
      'لو مسحت التطبيق أو بياناته أو شلت التنزيل، المصحف المتنزّل هيتمسح وهتحتاج تنزّله تاني.';

  @override
  String get quranAttribution =>
      'صفحات المصحف ونصّه: مجمع الملك فهد لطباعة المصحف الشريف، مصحف المدينة النبوية برواية حفص، الإصدار الرقمي ١٤٤١، مستخدمين حسب حقوق الاستخدام اللي نشرها المجمع. التطبيق مش صادر عن المجمع ولا معتمد منه.';

  @override
  String get quranJuzAttribution =>
      'بدايات الأجزاء ومراجعة أسماء السور بالإنجليزية: بيانات Tanzil.net (CC BY 3.0)، متراجعة على نص المجمع.';

  @override
  String get quranAyahsOnPage => 'آيات هذه الصفحة';

  @override
  String get quranAyahsOnLine => 'آيات هذا السطر';

  @override
  String get quranAyahHint => 'اضغط مطولًا على سطر في الصفحة لعرض آياته.';

  @override
  String get quranAyahHighlight => 'تظليل الآية';

  @override
  String get quranAyahRemoveHighlight => 'إزالة التظليل';

  @override
  String get quranAyahCopy => 'نسخ الآية';

  @override
  String get quranAyahCopied => 'تم نسخ الآية';

  @override
  String get quranAyahShow => 'إظهارها في الصفحة';

  @override
  String get quranAyahLinesNote =>
      'تظليل الآية يغطي الأسطر التي تقع عليها كاملة، فالسطر الذي تشترك فيه مع آية أخرى يُظلَّل كله.';

  @override
  String get quranAyahHighlights => 'الآيات المظللة';

  @override
  String quranAyahRef(String surah, String sura, String aya) {
    return '$surah، الآية $aya';
  }

  @override
  String quranJuzSurahLine(String verse, String page) {
    return 'من الآية $verse · صفحة $page';
  }

  @override
  String quranSurahPages(String surah, String first, String last) {
    return '$surah · الصفحات $first–$last';
  }

  @override
  String get quranSurahPagesHint =>
      'دوس على صفحة عشان تفتحها، أو اسحب عشان تتنقل جوه السورة.';

  @override
  String quranPage(String page) {
    return 'صفحة $page';
  }

  @override
  String quranJuz(String juz) {
    return 'الجزء $juz';
  }

  @override
  String get quranNextPage => 'الصفحة اللي بعدها';

  @override
  String get quranPreviousPage => 'الصفحة اللي قبلها';

  @override
  String get quranZoomIn => 'كبّر';

  @override
  String get quranZoomOut => 'صغّر';

  @override
  String get quranResetZoom => 'على قد الشاشة';

  @override
  String get quranFitPage => 'الصفحة كاملة';

  @override
  String get quranFitWidth => 'على عرض الشاشة';

  @override
  String get quranFacingPages => 'صفحتين جنب بعض في الشاشات العريضة';

  @override
  String get quranShowHighlights => 'اعرض التظليل';

  @override
  String get quranGoToPage => 'روح لصفحة';

  @override
  String quranGoToPageHint(String count) {
    return 'من ١ لـ $count';
  }

  @override
  String quranGoToPageInvalid(String count) {
    return 'اكتب رقم صفحة من ١ لـ $count.';
  }

  @override
  String get quranGo => 'روح';

  @override
  String get quranIndex => 'السور والأجزاء';

  @override
  String get quranSurahsTab => 'السور';

  @override
  String get quranJuzTab => 'الأجزاء';

  @override
  String get quranFilterSurahs => 'دوّر على سورة بالاسم أو الرقم';

  @override
  String quranSurahLine(String number, String verses, String page) {
    return 'سورة رقم $number · $verses آية · صفحة $page';
  }

  @override
  String quranJuzLine(String page) {
    return 'بيبدأ من صفحة $page';
  }

  @override
  String get quranNoSurah => 'مفيش سورة بالاسم ده.';

  @override
  String get quranSearch => 'دوّر في القرآن';

  @override
  String get quranSearchHint => 'كلمة أو جملة بالعربي';

  @override
  String get quranSearchIdle =>
      'اكتب كلمة أو جزء من آية. البحث بيشتغل من غير إنترنت ومش بيفرّق بين التشكيل ولا أشكال الألف والهمزة.';

  @override
  String get quranSearchEmpty => 'مفيش آية فيها الكلام ده.';

  @override
  String quranSearchCount(int count, String shown) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$shown آية',
      two: 'آيتين',
      one: 'آية واحدة',
    );
    return '$_temp0';
  }

  @override
  String quranSearchMore(String shown, String total) {
    return 'بنعرض أول $shown من $total آية. اكتب أكتر علشان تضيّق البحث.';
  }

  @override
  String quranVerseRef(String verse, String page) {
    return 'آية $verse · صفحة $page';
  }

  @override
  String get quranBookmarkAdd => 'علّم الصفحة دي';

  @override
  String get quranBookmarkRemove => 'شيل العلامة';

  @override
  String get quranNotes => 'العلامات والتظليل';

  @override
  String get quranBookmarksTab => 'العلامات';

  @override
  String get quranHighlightsTab => 'تظليلاتي';

  @override
  String get quranNoBookmarks =>
      'لسه مفيش علامات. استخدم زرار العلامة على أي صفحة.';

  @override
  String get quranNoHighlights => 'لسه مفيش تظليل. اختار «ظلّل» على أي صفحة.';

  @override
  String get quranHighlight => 'ظلّل';

  @override
  String get quranAreaExplain =>
      'تظليل بالمساحة: ارسم مربعات على الصفحة. ده بيعلّم جزء من صورة الصفحة، مش كلمات أو آيات بعينها. قلّب بالزراير علشان تكمّل في صفحة تانية.';

  @override
  String get quranHighlightSave => 'احفظ';

  @override
  String get quranHighlightUndo => 'امسح آخر مربع';

  @override
  String get quranHighlightCancel => 'إلغاء';

  @override
  String quranHighlightBoxes(int count, String shown) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$shown مربع',
      two: 'مربعين',
      one: 'مربع واحد',
    );
    return '$_temp0';
  }

  @override
  String quranHighlightPages(String first, String last) {
    return 'صفحات $first–$last';
  }

  @override
  String get quranHighlightDelete => 'امسح التظليل';

  @override
  String get quranHighlightOpen => 'افتح';

  @override
  String get quranHighlightColor => 'اللون';

  @override
  String get quranColorYellow => 'أصفر';

  @override
  String get quranColorGreen => 'أخضر';

  @override
  String get quranColorBlue => 'أزرق';

  @override
  String get quranColorPink => 'وردي';

  @override
  String get quranColorOrange => 'برتقالي';

  @override
  String get quranStorage => 'تنزيل المصحف';

  @override
  String quranEdition(String edition, String version) {
    return 'مصحف المدينة النبوية · حفص · الإصدار الرقمي $edition · الحزمة $version';
  }

  @override
  String quranOnDevice(String size) {
    return 'على الجهاز: $size';
  }

  @override
  String get quranVerify => 'راجع كل الملفات';

  @override
  String quranVerifying(String done, String total) {
    return 'بنراجع $done من $total ملف…';
  }

  @override
  String quranVerified(int count, String shown) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'كل الـ $shown ملف عدّوا فحص السلامة.',
      one: 'الملف عدّى فحص السلامة.',
    );
    return '$_temp0';
  }

  @override
  String get quranRemove => 'شيل التنزيل';

  @override
  String get quranRemoveTitle => 'تشيل المصحف المتنزّل؟';

  @override
  String quranRemoveBody(String size) {
    return 'القراءة من غير إنترنت هتقف لحد ما تنزّله تاني ($size). علاماتك وتظليلك وآخر صفحة هيفضلوا محفوظين ويرجعوا لما تنزّله تاني.';
  }

  @override
  String get quranRemoveConfirm => 'شيله';

  @override
  String get quranKeep => 'خلّيه';

  @override
  String get quranRemoved => 'المصحف المتنزّل اتشال. ملاحظاتك محفوظة.';

  @override
  String get quranPageError =>
      'الصفحة دي ماظهرتش. راجع الملفات من «تنزيل المصحف».';

  @override
  String get quranOpening => 'بنفتح المصحف…';

  @override
  String quranReaderLabel(String page) {
    return 'صفحة $page من المصحف. اسحب يمين أو استخدم «الصفحة اللي بعدها» علشان تكمّل.';
  }

  @override
  String get quranMore => 'المزيد';

  @override
  String get quranShowControls => 'اعرض الأزرار';

  @override
  String get quranUpdate => 'نزّل التحديث';

  @override
  String get quranUpdateBody =>
      'في نسخة أحدث من حزمة المصحف. النسخة اللي على جهازك هتفضل شغّالة لحد ما الجديدة تتنزّل وتتراجع.';
}
