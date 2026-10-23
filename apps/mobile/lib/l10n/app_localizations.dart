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

  /// Onboarding welcome button.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get onboardingStart;

  /// Onboarding location step title.
  ///
  /// In en, this message translates to:
  /// **'Where are you?'**
  String get onboardingLocationTitle;

  /// Onboarding location step body.
  ///
  /// In en, this message translates to:
  /// **'Approximate location is enough for today\'s times. You can choose a place instead.'**
  String get onboardingLocationBody;

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
  /// **'No place found. Try another spelling or enter coordinates.'**
  String get placeEmpty;

  /// Manual place: search failed.
  ///
  /// In en, this message translates to:
  /// **'The search did not work (code {code}).'**
  String placeError(String code);

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
  /// **'There is no local authority profile here; the engine default is used.'**
  String get homeNoProfile;

  /// Home: calculation failed.
  ///
  /// In en, this message translates to:
  /// **'Prayer times could not be worked out (code {code}).'**
  String homeError(String code);

  /// Home: Athan readiness before Athan exists.
  ///
  /// In en, this message translates to:
  /// **'Athan: not set up yet'**
  String get homeHealthUnknown;

  /// Home: place chip for a manual context (US-02).
  ///
  /// In en, this message translates to:
  /// **'Manual place · {label}'**
  String homeManualPlace(String label);

  /// Home: place chip for the device location.
  ///
  /// In en, this message translates to:
  /// **'Approximate location'**
  String get homeCurrentPlace;

  /// Home: place chip for a pinned context.
  ///
  /// In en, this message translates to:
  /// **'Pinned place · {label}'**
  String homePinnedPlace(String label);

  /// Home: button to manual place.
  ///
  /// In en, this message translates to:
  /// **'Change place'**
  String get homeChangePlace;

  /// Day timeline title and Home button.
  ///
  /// In en, this message translates to:
  /// **'Next 7 days'**
  String get timelineTitle;

  /// Day timeline: failed.
  ///
  /// In en, this message translates to:
  /// **'The days could not be worked out (code {code}).'**
  String timelineError(String code);

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

  /// Qibla without a place.
  ///
  /// In en, this message translates to:
  /// **'Choose a place to see the Qibla.'**
  String get qiblaNeedsPlace;

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
  /// **'Open Daily Muslim to keep the Athan scheduled.'**
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
  /// **'Allow notifications for Daily Muslim'**
  String get athanReasonNeedsNotificationPermission;

  /// Health reason.
  ///
  /// In en, this message translates to:
  /// **'Allow alarms and reminders'**
  String get athanReasonNeedsExactAlarmPermission;

  /// Health reason.
  ///
  /// In en, this message translates to:
  /// **'Allow alarms for Daily Muslim'**
  String get athanReasonNeedsAlarmKitAuthorization;

  /// Health reason.
  ///
  /// In en, this message translates to:
  /// **'The Athan sound is muted in system settings'**
  String get athanReasonMutedChannel;

  /// Health reason.
  ///
  /// In en, this message translates to:
  /// **'The phone restricts Daily Muslim in the background'**
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

  /// Health reason.
  ///
  /// In en, this message translates to:
  /// **'Alarms may be a few minutes late'**
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
