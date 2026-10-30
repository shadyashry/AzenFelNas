import 'package:dm_packages/dm_packages.dart';
import 'package:geo_salah_profiles/geo_salah_profiles.dart';

/// Facts about this build that the package client checks `compat` against
/// (§10.3). [version] equals `pubspec.yaml` (a test keeps them equal).
abstract final class AppBuild {
  /// The app version, `major.minor.patch`.
  static const version = '0.2.0';

  /// The prayer-profile schema the engine reads (`minEngineSchema` gate).
  static const engineSchema = 1;

  /// The compatibility the client checks: only types with a payload reader
  /// in `PackagePayloadChecks` are listed.
  static final compat = AppCompat(
    appVersion: version,
    engineSchema: engineSchema,
    schemaVersions: const {
      PackageType.gazetteer: 1,
      PackageType.prayerProfiles: 1,
      PackageType.tzdata: 1,
      PackageType.tzPolygons: 1,
      PackageType.countryPolygons: 1,
    },
  );

  /// The release channel this binary was built for (`--dart-define
  /// DM_CHANNEL=dev|lab|beta|production`, §15 D77). `DRAFT_UNVERIFIED`
  /// profiles calculate only on `dev` and `lab` (Appendix E); a build
  /// without the define is `dev`, and the release pipeline (S27) sets it.
  /// An unknown name is `production`, the strictest channel, so a typo never
  /// loads draft profiles.
  static final ReleaseChannel channel = ReleaseChannel.values.firstWhere(
    (channel) => channel.name == _channelName,
    orElse: () => ReleaseChannel.production,
  );

  static const String _channelName = String.fromEnvironment(
    'DM_CHANNEL',
    defaultValue: 'dev',
  );
}
