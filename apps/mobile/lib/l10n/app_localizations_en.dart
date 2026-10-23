// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Daily Muslim';

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
  String get healthTitle => 'Athan Health';

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
}
