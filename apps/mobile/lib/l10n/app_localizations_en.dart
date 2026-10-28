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
  String get themeSky => 'Sky (follows the sun)';

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
  String get remediationChooseManualPlace =>
      'Choose your place from the list or enter its coordinates.';

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
  String get onboardingWelcomeTitle => 'Prayer times for where you are';

  @override
  String get onboardingWelcomeBody =>
      'Works offline, without an account. Your location stays on this phone.';

  @override
  String get onboardingStart => 'Get started';

  @override
  String get onboardingLocationTitle => 'Where are you?';

  @override
  String get onboardingLocationBody =>
      'Approximate location is enough for today\'s times. You can choose a place instead.';

  @override
  String get onboardingUseLocation => 'Use approximate location';

  @override
  String get onboardingChoosePlace => 'Choose a place';

  @override
  String get onboardingResolving => 'Finding your place…';

  @override
  String get onboardingFailedTitle => 'Location is not available';

  @override
  String get onboardingTryAgain => 'Try again';

  @override
  String get onboardingDoneTitle => 'Your times are ready';

  @override
  String onboardingDoneBody(String place) {
    return 'Prayer times for $place.';
  }

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
  String get placeEmpty =>
      'No place found. Try another spelling or enter coordinates.';

  @override
  String placeError(String code) {
    return 'The search did not work (code $code).';
  }

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
  String homeNextPrayer(String prayer) {
    return 'Next: $prayer';
  }

  @override
  String homeCountdown(String hours, String minutes) {
    return 'in $hours h $minutes min';
  }

  @override
  String get homeNoNextPrayer => 'No further prayer in the coming days';

  @override
  String get homeNeedsLocation => 'Choose where to show prayer times for.';

  @override
  String get homeNoProfile =>
      'There is no local authority profile here; the engine default is used.';

  @override
  String homeError(String code) {
    return 'Prayer times could not be worked out (code $code).';
  }

  @override
  String get homeHealthUnknown => 'Athan: not set up yet';

  @override
  String homeManualPlace(String label) {
    return 'Manual place · $label';
  }

  @override
  String get homeCurrentPlace => 'Approximate location';

  @override
  String homePinnedPlace(String label) {
    return 'Pinned place · $label';
  }

  @override
  String get homeChangePlace => 'Change place';

  @override
  String get timelineTitle => 'Next 7 days';

  @override
  String timelineError(String code) {
    return 'The days could not be worked out (code $code).';
  }

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
  String get qiblaNeedsPlace => 'Choose a place to see the Qibla.';

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
      'Open Daily Muslim to keep the Athan scheduled.';

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
      'Allow notifications for Daily Muslim';

  @override
  String get athanReasonNeedsExactAlarmPermission =>
      'Allow alarms and reminders';

  @override
  String get athanReasonNeedsAlarmKitAuthorization =>
      'Allow alarms for Daily Muslim';

  @override
  String get athanReasonMutedChannel =>
      'The Athan sound is muted in system settings';

  @override
  String get athanReasonBatteryRestricted =>
      'The phone restricts Daily Muslim in the background';

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
  String get athanReasonInexactFallback => 'Alarms may be a few minutes late';

  @override
  String get athanReasonUnverifiableDelivery =>
      'This phone cannot confirm the Athan played';

  @override
  String get athanReasonForceStoppedPreviously =>
      'The app was force-stopped before; alarms were lost then';

  @override
  String get athanTestTitle => 'Athan test';

  @override
  String get athanTestStart => 'Play a test Athan in 60 seconds';

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
  String get athanSound => 'Athan sound';

  @override
  String get athanNoSounds => 'No Athan sounds are installed yet';

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
  String get settingsDiagnostics => 'Diagnostics';

  @override
  String get diagnosticsTitle => 'Diagnostics';

  @override
  String get diagnosticsIntro =>
      'This is everything the diagnostic report contains. Your place is rounded to about 1 km and nothing identifies you or this device. Nothing is sent: copy it and paste it into a message to support only if you want to.';

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
  String homeCountdownMinutes(String minutes) {
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
  String get navHome => 'Today';

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
}
