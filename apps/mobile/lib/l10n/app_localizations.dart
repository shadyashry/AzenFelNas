import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// App name in the title bar and task switcher.
  ///
  /// In en, this message translates to:
  /// **'Daily Muslim'**
  String get appTitle;

  /// Home screen title.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get homeTitle;

  /// Settings screen title and button label.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// Settings row: app language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// Language choice; always written in Arabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get languageArabic;

  /// Language choice; always written in English.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// Language choice: follow the device.
  ///
  /// In en, this message translates to:
  /// **'Device language'**
  String get languageSystem;

  /// Settings row: digit style.
  ///
  /// In en, this message translates to:
  /// **'Digits'**
  String get settingsDigits;

  /// Digit choice: follow the language.
  ///
  /// In en, this message translates to:
  /// **'Same as language'**
  String get digitsLocale;

  /// Digit choice: western digits, shown as digits.
  ///
  /// In en, this message translates to:
  /// **'0123456789'**
  String get digitsWestern;

  /// Digit choice: Arabic-Indic digits, shown as digits.
  ///
  /// In en, this message translates to:
  /// **'٠١٢٣٤٥٦٧٨٩'**
  String get digitsArabicIndic;

  /// Settings row: theme mode.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsTheme;

  /// Theme choice: header colours follow the sun.
  ///
  /// In en, this message translates to:
  /// **'Sky (follows the sun)'**
  String get themeSky;

  /// Theme choice.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// Theme choice.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// Theme choice: follow the device.
  ///
  /// In en, this message translates to:
  /// **'Same as device'**
  String get themeSystem;

  /// Settings switch: turn off animations.
  ///
  /// In en, this message translates to:
  /// **'Reduce motion'**
  String get settingsReducedMotion;

  /// Settings row and screen title for attributions.
  ///
  /// In en, this message translates to:
  /// **'Data sources and licences'**
  String get settingsAttributions;

  /// Button: the licences of the software the app uses.
  ///
  /// In en, this message translates to:
  /// **'Open-source licences'**
  String get attributionsOpenSource;

  /// Athan Health screen title.
  ///
  /// In en, this message translates to:
  /// **'Athan Health'**
  String get healthTitle;

  /// Qibla screen title.
  ///
  /// In en, this message translates to:
  /// **'Qibla'**
  String get qiblaTitle;

  /// Accuracy Passport screen title.
  ///
  /// In en, this message translates to:
  /// **'Accuracy Passport'**
  String get passportTitle;

  /// Body of a screen that is not built yet.
  ///
  /// In en, this message translates to:
  /// **'This screen arrives in a later update.'**
  String get notYetAvailable;

  /// Title of a notice about something the user can fix.
  ///
  /// In en, this message translates to:
  /// **'Needs attention'**
  String get needsAttentionTitle;

  /// Technical code under a notice, for support.
  ///
  /// In en, this message translates to:
  /// **'Code {code}'**
  String needsAttentionCode(String code);

  /// Title shown when the databases could not be opened.
  ///
  /// In en, this message translates to:
  /// **'The app could not open its data'**
  String get startupFailedTitle;

  /// Remediation.
  ///
  /// In en, this message translates to:
  /// **'Allow location access, or choose a place yourself.'**
  String get remediationGrantLocationPermission;

  /// Remediation.
  ///
  /// In en, this message translates to:
  /// **'Turn on location in the device settings, or choose a place yourself.'**
  String get remediationTurnOnLocationServices;

  /// Remediation.
  ///
  /// In en, this message translates to:
  /// **'Choose your place from the list or enter its coordinates.'**
  String get remediationChooseManualPlace;

  /// Remediation.
  ///
  /// In en, this message translates to:
  /// **'Nothing to do now. A data update will fix this.'**
  String get remediationWaitForDataUpdate;

  /// Remediation.
  ///
  /// In en, this message translates to:
  /// **'Connect to the internet. The app will try again.'**
  String get remediationRetryWhenOnline;

  /// Remediation.
  ///
  /// In en, this message translates to:
  /// **'Free some storage on the device.'**
  String get remediationFreeUpStorage;

  /// Remediation.
  ///
  /// In en, this message translates to:
  /// **'Try again.'**
  String get remediationTryAgain;

  /// Remediation.
  ///
  /// In en, this message translates to:
  /// **'Install the latest version of the app.'**
  String get remediationUpdateApp;

  /// Remediation.
  ///
  /// In en, this message translates to:
  /// **'Allow alarms and notifications so the Athan can sound on time.'**
  String get remediationGrantAlarmPermission;

  /// Remediation.
  ///
  /// In en, this message translates to:
  /// **'Open Athan Health for the details.'**
  String get remediationOpenAthanHealth;

  /// Remediation.
  ///
  /// In en, this message translates to:
  /// **'Set the device\'s date and time to update automatically.'**
  String get remediationCheckDeviceClock;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
