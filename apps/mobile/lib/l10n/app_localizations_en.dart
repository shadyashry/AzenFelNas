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
}
