import 'package:dm_core_types/dm_core_types.dart';
import 'package:geo_salah_core/geo_salah_core.dart';
import 'package:geo_salah_profiles/src/profile_failure.dart';
import 'package:geo_salah_profiles/src/profile_set.dart';
import 'package:geo_salah_profiles/src/release_channel.dart';

/// The channel gate of Appendix E and §0.1: `DRAFT_UNVERIFIED` and
/// `CANDIDATE` profiles load on `dev` and `lab` only. On `beta` or
/// `production` a set holding one is refused as a whole with
/// `ProfileFailure.invalid`, never silently trimmed. Pure.
final class CheckProfileChannel {
  /// The use case.
  const new();

  /// [set] when every profile may load on [channel], or the first that may
  /// not.
  Result<ProfileSet, ProfileFailure> call(
    ProfileSet set,
    ReleaseChannel channel,
  ) {
    final releaseChannel = switch (channel) {
      ReleaseChannel.dev || ReleaseChannel.lab => false,
      ReleaseChannel.beta || ReleaseChannel.production => true,
    };
    if (!releaseChannel) return Result.ok(set);
    for (final profile in set.profiles) {
      final unreleased = switch (profile.status) {
        ProfileStatus.draftUnverified || ProfileStatus.candidate => true,
        ProfileStatus.approved || ProfileStatus.retired => false,
      };
      if (unreleased) {
        return Result.err(
          ProfileFailure.invalid(
            '${profile.profileId}@${profile.version} is '
            '${profile.status.name}; it loads on dev and lab only',
          ),
        );
      }
    }
    return Result.ok(set);
  }
}
