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
  /// **'Azen Fel Nas'**
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
  /// **'Dynamic (changes with prayer times)'**
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
  /// **'Choose your city from the list.'**
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

  /// Needs attention button that opens the device's location settings (§15 D97).
  ///
  /// In en, this message translates to:
  /// **'Turn on location'**
  String get remediationActionTurnOnLocation;

  /// Needs attention button that opens the app's settings for a blocked permission (§15 D97).
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get remediationActionOpenSettings;

  /// Onboarding welcome step title.
  ///
  /// In en, this message translates to:
  /// **'Prayer times for where you are'**
  String get onboardingWelcomeTitle;

  /// Onboarding welcome step body.
  ///
  /// In en, this message translates to:
  /// **'Works offline, without an account. Your location stays on this phone.'**
  String get onboardingWelcomeBody;

  /// Button: ask for approximate location.
  ///
  /// In en, this message translates to:
  /// **'Use approximate location'**
  String get onboardingUseLocation;

  /// Button: open manual place search.
  ///
  /// In en, this message translates to:
  /// **'Choose a place'**
  String get onboardingChoosePlace;

  /// Shown while the location is resolved.
  ///
  /// In en, this message translates to:
  /// **'Finding your place…'**
  String get onboardingResolving;

  /// Onboarding: location failed.
  ///
  /// In en, this message translates to:
  /// **'Location is not available'**
  String get onboardingFailedTitle;

  /// Button: retry location.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get onboardingTryAgain;

  /// Onboarding done step title.
  ///
  /// In en, this message translates to:
  /// **'Your times are ready'**
  String get onboardingDoneTitle;

  /// Onboarding done step body.
  ///
  /// In en, this message translates to:
  /// **'Prayer times for {place}.'**
  String onboardingDoneBody(String place);

  /// Onboarding done step: why the notification and alarm prompts follow (REQ-ALM-026, §15 D96).
  ///
  /// In en, this message translates to:
  /// **'So the Athan sounds on time, the next screens ask to allow notifications and alarms.'**
  String get onboardingAthanPermissions;

  /// Onboarding done button.
  ///
  /// In en, this message translates to:
  /// **'Show today\'s times'**
  String get onboardingShowTimes;

  /// Manual place screen title.
  ///
  /// In en, this message translates to:
  /// **'Choose a place'**
  String get placeTitle;

  /// Manual place search field hint.
  ///
  /// In en, this message translates to:
  /// **'City name'**
  String get placeSearchHint;

  /// Manual place: before searching.
  ///
  /// In en, this message translates to:
  /// **'Search the offline list of cities.'**
  String get placeIdle;

  /// Manual place: search running.
  ///
  /// In en, this message translates to:
  /// **'Searching…'**
  String get placeSearching;

  /// Manual place: no results.
  ///
  /// In en, this message translates to:
  /// **'No place found. Try another spelling.'**
  String get placeEmpty;

  /// Button: switch to coordinate entry.
  ///
  /// In en, this message translates to:
  /// **'Enter coordinates'**
  String get placeEnterCoordinates;

  /// Coordinate entry field.
  ///
  /// In en, this message translates to:
  /// **'Latitude'**
  String get placeLatitude;

  /// Coordinate entry field.
  ///
  /// In en, this message translates to:
  /// **'Longitude'**
  String get placeLongitude;

  /// Coordinate entry: label field.
  ///
  /// In en, this message translates to:
  /// **'Place name'**
  String get placeName;

  /// Coordinate entry: invalid numbers.
  ///
  /// In en, this message translates to:
  /// **'Latitude from -90 to 90, longitude from -180 to 180.'**
  String get placeCoordinatesInvalid;

  /// Coordinate entry: save button.
  ///
  /// In en, this message translates to:
  /// **'Use this place'**
  String get placeUse;

  /// Home hero: small label above the next prayer's name.
  ///
  /// In en, this message translates to:
  /// **'Next prayer'**
  String get homeNextPrayerLabel;

  /// Home hero: the next prayer's Athan is switched on; opens the Athan tab.
  ///
  /// In en, this message translates to:
  /// **'Athan on'**
  String get homeAthanOn;

  /// Home hero: the next prayer's Athan is switched off; opens the Athan tab.
  ///
  /// In en, this message translates to:
  /// **'Athan off'**
  String get homeAthanOff;

  /// Home: next prayer line.
  ///
  /// In en, this message translates to:
  /// **'Next: {prayer}'**
  String homeNextPrayer(String prayer);

  /// Home: countdown to the next prayer.
  ///
  /// In en, this message translates to:
  /// **'in {hours} h {minutes} min'**
  String homeCountdown(String hours, String minutes);

  /// Home: no timed prayer left.
  ///
  /// In en, this message translates to:
  /// **'No further prayer in the coming days'**
  String get homeNoNextPrayer;

  /// Home: no usable place.
  ///
  /// In en, this message translates to:
  /// **'Choose where to show prayer times for.'**
  String get homeNeedsLocation;

  /// Home: engine default profile used (US-06).
  ///
  /// In en, this message translates to:
  /// **'No local timetable for this area yet; times use the standard method.'**
  String get homeNoProfile;

  /// Home: Athan readiness before Athan exists.
  ///
  /// In en, this message translates to:
  /// **'Athan: not set up yet'**
  String get homeHealthUnknown;

  /// Home: place chip for the device location.
  ///
  /// In en, this message translates to:
  /// **'Your location'**
  String get homeCurrentPlace;

  /// Day timeline title and Home button.
  ///
  /// In en, this message translates to:
  /// **'Next 7 days'**
  String get timelineTitle;

  /// Event name.
  ///
  /// In en, this message translates to:
  /// **'Imsak'**
  String get prayerImsak;

  /// Event name.
  ///
  /// In en, this message translates to:
  /// **'Fajr'**
  String get prayerFajr;

  /// Event name.
  ///
  /// In en, this message translates to:
  /// **'Sunrise'**
  String get prayerSunrise;

  /// Event name.
  ///
  /// In en, this message translates to:
  /// **'Dhuhr'**
  String get prayerDhuhr;

  /// Event name.
  ///
  /// In en, this message translates to:
  /// **'Asr'**
  String get prayerAsr;

  /// Event name.
  ///
  /// In en, this message translates to:
  /// **'Maghrib'**
  String get prayerMaghrib;

  /// Event name.
  ///
  /// In en, this message translates to:
  /// **'Isha'**
  String get prayerIsha;

  /// Time cell when an event has no time.
  ///
  /// In en, this message translates to:
  /// **'—'**
  String get noTimeText;

  /// Unknown reason when an event has no time.
  ///
  /// In en, this message translates to:
  /// **'no time on this day'**
  String get noTimeReason;

  /// Passport: Calculation ID not found.
  ///
  /// In en, this message translates to:
  /// **'This calculation is not on this device'**
  String get passportNotFoundTitle;

  /// Passport: not found explanation.
  ///
  /// In en, this message translates to:
  /// **'The link\'s Calculation ID is not in this week\'s times and the link carries no inputs to recompute it.'**
  String get passportNotFoundBody;

  /// Passport import mismatch title.
  ///
  /// In en, this message translates to:
  /// **'Computed differently on this device'**
  String get passportMismatchTitle;

  /// Import mismatch: IDs differ (§6.4 ¶11).
  ///
  /// In en, this message translates to:
  /// **'This time was computed with a different engine, profile or time-zone data version.'**
  String get passportMismatchVersions;

  /// Import mismatch: profile version missing.
  ///
  /// In en, this message translates to:
  /// **'This device does not have profile {profile} version {version}.'**
  String passportMismatchProfile(String profile, String version);

  /// Import mismatch: zone missing.
  ///
  /// In en, this message translates to:
  /// **'This device\'s time-zone data does not include the shared place\'s zone.'**
  String get passportMismatchZone;

  /// Calculation ID carried by the link.
  ///
  /// In en, this message translates to:
  /// **'In the link: {id}'**
  String passportLinkId(String id);

  /// Calculation ID this device computed.
  ///
  /// In en, this message translates to:
  /// **'On this device: {id}'**
  String passportLocalId(String id);

  /// This device's versions on a mismatch.
  ///
  /// In en, this message translates to:
  /// **'This device: engine {engine}, time-zone data {tzdb}'**
  String passportThisDevice(String engine, String tzdb);

  /// Import matched banner.
  ///
  /// In en, this message translates to:
  /// **'Recomputed on this device: the result matches the link.'**
  String get passportImportMatch;

  /// Copy the share link.
  ///
  /// In en, this message translates to:
  /// **'Copy link'**
  String get passportCopyLink;

  /// Snackbar after copying.
  ///
  /// In en, this message translates to:
  /// **'Link copied'**
  String get passportLinkCopied;

  /// Passport inputs section.
  ///
  /// In en, this message translates to:
  /// **'Inputs'**
  String get passportInputsTitle;

  /// Passport versions section.
  ///
  /// In en, this message translates to:
  /// **'Versions'**
  String get passportVersionsTitle;

  /// Inputs: coordinates.
  ///
  /// In en, this message translates to:
  /// **'Coordinates'**
  String get passportCoordinates;

  /// Inputs: zone.
  ///
  /// In en, this message translates to:
  /// **'Time zone'**
  String get passportZone;

  /// Inputs: day.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get passportDay;

  /// Inputs: profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get passportProfile;

  /// Inputs: Hijri dates.
  ///
  /// In en, this message translates to:
  /// **'Hijri date (dawn / night)'**
  String get passportHijri;

  /// Versions: engine.
  ///
  /// In en, this message translates to:
  /// **'Engine'**
  String get passportEngine;

  /// Versions: ΔT model.
  ///
  /// In en, this message translates to:
  /// **'ΔT model'**
  String get passportDeltaT;

  /// Versions: TZDB.
  ///
  /// In en, this message translates to:
  /// **'Time-zone data'**
  String get passportTzdb;

  /// Versions: inputs hash.
  ///
  /// In en, this message translates to:
  /// **'Inputs hash'**
  String get passportInputsHash;

  /// Raw instant, local, with seconds.
  ///
  /// In en, this message translates to:
  /// **'Calculated instant {time}'**
  String passportRaw(String time);

  /// Displayed time.
  ///
  /// In en, this message translates to:
  /// **'Shown as {time}'**
  String passportShown(String time);

  /// Rounding ceil.
  ///
  /// In en, this message translates to:
  /// **'Rounded up to the next minute'**
  String get passportRoundingCeil;

  /// Rounding floor.
  ///
  /// In en, this message translates to:
  /// **'Rounded down to the minute'**
  String get passportRoundingFloor;

  /// Rounding nearest.
  ///
  /// In en, this message translates to:
  /// **'Rounded to the nearest minute'**
  String get passportRoundingNearest;

  /// Origin primary.
  ///
  /// In en, this message translates to:
  /// **'From the astronomical rule'**
  String get passportOriginPrimary;

  /// Origin fallback.
  ///
  /// In en, this message translates to:
  /// **'From the high-latitude method {method}'**
  String passportOriginFallback(String method);

  /// Origin no event.
  ///
  /// In en, this message translates to:
  /// **'No time on this day ({reason})'**
  String passportOriginNoEvent(String reason);

  /// Sensitivity line (§6.7).
  ///
  /// In en, this message translates to:
  /// **'±1 km changes this by ≤ {seconds} s'**
  String passportSensitivity(int seconds);

  /// One adjustment trace step.
  ///
  /// In en, this message translates to:
  /// **'{kind}: {seconds} s'**
  String passportAdjustment(String kind, String seconds);

  /// Adjustment kind perEventOffset.
  ///
  /// In en, this message translates to:
  /// **'Offset'**
  String get passportAdjustOffset;

  /// Adjustment kind ramadanRuleReplacement.
  ///
  /// In en, this message translates to:
  /// **'Ramadan rule'**
  String get passportAdjustRamadan;

  /// Adjustment kind highLatitudeFallback.
  ///
  /// In en, this message translates to:
  /// **'High-latitude method'**
  String get passportAdjustHighLatitude;

  /// Adjustment kind rounding.
  ///
  /// In en, this message translates to:
  /// **'Rounding'**
  String get passportAdjustRounding;

  /// Flag nearRoundingBoundary.
  ///
  /// In en, this message translates to:
  /// **'The calculated instant is within half a second of a minute boundary.'**
  String get flagNearRoundingBoundary;

  /// Flag highLatitudeFallback.
  ///
  /// In en, this message translates to:
  /// **'A high-latitude method gave this time.'**
  String get flagHighLatitudeFallback;

  /// Flag lowLocationAccuracy.
  ///
  /// In en, this message translates to:
  /// **'Your location is approximate.'**
  String get flagLowLocationAccuracy;

  /// Flag dstTransitionDay.
  ///
  /// In en, this message translates to:
  /// **'The clocks change on this day.'**
  String get flagDstTransitionDay;

  /// Flag staleTzdb.
  ///
  /// In en, this message translates to:
  /// **'The time-zone data on this device is old.'**
  String get flagStaleTzdb;

  /// Flag hijriExpected.
  ///
  /// In en, this message translates to:
  /// **'The Hijri date is expected, not yet announced.'**
  String get flagHijriExpected;

  /// Flag referenceModeAuthorityPoint.
  ///
  /// In en, this message translates to:
  /// **'Calculated at the authority\'s reference point for your area.'**
  String get flagReferenceModeAuthorityPoint;

  /// Flag manualCoordinateResolution.
  ///
  /// In en, this message translates to:
  /// **'The place was chosen by hand.'**
  String get flagManualCoordinateResolution;

  /// Flag zoneBoundaryProximity.
  ///
  /// In en, this message translates to:
  /// **'You are near a time-zone border.'**
  String get flagZoneBoundaryProximity;

  /// Flag noLocalProfile.
  ///
  /// In en, this message translates to:
  /// **'No local profile covers this place; the engine default is used.'**
  String get flagNoLocalProfile;

  /// No flags.
  ///
  /// In en, this message translates to:
  /// **'No flags for this time.'**
  String get passportNoFlags;

  /// Qibla: no heading yet.
  ///
  /// In en, this message translates to:
  /// **'Waiting for the compass…'**
  String get qiblaNoHeading;

  /// Qibla: numeric only.
  ///
  /// In en, this message translates to:
  /// **'This device has no usable compass. Face the bearing below using a map or a physical compass.'**
  String get qiblaNumericOnly;

  /// Qibla: calibration guidance.
  ///
  /// In en, this message translates to:
  /// **'Compass accuracy is low. Move the phone in a figure-eight away from metal.'**
  String get qiblaCalibrating;

  /// Qibla bearing line.
  ///
  /// In en, this message translates to:
  /// **'Qibla: {degrees}° from true north'**
  String qiblaBearing(String degrees);

  /// Distance to the Kaaba.
  ///
  /// In en, this message translates to:
  /// **'{km} km to the Kaaba'**
  String qiblaDistance(String km);

  /// Heading accuracy.
  ///
  /// In en, this message translates to:
  /// **'Compass accuracy ±{degrees}°'**
  String qiblaAccuracy(String degrees);

  /// Turn instruction.
  ///
  /// In en, this message translates to:
  /// **'Turn {degrees}° {direction}'**
  String qiblaTurn(String degrees, String direction);

  /// Turn right.
  ///
  /// In en, this message translates to:
  /// **'right'**
  String get qiblaRight;

  /// Turn left.
  ///
  /// In en, this message translates to:
  /// **'left'**
  String get qiblaLeft;

  /// Facing within tolerance.
  ///
  /// In en, this message translates to:
  /// **'You are facing the Qibla.'**
  String get qiblaFacing;

  /// Qibla hint under the compass (§15 D98).
  ///
  /// In en, this message translates to:
  /// **'Hold the phone flat, away from metal and magnets.'**
  String get qiblaHoldFlat;

  /// Qibla without a place.
  ///
  /// In en, this message translates to:
  /// **'Choose a place to see the Qibla.'**
  String get qiblaNeedsPlace;

  /// Heading of the sensor-free Qibla section (D91).
  ///
  /// In en, this message translates to:
  /// **'Qibla by the Sun\'s shadow'**
  String get qiblaShadowTitle;

  /// How to use the shadow times.
  ///
  /// In en, this message translates to:
  /// **'No compass needed: stand a stick, pole or plumb line upright. At these times its shadow lies on the Qibla line.'**
  String get qiblaShadowFootnote;

  /// Sun at the Qibla bearing.
  ///
  /// In en, this message translates to:
  /// **'Face the Sun. The Qibla runs from the tip of the shadow to the base of the stick.'**
  String get qiblaShadowToward;

  /// Sun opposite the Qibla bearing.
  ///
  /// In en, this message translates to:
  /// **'The Sun is behind you. The Qibla runs from the base of the stick along the shadow to its tip.'**
  String get qiblaShadowAway;

  /// Window of one alignment, local times.
  ///
  /// In en, this message translates to:
  /// **'Within 1° from {start} to {end}'**
  String qiblaShadowWindow(String start, String end);

  /// The alignment's window has closed.
  ///
  /// In en, this message translates to:
  /// **'Passed'**
  String get qiblaShadowPassed;

  /// Sun altitude 75° or more.
  ///
  /// In en, this message translates to:
  /// **'Hard to use: the Sun is high, so the shadow is short.'**
  String get qiblaShadowHighSun;

  /// Window shorter than 2 min.
  ///
  /// In en, this message translates to:
  /// **'Hard to use: the window is under two minutes.'**
  String get qiblaShadowBriefWindow;

  /// No alignment today; the first day that has one.
  ///
  /// In en, this message translates to:
  /// **'None today. Next: {date}'**
  String qiblaShadowNextDay(String date);

  /// No alignment in the searched days.
  ///
  /// In en, this message translates to:
  /// **'The Sun does not line up with the Qibla here in the next 8 days.'**
  String get qiblaShadowNone;

  /// Plan notification title of an Athan (§7.7).
  ///
  /// In en, this message translates to:
  /// **'{prayer} Athan'**
  String planAthanTitle(String prayer);

  /// Plan notification body of an Athan.
  ///
  /// In en, this message translates to:
  /// **'It is time for {prayer}.'**
  String planAthanBody(String prayer);

  /// Plan notification title of the Imsak alert.
  ///
  /// In en, this message translates to:
  /// **'Imsak'**
  String get planImsakTitle;

  /// Plan notification body of the Imsak alert.
  ///
  /// In en, this message translates to:
  /// **'It is Imsak time.'**
  String get planImsakBody;

  /// Plan pre-reminder title (REQ-ALM-042).
  ///
  /// In en, this message translates to:
  /// **'{prayer} in {minutes} min'**
  String planPreReminderTitle(String prayer, int minutes);

  /// Plan pre-reminder body.
  ///
  /// In en, this message translates to:
  /// **'The {prayer} Athan is in {minutes} minutes.'**
  String planPreReminderBody(String prayer, int minutes);

  /// Horizon warning title (REQ-ALM-010).
  ///
  /// In en, this message translates to:
  /// **'Athan schedule ends soon'**
  String get planHorizonTitle;

  /// Horizon warning body.
  ///
  /// In en, this message translates to:
  /// **'Open Azen Fel Nas to keep the Athan scheduled.'**
  String get planHorizonBody;

  /// Athan settings page title.
  ///
  /// In en, this message translates to:
  /// **'Athan'**
  String get athanTitle;

  /// Settings entry to the Athan page.
  ///
  /// In en, this message translates to:
  /// **'Athan'**
  String get settingsAthan;

  /// Athan Health section title.
  ///
  /// In en, this message translates to:
  /// **'Athan readiness'**
  String get athanHealthTitle;

  /// Athan Health while probes run.
  ///
  /// In en, this message translates to:
  /// **'Checking…'**
  String get athanHealthEvaluating;

  /// Athan Health ready state.
  ///
  /// In en, this message translates to:
  /// **'Ready: the Athan will sound'**
  String get athanHealthReady;

  /// Athan Health limited state.
  ///
  /// In en, this message translates to:
  /// **'Limited: the Athan may be late or quiet'**
  String get athanHealthLimited;

  /// Athan Health not-ready state.
  ///
  /// In en, this message translates to:
  /// **'Not ready: the Athan will not sound'**
  String get athanHealthNotReady;

  /// Athan Health unknown state (§18.5 Unknown).
  ///
  /// In en, this message translates to:
  /// **'Not available · the phone cannot tell'**
  String get athanHealthUnknown;

  /// Health reason.
  ///
  /// In en, this message translates to:
  /// **'Allow notifications for Azen Fel Nas'**
  String get athanReasonNeedsNotificationPermission;

  /// Health reason.
  ///
  /// In en, this message translates to:
  /// **'Allow alarms and reminders'**
  String get athanReasonNeedsExactAlarmPermission;

  /// Health reason.
  ///
  /// In en, this message translates to:
  /// **'Allow alarms for Azen Fel Nas'**
  String get athanReasonNeedsAlarmKitAuthorization;

  /// Health reason.
  ///
  /// In en, this message translates to:
  /// **'The Athan sound is muted in system settings'**
  String get athanReasonMutedChannel;

  /// Health reason.
  ///
  /// In en, this message translates to:
  /// **'The phone restricts Azen Fel Nas in the background'**
  String get athanReasonBatteryRestricted;

  /// Health reason.
  ///
  /// In en, this message translates to:
  /// **'Open the app to schedule the Athan'**
  String get athanReasonStalePlan;

  /// Health reason.
  ///
  /// In en, this message translates to:
  /// **'The Athan schedule ends soon; open the app'**
  String get athanReasonHorizonEnding;

  /// Health reason.
  ///
  /// In en, this message translates to:
  /// **'You did not hear the last test'**
  String get athanReasonFailedTest;

  /// Health reason.
  ///
  /// In en, this message translates to:
  /// **'The phone clock looks wrong'**
  String get athanReasonClockSkew;

  /// Health reason.
  ///
  /// In en, this message translates to:
  /// **'No Athan sound is installed'**
  String get athanReasonNoSoundAsset;

  /// Health reason: Android's inexact fallback may deliver up to an hour late (§15 D95).
  ///
  /// In en, this message translates to:
  /// **'Without “Alarms & reminders” the Athan may be up to an hour late'**
  String get athanReasonInexactFallback;

  /// Health reason.
  ///
  /// In en, this message translates to:
  /// **'This phone cannot confirm the Athan played'**
  String get athanReasonUnverifiableDelivery;

  /// Health reason (advisory).
  ///
  /// In en, this message translates to:
  /// **'The app was force-stopped before; alarms were lost then'**
  String get athanReasonForceStoppedPreviously;

  /// Athan Health button that shows the system permission prompt (§15 D95).
  ///
  /// In en, this message translates to:
  /// **'Allow'**
  String get athanGrantAllow;

  /// Athan Health button that opens the app's system settings (§15 D95).
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get athanGrantOpenSettings;

  /// Athan Test section title.
  ///
  /// In en, this message translates to:
  /// **'Athan test'**
  String get athanTestTitle;

  /// Athan Test start button.
  ///
  /// In en, this message translates to:
  /// **'Play a test Athan in 60 seconds'**
  String get athanTestStart;

  /// Athan Test disabled hint.
  ///
  /// In en, this message translates to:
  /// **'Choose an Athan sound first'**
  String get athanTestNeedsSound;

  /// Athan Test fired state.
  ///
  /// In en, this message translates to:
  /// **'The test Athan should be playing now'**
  String get athanTestFired;

  /// Athan Test question.
  ///
  /// In en, this message translates to:
  /// **'Did you hear it?'**
  String get athanTestAsk;

  /// Athan Test answer.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get athanTestYes;

  /// Athan Test answer.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get athanTestNo;

  /// Athan Test recorded, heard.
  ///
  /// In en, this message translates to:
  /// **'Recorded: you heard the test'**
  String get athanTestHeard;

  /// Athan Test recorded, not heard.
  ///
  /// In en, this message translates to:
  /// **'Recorded: you did not hear the test'**
  String get athanTestNotHeard;

  /// Athan Test refused by the platform.
  ///
  /// In en, this message translates to:
  /// **'The phone did not schedule the test'**
  String get athanTestNotArmed;

  /// Athan Test reset button.
  ///
  /// In en, this message translates to:
  /// **'Test again'**
  String get athanTestAgain;

  /// Sound choice title.
  ///
  /// In en, this message translates to:
  /// **'Athan sound'**
  String get athanSound;

  /// Sound choice when the manifest is empty.
  ///
  /// In en, this message translates to:
  /// **'No Athan sounds are installed yet'**
  String get athanNoSounds;

  /// Name of a bundled test Athan sound on dev and lab builds (§15 D94, D95).
  ///
  /// In en, this message translates to:
  /// **'Test Athan (not for release)'**
  String get athanSoundTest;

  /// Title of the per-prayer Athan switches (§15 D95).
  ///
  /// In en, this message translates to:
  /// **'Athan for'**
  String get athanPrayersTitle;

  /// Pre-reminder choice title (REQ-ALM-042).
  ///
  /// In en, this message translates to:
  /// **'Reminder before the Athan'**
  String get athanPreReminder;

  /// Pre-reminder off.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get athanPreReminderOff;

  /// Athan Test countdown.
  ///
  /// In en, this message translates to:
  /// **'Test Athan in {seconds} s'**
  String athanTestScheduled(int seconds);

  /// Pre-reminder option.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min before'**
  String athanPreReminderMinutes(int minutes);

  /// Settings row and screen title for the diagnostic export.
  ///
  /// In en, this message translates to:
  /// **'Report a problem'**
  String get settingsDiagnostics;

  /// Diagnostics screen title.
  ///
  /// In en, this message translates to:
  /// **'Report a problem'**
  String get diagnosticsTitle;

  /// Explains the bundle before the user copies it (REQ-PRIV-005).
  ///
  /// In en, this message translates to:
  /// **'If something goes wrong, copy this report and send it to support. This is everything it contains: your place is rounded to about 1 km and nothing identifies you or this device. Nothing is sent by the app itself.'**
  String get diagnosticsIntro;

  /// Button that copies the shown diagnostic report to the clipboard.
  ///
  /// In en, this message translates to:
  /// **'Copy report'**
  String get diagnosticsCopy;

  /// Shown after the report was copied.
  ///
  /// In en, this message translates to:
  /// **'Report copied'**
  String get diagnosticsCopied;

  /// Shown when assembling the report failed.
  ///
  /// In en, this message translates to:
  /// **'The report could not be prepared.'**
  String get diagnosticsUnavailable;

  /// Home Ramadan card title (US-23).
  ///
  /// In en, this message translates to:
  /// **'Ramadan {day}'**
  String homeFastingTitle(int day);

  /// Home Ramadan card: Fajr to Maghrib, the profile's own times.
  ///
  /// In en, this message translates to:
  /// **'Fast from {begins} to {ends}'**
  String homeFastingWindow(String begins, String ends);

  /// Home Ramadan card: Imsak when the profile has it.
  ///
  /// In en, this message translates to:
  /// **'Imsak {time}'**
  String homeFastingImsak(String time);

  /// Home Ramadan card: polar day or night, no window is invented.
  ///
  /// In en, this message translates to:
  /// **'Fajr or Maghrib has no time here today; follow your local authority.'**
  String get homeFastingUnknown;

  /// Home Ramadan card: the ±1 day override control (ADR-016).
  ///
  /// In en, this message translates to:
  /// **'Hijri day'**
  String get homeHijriOverride;

  /// Home Ramadan card: the Hijri date includes the user's ±1 day override.
  ///
  /// In en, this message translates to:
  /// **'Adjusted by you'**
  String get homeHijriOverrideApplied;

  /// Travel Mode prompt (US-22).
  ///
  /// In en, this message translates to:
  /// **'You seem to be in {city}. Switch schedule?'**
  String travelPrompt(String city);

  /// Travel Mode: follow the device location.
  ///
  /// In en, this message translates to:
  /// **'Switch'**
  String get travelSwitch;

  /// Travel Mode: keep the chosen place.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get travelNotNow;

  /// Home: time left to the next prayer, under an hour.
  ///
  /// In en, this message translates to:
  /// **'in {minutes} min'**
  String homeCountdownMinutes(String minutes);

  /// Home: the next prayer, in the cartouche inside the arch.
  ///
  /// In en, this message translates to:
  /// **'{prayer}'**
  String homeCartouche(String prayer);

  /// Home: the Hijri date in the header.
  ///
  /// In en, this message translates to:
  /// **'{day} {monthName} {year} AH'**
  String homeHijriDate(String day, String monthName, String year);

  /// Name of Hijri month 1-12.
  ///
  /// In en, this message translates to:
  /// **'{month, select, 1{Muharram} 2{Safar} 3{Rabi al-Awwal} 4{Rabi al-Thani} 5{Jumada al-Ula} 6{Jumada al-Akhirah} 7{Rajab} 8{Shaban} 9{Ramadan} 10{Shawwal} 11{Dhu al-Qadah} 12{Dhu al-Hijjah} other{}}'**
  String hijriMonthName(String month);

  /// Navigation bar: Home.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get navHome;

  /// Navigation bar: Qibla.
  ///
  /// In en, this message translates to:
  /// **'Qibla'**
  String get navQibla;

  /// Navigation bar: Athan.
  ///
  /// In en, this message translates to:
  /// **'Athan'**
  String get navAthan;

  /// Navigation bar: Settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// Qibla dial: north.
  ///
  /// In en, this message translates to:
  /// **'N'**
  String get compassNorth;

  /// Qibla dial: east.
  ///
  /// In en, this message translates to:
  /// **'E'**
  String get compassEast;

  /// Qibla dial: south.
  ///
  /// In en, this message translates to:
  /// **'S'**
  String get compassSouth;

  /// Qibla dial: west.
  ///
  /// In en, this message translates to:
  /// **'W'**
  String get compassWest;

  /// Qibla: the bearing in large numerals.
  ///
  /// In en, this message translates to:
  /// **'{degrees}°'**
  String qiblaDegrees(String degrees);

  /// Settings: heading of language, digits, theme and motion.
  ///
  /// In en, this message translates to:
  /// **'Display'**
  String get settingsDisplaySection;

  /// Settings: heading of Athan, diagnostics and data sources.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get settingsMoreSection;

  /// Onboarding: title of the place step.
  ///
  /// In en, this message translates to:
  /// **'Choose your city'**
  String get onboardingChooseCity;

  /// Onboarding welcome: main button; detects the place from the device location.
  ///
  /// In en, this message translates to:
  /// **'Find my location'**
  String get onboardingDetect;

  /// Onboarding welcome: secondary link to the city list.
  ///
  /// In en, this message translates to:
  /// **'I\'ll choose my city'**
  String get onboardingChooseCityMyself;

  /// Onboarding: under 'Finding your place'.
  ///
  /// In en, this message translates to:
  /// **'This takes a few seconds.'**
  String get onboardingResolvingBody;

  /// Onboarding failure: the city suggested by the device time zone.
  ///
  /// In en, this message translates to:
  /// **'Your phone\'s time zone suggests {place}.'**
  String onboardingSuggestion(String place);

  /// Onboarding failure: button pinning the suggested city.
  ///
  /// In en, this message translates to:
  /// **'Use {place}'**
  String onboardingUseSuggestion(String place);

  /// Onboarding failure: link to the city list.
  ///
  /// In en, this message translates to:
  /// **'Choose another city'**
  String get onboardingOtherCity;

  /// Onboarding welcome feature.
  ///
  /// In en, this message translates to:
  /// **'Works offline'**
  String get onboardingFeatureOffline;

  /// Onboarding welcome feature.
  ///
  /// In en, this message translates to:
  /// **'Athan on time'**
  String get onboardingFeatureAthan;

  /// Onboarding welcome feature.
  ///
  /// In en, this message translates to:
  /// **'Qibla compass'**
  String get onboardingFeatureQibla;

  /// Place search: heading of the cities suggested before typing.
  ///
  /// In en, this message translates to:
  /// **'Cities in your time zone'**
  String get placeSuggestions;

  /// Home header: screen-reader label of the place chip.
  ///
  /// In en, this message translates to:
  /// **'{place}, change place'**
  String homePlaceChip(String place);

  /// Settings: line under 'Report a problem'.
  ///
  /// In en, this message translates to:
  /// **'Copy a report for support if something goes wrong'**
  String get settingsDiagnosticsHint;

  /// Tab label: the Quran reader.
  ///
  /// In en, this message translates to:
  /// **'Quran'**
  String get navQuran;

  /// Quran tab title.
  ///
  /// In en, this message translates to:
  /// **'The Holy Quran'**
  String get quranTitle;

  /// Button: start the Quran download.
  ///
  /// In en, this message translates to:
  /// **'Download Quran for offline use'**
  String get quranDownloadAction;

  /// Quran download screen: what the download is.
  ///
  /// In en, this message translates to:
  /// **'The Madinah Mushaf (Hafs ʿan ʿĀṣim), as published by the King Fahd Glorious Quran Printing Complex. After one download every page, the surah and juz index, search, bookmarks and highlights work with no internet.'**
  String get quranDownloadBody;

  /// Measured size of the Quran download.
  ///
  /// In en, this message translates to:
  /// **'Download size: {size}'**
  String quranDownloadSize(String size);

  /// Measured size on the device after install.
  ///
  /// In en, this message translates to:
  /// **'Space after installing: {size}'**
  String quranInstalledSize(String size);

  /// Free space needed, including the search index.
  ///
  /// In en, this message translates to:
  /// **'Free space needed to install: {size}'**
  String quranRequiredSpace(String size);

  /// Button: resume a paused Quran download.
  ///
  /// In en, this message translates to:
  /// **'Resume download'**
  String get quranResume;

  /// Button: stop the Quran download.
  ///
  /// In en, this message translates to:
  /// **'Stop download'**
  String get quranCancel;

  /// Download progress in sizes.
  ///
  /// In en, this message translates to:
  /// **'Downloading {done} of {total}'**
  String quranDownloading(String done, String total);

  /// Quran install step.
  ///
  /// In en, this message translates to:
  /// **'Checking every file and preparing search…'**
  String get quranInstalling;

  /// Quran tab while checking files at start.
  ///
  /// In en, this message translates to:
  /// **'Checking the downloaded Quran…'**
  String get quranChecking;

  /// Quran download paused.
  ///
  /// In en, this message translates to:
  /// **'Download paused. What was downloaded is kept.'**
  String get quranPaused;

  /// Quran download failure: offline.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Connect and try again.'**
  String get quranFailOffline;

  /// Quran download failure: HTTP error.
  ///
  /// In en, this message translates to:
  /// **'The download server did not answer (HTTP {code}). Try again later.'**
  String quranFailServer(String code);

  /// Quran download failure: not enough space.
  ///
  /// In en, this message translates to:
  /// **'Not enough space: {needed} needed, {available} free.'**
  String quranFailSpace(String needed, String available);

  /// Quran download failure: disk full while writing.
  ///
  /// In en, this message translates to:
  /// **'The device ran out of space. Free up space and try again.'**
  String get quranFailSpaceFull;

  /// Quran download failure: hash mismatch.
  ///
  /// In en, this message translates to:
  /// **'A file did not match the official copy and was discarded. Try again.'**
  String get quranFailIntegrity;

  /// Quran download failure: storage error.
  ///
  /// In en, this message translates to:
  /// **'The app could not write to its storage. Try again.'**
  String get quranFailStorage;

  /// Quran install failure: search index.
  ///
  /// In en, this message translates to:
  /// **'The offline search could not be prepared. Try again.'**
  String get quranFailSearch;

  /// Quran download stopped by the user.
  ///
  /// In en, this message translates to:
  /// **'Download stopped. What was downloaded is kept.'**
  String get quranFailCancelled;

  /// Quran package damaged: title.
  ///
  /// In en, this message translates to:
  /// **'Some Quran files are missing or damaged'**
  String get quranDamagedTitle;

  /// Quran package damaged: body.
  ///
  /// In en, this message translates to:
  /// **'{count} files need to be downloaded again. Reading is paused until they are repaired.'**
  String quranDamagedBody(String count);

  /// Button: download damaged Quran files again.
  ///
  /// In en, this message translates to:
  /// **'Repair'**
  String get quranRepair;

  /// Status: the Quran package is verified and usable offline.
  ///
  /// In en, this message translates to:
  /// **'Ready offline'**
  String get quranReadyOffline;

  /// What removes the offline Quran.
  ///
  /// In en, this message translates to:
  /// **'Uninstalling the app, clearing its data or removing the download deletes the downloaded Quran; you would need to download it again.'**
  String get quranUninstallNote;

  /// Quran source attribution; no endorsement claim.
  ///
  /// In en, this message translates to:
  /// **'Mushaf pages and text: King Fahd Glorious Quran Printing Complex, Madinah Mushaf (Hafs), digital edition 1441, used under the Complex\'s published usage terms. The app is not endorsed or certified by the Complex.'**
  String get quranAttribution;

  /// Juz metadata attribution.
  ///
  /// In en, this message translates to:
  /// **'Juz boundaries: Tanzil.net Quran metadata (CC BY 3.0), checked against the Complex\'s text.'**
  String get quranJuzAttribution;

  /// Current Mushaf page.
  ///
  /// In en, this message translates to:
  /// **'Page {page}'**
  String quranPage(String page);

  /// Current juz.
  ///
  /// In en, this message translates to:
  /// **'Juz {juz}'**
  String quranJuz(String juz);

  /// Button: next Mushaf page (always on the left).
  ///
  /// In en, this message translates to:
  /// **'Next page'**
  String get quranNextPage;

  /// Button: previous Mushaf page (always on the right).
  ///
  /// In en, this message translates to:
  /// **'Previous page'**
  String get quranPreviousPage;

  /// Button: zoom in.
  ///
  /// In en, this message translates to:
  /// **'Zoom in'**
  String get quranZoomIn;

  /// Button: zoom out.
  ///
  /// In en, this message translates to:
  /// **'Zoom out'**
  String get quranZoomOut;

  /// Button: reset the zoom to fit.
  ///
  /// In en, this message translates to:
  /// **'Fit to screen'**
  String get quranResetZoom;

  /// Fit mode: whole page visible.
  ///
  /// In en, this message translates to:
  /// **'Whole page'**
  String get quranFitPage;

  /// Fit mode: page fills the width and scrolls.
  ///
  /// In en, this message translates to:
  /// **'Fit width'**
  String get quranFitWidth;

  /// Setting: show spreads on wide screens.
  ///
  /// In en, this message translates to:
  /// **'Two facing pages on wide screens'**
  String get quranFacingPages;

  /// Toggle: draw saved highlights.
  ///
  /// In en, this message translates to:
  /// **'Show highlights'**
  String get quranShowHighlights;

  /// Action and dialog title: jump to a page.
  ///
  /// In en, this message translates to:
  /// **'Go to page'**
  String get quranGoToPage;

  /// Page number field hint.
  ///
  /// In en, this message translates to:
  /// **'1 to {count}'**
  String quranGoToPageHint(String count);

  /// Invalid page number.
  ///
  /// In en, this message translates to:
  /// **'Enter a page from 1 to {count}.'**
  String quranGoToPageInvalid(String count);

  /// Button: go to the typed page.
  ///
  /// In en, this message translates to:
  /// **'Go'**
  String get quranGo;

  /// Action and title: the index.
  ///
  /// In en, this message translates to:
  /// **'Surahs and juz'**
  String get quranIndex;

  /// Index tab: surahs.
  ///
  /// In en, this message translates to:
  /// **'Surahs'**
  String get quranSurahsTab;

  /// Index tab: juz.
  ///
  /// In en, this message translates to:
  /// **'Juz'**
  String get quranJuzTab;

  /// Index filter hint.
  ///
  /// In en, this message translates to:
  /// **'Find a surah by name or number'**
  String get quranFilterSurahs;

  /// Index line under a surah name.
  ///
  /// In en, this message translates to:
  /// **'Surah {number} · {verses} verses · page {page}'**
  String quranSurahLine(String number, String verses, String page);

  /// Index line for a juz.
  ///
  /// In en, this message translates to:
  /// **'Starts at page {page}'**
  String quranJuzLine(String page);

  /// Index filter: nothing found.
  ///
  /// In en, this message translates to:
  /// **'No surah matches.'**
  String get quranNoSurah;

  /// Action and title: Quran text search.
  ///
  /// In en, this message translates to:
  /// **'Search the Quran'**
  String get quranSearch;

  /// Search field hint.
  ///
  /// In en, this message translates to:
  /// **'Arabic word or phrase'**
  String get quranSearchHint;

  /// Search screen before typing.
  ///
  /// In en, this message translates to:
  /// **'Type an Arabic word or part of a verse. Search works offline and ignores diacritics and the different spellings of alef and hamza.'**
  String get quranSearchIdle;

  /// Search: no results.
  ///
  /// In en, this message translates to:
  /// **'No verse matches.'**
  String get quranSearchEmpty;

  /// Search: number of matching verses.
  ///
  /// In en, this message translates to:
  /// **'{count} verses'**
  String quranSearchCount(String count);

  /// Search: result list truncated.
  ///
  /// In en, this message translates to:
  /// **'Showing the first {shown} of {total} verses. Type more to narrow it.'**
  String quranSearchMore(String shown, String total);

  /// Search result reference.
  ///
  /// In en, this message translates to:
  /// **'Verse {verse} · page {page}'**
  String quranVerseRef(String verse, String page);

  /// Button: add a bookmark.
  ///
  /// In en, this message translates to:
  /// **'Bookmark this page'**
  String get quranBookmarkAdd;

  /// Button: remove the page's bookmark.
  ///
  /// In en, this message translates to:
  /// **'Remove bookmark'**
  String get quranBookmarkRemove;

  /// Action and title: saved notes.
  ///
  /// In en, this message translates to:
  /// **'Bookmarks and highlights'**
  String get quranNotes;

  /// Notes tab: bookmarks.
  ///
  /// In en, this message translates to:
  /// **'Bookmarks'**
  String get quranBookmarksTab;

  /// Notes tab: highlights.
  ///
  /// In en, this message translates to:
  /// **'My highlights'**
  String get quranHighlightsTab;

  /// Notes: no bookmarks.
  ///
  /// In en, this message translates to:
  /// **'No bookmarks yet. Use the bookmark button on a page.'**
  String get quranNoBookmarks;

  /// Notes: no highlights.
  ///
  /// In en, this message translates to:
  /// **'No highlights yet. Choose Highlight on a page.'**
  String get quranNoHighlights;

  /// Action: start an area highlight.
  ///
  /// In en, this message translates to:
  /// **'Highlight'**
  String get quranHighlight;

  /// Explains area highlighting while drawing.
  ///
  /// In en, this message translates to:
  /// **'Area highlight: draw boxes over the page. It marks a region of the page image, not specific words or verses. Turn pages with the buttons to continue on another page.'**
  String get quranAreaExplain;

  /// Button: save the drawn highlight.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get quranHighlightSave;

  /// Button: remove the last drawn box.
  ///
  /// In en, this message translates to:
  /// **'Undo last box'**
  String get quranHighlightUndo;

  /// Button: leave drawing mode without saving.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get quranHighlightCancel;

  /// Number of boxes in the highlight being drawn.
  ///
  /// In en, this message translates to:
  /// **'{count} boxes'**
  String quranHighlightBoxes(String count);

  /// A highlight spanning pages.
  ///
  /// In en, this message translates to:
  /// **'Pages {first}–{last}'**
  String quranHighlightPages(String first, String last);

  /// Button: delete a highlight.
  ///
  /// In en, this message translates to:
  /// **'Delete highlight'**
  String get quranHighlightDelete;

  /// Button: open the highlighted page.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get quranHighlightOpen;

  /// Highlight colour picker label.
  ///
  /// In en, this message translates to:
  /// **'Colour'**
  String get quranHighlightColor;

  /// Highlight colour.
  ///
  /// In en, this message translates to:
  /// **'Yellow'**
  String get quranColorYellow;

  /// Highlight colour.
  ///
  /// In en, this message translates to:
  /// **'Green'**
  String get quranColorGreen;

  /// Highlight colour.
  ///
  /// In en, this message translates to:
  /// **'Blue'**
  String get quranColorBlue;

  /// Highlight colour.
  ///
  /// In en, this message translates to:
  /// **'Pink'**
  String get quranColorPink;

  /// Highlight colour.
  ///
  /// In en, this message translates to:
  /// **'Orange'**
  String get quranColorOrange;

  /// Action and title: storage management.
  ///
  /// In en, this message translates to:
  /// **'Quran download'**
  String get quranStorage;

  /// Installed edition line.
  ///
  /// In en, this message translates to:
  /// **'Madinah Mushaf · Hafs · digital edition {edition} · package {version}'**
  String quranEdition(String edition, String version);

  /// Measured storage used by the Quran download.
  ///
  /// In en, this message translates to:
  /// **'On this device: {size}'**
  String quranOnDevice(String size);

  /// Button: verify every file's hash.
  ///
  /// In en, this message translates to:
  /// **'Check all files'**
  String get quranVerify;

  /// Verification progress.
  ///
  /// In en, this message translates to:
  /// **'Checking {done} of {total} files…'**
  String quranVerifying(String done, String total);

  /// Verification passed.
  ///
  /// In en, this message translates to:
  /// **'All {count} files match the official copy.'**
  String quranVerified(String count);

  /// Button: delete the Quran package.
  ///
  /// In en, this message translates to:
  /// **'Remove download'**
  String get quranRemove;

  /// Confirm dialog title.
  ///
  /// In en, this message translates to:
  /// **'Remove the downloaded Quran?'**
  String get quranRemoveTitle;

  /// Confirm dialog body.
  ///
  /// In en, this message translates to:
  /// **'Offline reading stops until you download it again ({size}). Your bookmarks, highlights and last page are kept and come back when you download it again.'**
  String quranRemoveBody(String size);

  /// Confirm button: remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get quranRemoveConfirm;

  /// Dismiss button: keep the download.
  ///
  /// In en, this message translates to:
  /// **'Keep'**
  String get quranKeep;

  /// Snack bar after removal.
  ///
  /// In en, this message translates to:
  /// **'The Quran download was removed. Your notes are kept.'**
  String get quranRemoved;

  /// Page image failed to decode.
  ///
  /// In en, this message translates to:
  /// **'This page could not be shown. Check the files under Quran download.'**
  String get quranPageError;

  /// Reader loading.
  ///
  /// In en, this message translates to:
  /// **'Opening the Mushaf…'**
  String get quranOpening;

  /// Screen reader label of the page surface.
  ///
  /// In en, this message translates to:
  /// **'Mushaf page {page}. Swipe right or use Next page to read on.'**
  String quranReaderLabel(String page);

  /// Menu button.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get quranMore;

  /// Button shown while controls are hidden.
  ///
  /// In en, this message translates to:
  /// **'Show controls'**
  String get quranShowControls;
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
