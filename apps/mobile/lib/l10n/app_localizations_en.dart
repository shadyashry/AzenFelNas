// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Azen Fel Nas';

  @override
  String get homeTitle => 'Today';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get languageArabic => 'العربية';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSystem => 'Device language';

  @override
  String get settingsDigits => 'Digits';

  @override
  String get digitsLocale => 'Same as language';

  @override
  String get digitsWestern => '0123456789';

  @override
  String get digitsArabicIndic => '٠١٢٣٤٥٦٧٨٩';

  @override
  String get settingsTheme => 'Appearance';

  @override
  String get themeSky => 'Dynamic (changes with prayer times)';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeSystem => 'Same as device';

  @override
  String get settingsReducedMotion => 'Reduce motion';

  @override
  String get settingsAttributions => 'Data sources and licences';

  @override
  String get attributionsOpenSource => 'Open-source licences';

  @override
  String get qiblaTitle => 'Qibla';

  @override
  String get passportTitle => 'Accuracy Passport';

  @override
  String get notYetAvailable => 'This screen arrives in a later update.';

  @override
  String get needsAttentionTitle => 'Needs attention';

  @override
  String needsAttentionCode(String code) {
    return 'Code $code';
  }

  @override
  String get startupFailedTitle => 'The app could not open its data';

  @override
  String get remediationGrantLocationPermission =>
      'Allow location access, or choose a place yourself.';

  @override
  String get remediationTurnOnLocationServices =>
      'Turn on location in the device settings, or choose a place yourself.';

  @override
  String get remediationChooseManualPlace => 'Choose your city from the list.';

  @override
  String get remediationWaitForDataUpdate =>
      'Nothing to do now. A data update will fix this.';

  @override
  String get remediationRetryWhenOnline =>
      'Connect to the internet. The app will try again.';

  @override
  String get remediationFreeUpStorage => 'Free some storage on the device.';

  @override
  String get remediationTryAgain => 'Try again.';

  @override
  String get remediationUpdateApp => 'Install the latest version of the app.';

  @override
  String get remediationGrantAlarmPermission =>
      'Allow alarms and notifications so the Athan can sound on time.';

  @override
  String get remediationOpenAthanHealth => 'Open Athan Health for the details.';

  @override
  String get remediationCheckDeviceClock =>
      'Set the device\'s date and time to update automatically.';

  @override
  String get remediationActionTurnOnLocation => 'Turn on location';

  @override
  String get remediationActionOpenSettings => 'Open settings';

  @override
  String get onboardingUseLocation => 'Use approximate location';

  @override
  String get onboardingChoosePlace => 'Choose a place';

  @override
  String get onboardingResolving => 'Finding your place…';

  @override
  String get onboardingFailedTitle => 'Location is not available';

  @override
  String get onboardingDoneTitle => 'Your times are ready';

  @override
  String onboardingDoneBody(String place) {
    return 'Prayer times for $place.';
  }

  @override
  String get onboardingAthanPermissions =>
      'So the Athan sounds on time, the next screens ask to allow notifications and alarms.';

  @override
  String get onboardingShowTimes => 'Show today\'s times';

  @override
  String get placeTitle => 'Choose a place';

  @override
  String get placeSearchHint => 'City name';

  @override
  String get placeIdle => 'Search the offline list of cities.';

  @override
  String get placeSearching => 'Searching…';

  @override
  String get placeEmpty => 'No place found. Try another spelling.';

  @override
  String get placeEnterCoordinates => 'Enter coordinates';

  @override
  String get placeLatitude => 'Latitude';

  @override
  String get placeLongitude => 'Longitude';

  @override
  String get placeName => 'Place name';

  @override
  String get placeCoordinatesInvalid =>
      'Latitude from -90 to 90, longitude from -180 to 180.';

  @override
  String get placeUse => 'Use this place';

  @override
  String get homeContinueQuran => 'Continue Quran';

  @override
  String get homeQuranResume => 'Resume';

  @override
  String get homeQuranOffline => 'Available offline';

  @override
  String homeSurahNumber(String number) {
    return 'Surah $number';
  }

  @override
  String get timeAm => 'AM';

  @override
  String get timePm => 'PM';

  @override
  String homeNextPrayer(String prayer) {
    return 'Next: $prayer';
  }

  @override
  String homeCountdown(int hours, int minutes) {
    return 'in $hours h $minutes min';
  }

  @override
  String get homeNoNextPrayer => 'No further prayer in the coming days';

  @override
  String get homeNeedsLocation => 'Choose where to show prayer times for.';

  @override
  String get homeNoProfile =>
      'No local timetable for this area yet; times use the standard method.';

  @override
  String get homeHealthUnknown => 'Athan: not set up yet';

  @override
  String get homeCurrentPlace => 'Your location';

  @override
  String get timelineTitle => 'Next 7 days';

  @override
  String get prayerImsak => 'Imsak';

  @override
  String get prayerFajr => 'Fajr';

  @override
  String get prayerSunrise => 'Sunrise';

  @override
  String get prayerDhuhr => 'Dhuhr';

  @override
  String get prayerAsr => 'Asr';

  @override
  String get prayerMaghrib => 'Maghrib';

  @override
  String get prayerIsha => 'Isha';

  @override
  String get noTimeText => '—';

  @override
  String get noTimeReason => 'no time on this day';

  @override
  String get passportNotFoundTitle => 'This calculation is not on this device';

  @override
  String get passportNotFoundBody =>
      'The link\'s Calculation ID is not in this week\'s times and the link carries no inputs to recompute it.';

  @override
  String get passportMismatchTitle => 'Computed differently on this device';

  @override
  String get passportMismatchVersions =>
      'This time was computed with a different engine, profile or time-zone data version.';

  @override
  String passportMismatchProfile(String profile, String version) {
    return 'This device does not have profile $profile version $version.';
  }

  @override
  String get passportMismatchZone =>
      'This device\'s time-zone data does not include the shared place\'s zone.';

  @override
  String passportLinkId(String id) {
    return 'In the link: $id';
  }

  @override
  String passportLocalId(String id) {
    return 'On this device: $id';
  }

  @override
  String passportThisDevice(String engine, String tzdb) {
    return 'This device: engine $engine, time-zone data $tzdb';
  }

  @override
  String get passportImportMatch =>
      'Recomputed on this device: the result matches the link.';

  @override
  String get passportCopyLink => 'Copy link';

  @override
  String get passportLinkCopied => 'Link copied';

  @override
  String get passportInputsTitle => 'Inputs';

  @override
  String get passportVersionsTitle => 'Versions';

  @override
  String get passportCoordinates => 'Coordinates';

  @override
  String get passportZone => 'Time zone';

  @override
  String get passportDay => 'Day';

  @override
  String get passportProfile => 'Profile';

  @override
  String get passportHijri => 'Hijri date (dawn / night)';

  @override
  String get passportEngine => 'Engine';

  @override
  String get passportDeltaT => 'ΔT model';

  @override
  String get passportTzdb => 'Time-zone data';

  @override
  String get passportInputsHash => 'Inputs hash';

  @override
  String passportRaw(String time) {
    return 'Calculated instant $time';
  }

  @override
  String passportShown(String time) {
    return 'Shown as $time';
  }

  @override
  String get passportRoundingCeil => 'Rounded up to the next minute';

  @override
  String get passportRoundingFloor => 'Rounded down to the minute';

  @override
  String get passportRoundingNearest => 'Rounded to the nearest minute';

  @override
  String get passportOriginPrimary => 'From the astronomical rule';

  @override
  String passportOriginFallback(String method) {
    return 'From the high-latitude method $method';
  }

  @override
  String passportOriginNoEvent(String reason) {
    return 'No time on this day ($reason)';
  }

  @override
  String passportSensitivity(int seconds) {
    return '±1 km changes this by ≤ $seconds s';
  }

  @override
  String passportAdjustment(String kind, String seconds) {
    return '$kind: $seconds s';
  }

  @override
  String get passportAdjustOffset => 'Offset';

  @override
  String get passportAdjustRamadan => 'Ramadan rule';

  @override
  String get passportAdjustHighLatitude => 'High-latitude method';

  @override
  String get passportAdjustRounding => 'Rounding';

  @override
  String get flagNearRoundingBoundary =>
      'The calculated instant is within half a second of a minute boundary.';

  @override
  String get flagHighLatitudeFallback =>
      'A high-latitude method gave this time.';

  @override
  String get flagLowLocationAccuracy => 'Your location is approximate.';

  @override
  String get flagDstTransitionDay => 'The clocks change on this day.';

  @override
  String get flagStaleTzdb => 'The time-zone data on this device is old.';

  @override
  String get flagHijriExpected =>
      'The Hijri date is expected, not yet announced.';

  @override
  String get flagReferenceModeAuthorityPoint =>
      'Calculated at the authority\'s reference point for your area.';

  @override
  String get flagManualCoordinateResolution => 'The place was chosen by hand.';

  @override
  String get flagZoneBoundaryProximity => 'You are near a time-zone border.';

  @override
  String get flagNoLocalProfile =>
      'No local profile covers this place; the engine default is used.';

  @override
  String get passportNoFlags => 'No flags for this time.';

  @override
  String get qiblaNoHeading => 'Waiting for the compass…';

  @override
  String get qiblaNumericOnly =>
      'This device has no usable compass. Face the bearing below using a map or a physical compass.';

  @override
  String get qiblaCalibrating =>
      'Compass accuracy is low. Move the phone in a figure-eight away from metal.';

  @override
  String qiblaBearing(String degrees) {
    return 'Qibla: $degrees° from true north';
  }

  @override
  String qiblaDistance(String km) {
    return '$km km to the Kaaba';
  }

  @override
  String qiblaAccuracy(String degrees) {
    return 'Compass accuracy ±$degrees°';
  }

  @override
  String qiblaTurn(String degrees, String direction) {
    return 'Turn $degrees° $direction';
  }

  @override
  String get qiblaRight => 'right';

  @override
  String get qiblaLeft => 'left';

  @override
  String get qiblaFacing => 'You are facing the Qibla.';

  @override
  String get qiblaHoldFlat =>
      'Hold the phone flat, away from metal and magnets.';

  @override
  String get qiblaNeedsPlace => 'Choose a place to see the Qibla.';

  @override
  String get qiblaShadowTitle => 'Qibla by the Sun\'s shadow';

  @override
  String get qiblaShadowFootnote =>
      'No compass needed: stand a stick, pole or plumb line upright. At these times its shadow lies on the Qibla line.';

  @override
  String get qiblaShadowToward =>
      'Face the Sun. The Qibla runs from the tip of the shadow to the base of the stick.';

  @override
  String get qiblaShadowAway =>
      'The Sun is behind you. The Qibla runs from the base of the stick along the shadow to its tip.';

  @override
  String qiblaShadowWindow(String start, String end) {
    return 'Within 1° from $start to $end';
  }

  @override
  String get qiblaShadowPassed => 'Passed';

  @override
  String get qiblaShadowHighSun =>
      'Hard to use: the Sun is high, so the shadow is short.';

  @override
  String get qiblaShadowBriefWindow =>
      'Hard to use: the window is under two minutes.';

  @override
  String qiblaShadowNextDay(String date) {
    return 'None today. Next: $date';
  }

  @override
  String get qiblaShadowNone =>
      'The Sun does not line up with the Qibla here in the next 8 days.';

  @override
  String planAthanTitle(String prayer) {
    return '$prayer Athan';
  }

  @override
  String planAthanBody(String prayer) {
    return 'It is time for $prayer.';
  }

  @override
  String get planImsakTitle => 'Imsak';

  @override
  String get planImsakBody => 'It is Imsak time.';

  @override
  String planPreReminderTitle(String prayer, int minutes) {
    return '$prayer in $minutes min';
  }

  @override
  String planPreReminderBody(String prayer, int minutes) {
    return 'The $prayer Athan is in $minutes minutes.';
  }

  @override
  String get planHorizonTitle => 'Athan schedule ends soon';

  @override
  String get planHorizonBody =>
      'Open Azen Fel Nas to keep the Athan scheduled.';

  @override
  String get athanTitle => 'Athan';

  @override
  String get settingsAthan => 'Athan';

  @override
  String get athanHealthTitle => 'Athan readiness';

  @override
  String get athanHealthEvaluating => 'Checking…';

  @override
  String get athanHealthReady => 'Ready: the Athan will sound';

  @override
  String get athanHealthLimited => 'Limited: the Athan may be late or quiet';

  @override
  String get athanHealthNotReady => 'Not ready: the Athan will not sound';

  @override
  String get athanHealthUnknown => 'Not available · the phone cannot tell';

  @override
  String get athanReasonNeedsNotificationPermission =>
      'Allow notifications for Azen Fel Nas';

  @override
  String get athanReasonNeedsExactAlarmPermission =>
      'Allow alarms and reminders';

  @override
  String get athanReasonNeedsAlarmKitAuthorization =>
      'Allow alarms for Azen Fel Nas';

  @override
  String get athanReasonMutedChannel =>
      'The Athan sound is muted in system settings';

  @override
  String get athanReasonBatteryRestricted =>
      'The phone restricts Azen Fel Nas in the background';

  @override
  String get athanReasonStalePlan => 'Open the app to schedule the Athan';

  @override
  String get athanReasonHorizonEnding =>
      'The Athan schedule ends soon; open the app';

  @override
  String get athanReasonFailedTest => 'You did not hear the last test';

  @override
  String get athanReasonClockSkew => 'The phone clock looks wrong';

  @override
  String get athanReasonNoSoundAsset => 'No Athan sound is installed';

  @override
  String get athanReasonInexactFallback =>
      'Without “Alarms & reminders” the Athan may be up to an hour late';

  @override
  String get athanReasonUnverifiableDelivery =>
      'This phone cannot confirm the Athan played';

  @override
  String get athanReasonForceStoppedPreviously =>
      'The app was force-stopped before; alarms were lost then';

  @override
  String get athanGrantAllow => 'Allow';

  @override
  String get athanGrantOpenSettings => 'Open settings';

  @override
  String get athanTestTitle => 'Athan test';

  @override
  String get athanTestStart => 'Play a test Athan in 10 seconds';

  @override
  String get athanTestNeedsSound => 'Choose an Athan sound first';

  @override
  String get athanTestFired => 'The test Athan should be playing now';

  @override
  String get athanTestAsk => 'Did you hear it?';

  @override
  String get athanTestYes => 'Yes';

  @override
  String get athanTestNo => 'No';

  @override
  String get athanTestHeard => 'Recorded: you heard the test';

  @override
  String get athanTestNotHeard => 'Recorded: you did not hear the test';

  @override
  String get athanTestNotArmed => 'The phone did not schedule the test';

  @override
  String get athanTestAgain => 'Test again';

  @override
  String get athanSoundTest => 'Test Athan (not for release)';

  @override
  String get athanVoice => 'Athan voice';

  @override
  String get athanFajrVoice => 'Fajr Athan voice';

  @override
  String get athanVoiceSameAsAthan => 'Same as the Athan voice';

  @override
  String get athanVoiceDevice => 'Phone alarm tone';

  @override
  String get athanVoiceDeviceNote => 'Always on the phone, no download';

  @override
  String get athanVoiceUnavailable => 'A voice that is no longer offered';

  @override
  String athanVoiceMissing(String missing, String fallback) {
    return '$missing is not on this phone any more, so $fallback plays instead. Download it again to bring it back.';
  }

  @override
  String get athanVoicesDownloadable => 'Voices to download';

  @override
  String get athanVoicesOffline =>
      'A downloaded voice plays from the phone itself: the Athan and the preview need no internet.';

  @override
  String get athanVoicesPlatformNote =>
      'On Android the whole Athan plays until it ends or you tap Stop. Downloaded voices are not on iPhone yet.';

  @override
  String get athanVoicesNone => 'No voices to download yet.';

  @override
  String get athanVoiceKindFajr => 'Fajr Athan';

  @override
  String get athanVoiceKindAthan => 'Athan';

  @override
  String get athanVoiceReviewPending =>
      'Not yet listened to in full: for testing only';

  @override
  String athanVoiceCredit(String licence, String creator) {
    return '$licence · $creator';
  }

  @override
  String get athanVoiceOnPhone => 'On this phone';

  @override
  String get athanVoiceDownload => 'Download';

  @override
  String get athanVoiceDownloading => 'Downloading';

  @override
  String get athanVoiceCancel => 'Stop download';

  @override
  String get athanVoiceRetry => 'Try again';

  @override
  String get athanVoicePreview => 'Listen';

  @override
  String get athanVoiceStop => 'Stop';

  @override
  String get athanPlayingNow => 'The Athan is playing';

  @override
  String get athanStopNow => 'Stop';

  @override
  String get athanVoiceRemove => 'Remove from phone';

  @override
  String get athanVoiceSelected => 'Selected';

  @override
  String get athanVoiceFailOffline =>
      'No internet. Try again when you are connected; what downloaded is kept.';

  @override
  String get athanVoiceFailServer =>
      'The voice could not be downloaded right now. Try again later.';

  @override
  String athanVoiceFailSpace(String size) {
    return 'Not enough space on the phone: $size needed.';
  }

  @override
  String get athanVoiceFailIntegrity =>
      'The download arrived damaged and was deleted. Try again.';

  @override
  String get athanVoiceFailStorage =>
      'The voice could not be saved on this phone.';

  @override
  String get athanVoiceFailCancelled =>
      'Download stopped; it continues where it left off.';

  @override
  String get athanPrayersTitle => 'Athan for';

  @override
  String get athanPreReminder => 'Reminder before the Athan';

  @override
  String get athanPreReminderOff => 'Off';

  @override
  String athanTestScheduled(int seconds) {
    return 'Test Athan in $seconds s';
  }

  @override
  String athanPreReminderMinutes(int minutes) {
    return '$minutes min before';
  }

  @override
  String get settingsDiagnostics => 'Report a problem';

  @override
  String get diagnosticsTitle => 'Report a problem';

  @override
  String get diagnosticsIntro =>
      'If something goes wrong, copy this report and send it to support. This is everything it contains: your place is rounded to about 1 km and nothing identifies you or this device. Nothing is sent by the app itself.';

  @override
  String get diagnosticsCopy => 'Copy report';

  @override
  String get diagnosticsCopied => 'Report copied';

  @override
  String get diagnosticsUnavailable => 'The report could not be prepared.';

  @override
  String homeFastingTitle(int day) {
    return 'Ramadan $day';
  }

  @override
  String homeFastingWindow(String begins, String ends) {
    return 'Fast from $begins to $ends';
  }

  @override
  String homeFastingImsak(String time) {
    return 'Imsak $time';
  }

  @override
  String get homeFastingUnknown =>
      'Fajr or Maghrib has no time here today; follow your local authority.';

  @override
  String get homeHijriOverride => 'Hijri day';

  @override
  String get homeHijriOverrideApplied => 'Adjusted by you';

  @override
  String travelPrompt(String city) {
    return 'You seem to be in $city. Switch schedule?';
  }

  @override
  String get travelSwitch => 'Switch';

  @override
  String get travelNotNow => 'Not now';

  @override
  String homeCountdownMinutes(int minutes) {
    return 'in $minutes min';
  }

  @override
  String homeCartouche(String prayer) {
    return '$prayer';
  }

  @override
  String homeHijriDate(String day, String monthName, String year) {
    return '$day $monthName $year AH';
  }

  @override
  String hijriMonthName(String month) {
    String _temp0 = intl.Intl.selectLogic(
      month,
      {
        '1': 'Muharram',
        '2': 'Safar',
        '3': 'Rabi al-Awwal',
        '4': 'Rabi al-Thani',
        '5': 'Jumada al-Ula',
        '6': 'Jumada al-Akhirah',
        '7': 'Rajab',
        '8': 'Shaban',
        '9': 'Ramadan',
        '10': 'Shawwal',
        '11': 'Dhu al-Qadah',
        '12': 'Dhu al-Hijjah',
        'other': '',
      },
    );
    return '$_temp0';
  }

  @override
  String get navHome => 'Home';

  @override
  String get navQibla => 'Qibla';

  @override
  String get navAthan => 'Athan';

  @override
  String get navSettings => 'Settings';

  @override
  String get compassNorth => 'N';

  @override
  String get compassEast => 'E';

  @override
  String get compassSouth => 'S';

  @override
  String get compassWest => 'W';

  @override
  String qiblaDegrees(String degrees) {
    return '$degrees°';
  }

  @override
  String get settingsDisplaySection => 'Display';

  @override
  String get settingsMoreSection => 'More';

  @override
  String onboardingSuggestion(String place) {
    return 'Your phone\'s time zone suggests $place.';
  }

  @override
  String onboardingUseSuggestion(String place) {
    return 'Use $place';
  }

  @override
  String get placeSuggestions => 'Cities in your time zone';

  @override
  String homePlaceChip(String place) {
    return '$place, change place';
  }

  @override
  String get settingsDiagnosticsHint =>
      'Copy a report for support if something goes wrong';

  @override
  String get navQuran => 'Quran';

  @override
  String get quranTitle => 'The Holy Quran';

  @override
  String get quranDownloadAction => 'Download Quran for offline use';

  @override
  String get quranDownloadBody =>
      'The Madinah Mushaf (Hafs ʿan ʿĀṣim), as published by the King Fahd Glorious Quran Printing Complex. After one download every page, the surah and juz index, search, bookmarks and highlights work with no internet.';

  @override
  String get quranBundledBody =>
      'The Madinah Mushaf (Hafs ʿan ʿĀṣim), as published by the King Fahd Glorious Quran Printing Complex, comes with the app. It is prepared once on this phone, with no internet; then every page, the surah and juz index, search, bookmarks and highlights work offline.';

  @override
  String get quranInstallAction => 'Open the Quran';

  @override
  String quranPreparing(String done, String total) {
    return 'Preparing the Quran: $done of $total';
  }

  @override
  String quranDownloadSize(String size) {
    return 'Download size: $size';
  }

  @override
  String quranInstalledSize(String size) {
    return 'Space after installing: $size';
  }

  @override
  String quranRequiredSpace(String size) {
    return 'Free space needed to install: $size';
  }

  @override
  String get quranResume => 'Resume download';

  @override
  String get quranCancel => 'Stop';

  @override
  String quranDownloading(String done, String total) {
    return 'Downloading $done of $total';
  }

  @override
  String get quranInstalling => 'Checking every file and preparing search…';

  @override
  String get quranChecking => 'Checking the downloaded Quran…';

  @override
  String get quranPaused => 'Download paused. What was downloaded is kept.';

  @override
  String get quranFailOffline =>
      'No internet connection. Connect and try again.';

  @override
  String quranFailServer(String code) {
    return 'The download server did not answer (HTTP $code). Try again later.';
  }

  @override
  String quranFailSpace(String needed, String available) {
    return 'Not enough space: $needed needed, $available free.';
  }

  @override
  String get quranFailSpaceFull =>
      'The device ran out of space. Free up space and try again.';

  @override
  String get quranFailIntegrity =>
      'A file failed its integrity check and was discarded. Try again.';

  @override
  String get quranFailStorage =>
      'The app could not write to its storage. Try again.';

  @override
  String get quranFailSearch =>
      'The offline search could not be prepared. Try again.';

  @override
  String get quranFailCancelled =>
      'Download stopped. What was downloaded is kept.';

  @override
  String get quranDamagedTitle => 'Some Quran files are missing or damaged';

  @override
  String quranDamagedBody(int count, String shown) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$shown files need to be downloaded again.',
      one: 'One file needs to be downloaded again.',
    );
    return '$_temp0 Reading is paused until they are repaired.';
  }

  @override
  String get quranRepair => 'Repair';

  @override
  String get quranReadyOffline => 'Ready offline';

  @override
  String get quranUninstallNote =>
      'Removing the Quran, clearing the app\'s data or uninstalling the app deletes the copy on this phone; you would need to install it again.';

  @override
  String get quranAttribution =>
      'Mushaf pages and text: King Fahd Glorious Quran Printing Complex, Madinah Mushaf (Hafs), digital edition 1441, used under the Complex\'s published usage terms. The app is not published or endorsed by the Complex.';

  @override
  String get quranJuzAttribution =>
      'Juz boundaries and the check of the English surah names: Tanzil.net Quran metadata (CC BY 3.0), checked against the Complex\'s text.';

  @override
  String get quranAyahsOnPage => 'Ayahs on this page';

  @override
  String get quranAyahsOnLine => 'Ayahs on this line';

  @override
  String get quranAyahHint =>
      'Press and hold a line of the page to see its ayahs.';

  @override
  String get quranAyahHighlight => 'Highlight this ayah';

  @override
  String get quranAyahRemoveHighlight => 'Remove highlight';

  @override
  String get quranAyahCopy => 'Copy ayah';

  @override
  String get quranAyahCopied => 'Ayah copied';

  @override
  String get quranAyahShow => 'Show on the page';

  @override
  String get quranAyahLinesNote =>
      'An ayah highlight covers the whole lines the ayah is on, so a line it shares with another ayah is covered whole.';

  @override
  String get quranAyahHighlights => 'Highlighted ayahs';

  @override
  String quranAyahRef(String surah, String sura, String aya) {
    return '$surah $sura:$aya';
  }

  @override
  String quranJuzSurahLine(String verse, String page) {
    return 'From verse $verse · page $page';
  }

  @override
  String quranSurahPages(String surah, String first, String last) {
    return '$surah · pages $first–$last';
  }

  @override
  String get quranSurahPagesHint => 'Tap a page to open it.';

  @override
  String quranPage(String page) {
    return 'Page $page';
  }

  @override
  String quranJuz(String juz) {
    return 'Juz $juz';
  }

  @override
  String get quranNextPage => 'Next page';

  @override
  String get quranPreviousPage => 'Previous page';

  @override
  String get quranZoomIn => 'Zoom in';

  @override
  String get quranZoomOut => 'Zoom out';

  @override
  String get quranResetZoom => 'Fit to screen';

  @override
  String get quranFitPage => 'Whole page';

  @override
  String get quranFitWidth => 'Fit width';

  @override
  String get quranFacingPages => 'Two facing pages on wide screens';

  @override
  String get quranShowHighlights => 'Show highlights';

  @override
  String get quranGoToPage => 'Go to page';

  @override
  String quranGoToPageHint(String count) {
    return '1 to $count';
  }

  @override
  String quranGoToPageInvalid(String count) {
    return 'Enter a page from 1 to $count.';
  }

  @override
  String get quranGo => 'Go';

  @override
  String get quranIndex => 'Surahs and juz';

  @override
  String get quranSurahsTab => 'Surahs';

  @override
  String get quranJuzTab => 'Juz';

  @override
  String get quranFilterSurahs => 'Find a surah by name or number';

  @override
  String quranSurahLine(String number, String verses, String page) {
    return 'Surah $number · $verses verses · page $page';
  }

  @override
  String quranJuzLine(String page) {
    return 'Starts at page $page';
  }

  @override
  String get quranNoSurah => 'No surah matches.';

  @override
  String get quranSearch => 'Search the Quran';

  @override
  String get quranSearchHint => 'Arabic word or phrase';

  @override
  String get quranSearchIdle =>
      'Type an Arabic word or part of a verse. Search works offline and ignores diacritics and the different spellings of alef and hamza.';

  @override
  String get quranSearchEmpty => 'No verse matches.';

  @override
  String quranSearchCount(int count, String shown) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$shown verses',
      one: 'One verse',
    );
    return '$_temp0';
  }

  @override
  String quranSearchMore(String shown, String total) {
    return 'Showing the first $shown of $total verses. Type more to narrow it.';
  }

  @override
  String quranVerseRef(String verse, String page) {
    return 'Verse $verse · page $page';
  }

  @override
  String get quranBookmarkAdd => 'Bookmark this page';

  @override
  String get quranBookmarkRemove => 'Remove bookmark';

  @override
  String get quranNotes => 'Bookmarks and highlights';

  @override
  String get quranBookmarksTab => 'Bookmarks';

  @override
  String get quranHighlightsTab => 'My highlights';

  @override
  String get quranNoBookmarks =>
      'No bookmarks yet. Use the bookmark button on a page.';

  @override
  String get quranNoHighlights =>
      'No highlights yet. Choose Highlight on a page.';

  @override
  String get quranHighlight => 'Highlight';

  @override
  String get quranAreaExplain =>
      'Area highlight: draw boxes over the page. It marks a region of the page image, not specific words or verses. Turn pages with the buttons to continue on another page.';

  @override
  String get quranHighlightSave => 'Save';

  @override
  String get quranHighlightUndo => 'Undo last box';

  @override
  String get quranHighlightCancel => 'Cancel';

  @override
  String quranHighlightBoxes(int count, String shown) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$shown boxes',
      one: 'one box',
    );
    return '$_temp0';
  }

  @override
  String quranHighlightPages(String first, String last) {
    return 'Pages $first–$last';
  }

  @override
  String get quranHighlightDelete => 'Delete highlight';

  @override
  String get quranHighlightOpen => 'Open';

  @override
  String get quranHighlightColor => 'Colour';

  @override
  String get quranColorYellow => 'Yellow';

  @override
  String get quranColorGreen => 'Green';

  @override
  String get quranColorBlue => 'Blue';

  @override
  String get quranColorPink => 'Pink';

  @override
  String get quranColorOrange => 'Orange';

  @override
  String get quranStorage => 'Quran on this phone';

  @override
  String quranEdition(String edition, String version) {
    return 'Madinah Mushaf · Hafs · digital edition $edition · package $version';
  }

  @override
  String quranOnDevice(String size) {
    return 'On this device: $size';
  }

  @override
  String get quranVerify => 'Check all files';

  @override
  String quranVerifying(String done, String total) {
    return 'Checking $done of $total files…';
  }

  @override
  String quranVerified(int count, String shown) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'All $shown files passed the integrity check.',
      one: 'The file passed the integrity check.',
    );
    return '$_temp0';
  }

  @override
  String get quranRemove => 'Remove the Quran';

  @override
  String get quranRemoveTitle => 'Remove the downloaded Quran?';

  @override
  String quranRemoveBody(String size) {
    return 'Offline reading stops until you download it again ($size). Your bookmarks, highlights and last page are kept and come back when you download it again.';
  }

  @override
  String get quranRemoveConfirm => 'Remove';

  @override
  String get quranKeep => 'Keep';

  @override
  String get quranRemoved =>
      'The Quran download was removed. Your notes are kept.';

  @override
  String get quranPageError =>
      'This page could not be shown. Check the files under Quran download.';

  @override
  String get quranOpening => 'Opening the Mushaf…';

  @override
  String quranReaderLabel(String page) {
    return 'Mushaf page $page. Swipe right or use Next page to read on.';
  }

  @override
  String get quranMore => 'More';

  @override
  String get quranShowControls => 'Show reading controls';

  @override
  String get quranUpdate => 'Download update';

  @override
  String get quranUpdateBody =>
      'A newer copy of the Quran package is available. The one on this device stays readable until the new one is downloaded and checked.';

  @override
  String quranSurahPosition(String page, String position, String count) {
    return 'Page $page · $position of $count in this surah';
  }

  @override
  String quranSurahOnePage(String page) {
    return 'Page $page · the whole surah is on this page';
  }

  @override
  String get quranSurahStart => 'Beginning of the surah';

  @override
  String get quranGoToAyah => 'Go to ayah';

  @override
  String quranGoToAyahInvalid(String count) {
    return 'Type an ayah number from 1 to $count.';
  }

  @override
  String quranNextSurah(String surah) {
    return 'Continue to $surah';
  }

  @override
  String quranNextSurahSamePage(String surah) {
    return 'Continue to $surah, which begins on this page';
  }

  @override
  String quranPageFirstAyah(String aya) {
    return 'Ayah $aya';
  }

  @override
  String quranPageContinuedAyah(String aya) {
    return 'Ayah $aya continues';
  }

  @override
  String get quranBookmarked => 'Bookmarked';

  @override
  String get quranWithinSurah => 'WITHIN THIS SURAH';

  @override
  String get quranSurahWholePage => 'the whole surah is on this page';

  @override
  String quranSurahPageOf(String position, String count) {
    return '$position of $count pages';
  }

  @override
  String get quranAllPages => 'All pages';

  @override
  String get quranSurahActions => 'Beginning of the surah or an ayah';

  @override
  String quranAyahRange(String first, String last) {
    return 'Ayahs $first–$last';
  }

  @override
  String get quranPositionSaved => 'Reading position saved';

  @override
  String get quranEditionShort => 'Madinah Mushaf · Hafs';

  @override
  String get quranTajweed => 'Tajweed colours';

  @override
  String get quranReadingMode => 'Reading mode';

  @override
  String get quranCalmReading =>
      'Calm reading: the King Fahd Complex\'s own lettering, marks and verse markers in one ink, without the printed frame. No letter is coloured by a rule.';

  @override
  String get quranTajweedUnavailableShort =>
      'Off · not available for this Mushaf yet';

  @override
  String get quranTajweedUnavailable =>
      'Tajweed colours will only be offered from a permitted Tajweed source that matches these pages, with that source\'s own colour legend. None is available for this edition yet, and the app never colours letters or marks by itself.';

  @override
  String get quranNextShort => 'Next';

  @override
  String get quranPreviousShort => 'Previous';

  @override
  String get navRadio => 'Radio';

  @override
  String get radioOverline => 'LISTEN & REFLECT';

  @override
  String get radioTitle => 'Quran radio';

  @override
  String get radioTagline => 'A quieter moment, wherever you are.';

  @override
  String get radioSource => 'MP3Quran';

  @override
  String get radioStatusReady => 'Ready';

  @override
  String get radioStatusConnecting => 'Connecting…';

  @override
  String get radioStatusLive => 'Live';

  @override
  String get radioStatusPaused => 'Paused';

  @override
  String get radioStatusReconnecting => 'Reconnecting…';

  @override
  String get radioStatusStopped => 'Stopped';

  @override
  String get radioStatusUnavailable => 'Unavailable';

  @override
  String get radioUnavailableHint =>
      'This station can\'t be reached right now. Check your connection and try again.';

  @override
  String get radioPlay => 'Play';

  @override
  String get radioPause => 'Pause';

  @override
  String get radioStop => 'Stop';

  @override
  String get radioClose => 'Stop and close the player';

  @override
  String radioFavoriteAdd(String station) {
    return 'Add $station to favorites';
  }

  @override
  String radioFavoriteRemove(String station) {
    return 'Remove $station from favorites';
  }

  @override
  String get radioSleepTimer => 'Sleep timer';

  @override
  String get radioSleepOff => 'Off';

  @override
  String radioSleepLabel(String value) {
    return 'Sleep timer · $value';
  }

  @override
  String get radioSleepNeedsAudio => 'Start a station to set the sleep timer.';

  @override
  String get radioSleepSheetBody =>
      'The radio stops at the chosen time, even with the screen locked.';

  @override
  String get radioYourStations => 'Your stations';

  @override
  String get radioAll => 'All';

  @override
  String get radioFavorites => 'Favorites';

  @override
  String get radioSearchHint => 'Find a station';

  @override
  String get radioNowPlaying => 'Now playing';

  @override
  String get radioVariantPlain => 'Live station';

  @override
  String get radioVariantMujawwad => 'Mujawwad recitation';

  @override
  String get radioVariantWarsh => 'Warsh narration';

  @override
  String get radioAttribution => 'Audio by MP3Quran';

  @override
  String get radioNoFavorites =>
      'No favorites yet. Tap the heart next to a station to keep it here.';

  @override
  String radioNoMatches(String query) {
    return 'No station matches “$query”.';
  }

  @override
  String get radioLoading => 'Loading stations…';

  @override
  String get radioLoadFailed =>
      'The station list couldn\'t be loaded. Live radio needs an internet connection.';

  @override
  String get radioTryAgain => 'Try again';

  @override
  String get radioSavedList =>
      'Couldn\'t update the station list. Showing the saved one.';

  @override
  String get radioNowPlayingSubtitle => 'Live · MP3Quran';

  @override
  String radioOpenPlayer(String station) {
    return 'Open Quran radio: $station';
  }

  @override
  String get radioChooseStation => 'Choose a station below';

  @override
  String radioSleepMinutes(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes min',
      one: '1 min',
    );
    return '$_temp0';
  }

  @override
  String get quranPagesButton => 'Pages';

  @override
  String quranPlaceInSurah(String position, String count) {
    return '$position of $count in this Surah';
  }

  @override
  String get quranWholeSurahHere => 'The whole surah is on this page';

  @override
  String quranHizbStart(String hizb) {
    return 'Hizb $hizb';
  }

  @override
  String quranHizbQuarter(String hizb) {
    return 'Quarter of Hizb $hizb';
  }

  @override
  String quranHizbHalf(String hizb) {
    return 'Half of Hizb $hizb';
  }

  @override
  String quranHizbThreeQuarters(String hizb) {
    return 'Three quarters of Hizb $hizb';
  }

  @override
  String get quranHideControls => 'Hide reading controls';

  @override
  String get quranKeepControls => 'Keep controls visible';

  @override
  String quranFitSwitchTo(String mode) {
    return 'Switch to $mode';
  }

  @override
  String get quranControlsHint => 'Tap the page to show or hide the controls';

  @override
  String get welcomeHeader => 'Welcome';

  @override
  String get welcomeEyebrow => 'A moment of peace, every day';

  @override
  String get welcomeHeadline => 'Prayer times,\nwherever you are.';

  @override
  String get welcomeHeading => 'Let’s make it local.';

  @override
  String get welcomeBody =>
      'Set your location for prayer times\nand your Qibla direction.';

  @override
  String get welcomeUseLocation => 'Use my location';

  @override
  String get welcomeChooseCity => 'Choose a city instead';

  @override
  String get welcomePrivacy => 'Your location stays on this device.';

  @override
  String get welcomeFeatureOffline => 'Works offline';

  @override
  String get welcomeFeatureAlerts => 'Prayer alerts';

  @override
  String get welcomeFeatureQibla => 'Qibla direction';

  @override
  String get cityPickerTitle => 'Where do you pray?';

  @override
  String get cityPickerBody => 'Choose your city to get started.';

  @override
  String get cityPickerSearch => 'Search for a city';

  @override
  String get cityPickerConfirm => 'Use this city';

  @override
  String get cityPickerEmpty => 'No matching cities';

  @override
  String cityPickerSelected(String city) {
    return 'Selected: $city';
  }
}
