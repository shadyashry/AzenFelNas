import 'package:dm_core_types/dm_core_types.dart';
import 'package:geo_salah_core/geo_salah_core.dart';
import 'package:geo_salah_profiles/geo_salah_profiles.dart';
import 'package:test/test.dart';

import 'support/profile_files.dart';

const CheckProfileChannel _check = CheckProfileChannel();

ProfileSet _setOf(List<PrayerProfile> profiles) =>
    switch (const ValidateProfileSet()(profiles)) {
      Ok(:final value) => value,
      Err(:final failure) => throw StateError(failure.detail),
    };

void main() {
  group('CheckProfileChannel (Appendix E)', () {
    test('loads DRAFT_UNVERIFIED and CANDIDATE profiles on dev and lab '
        'only', () {
      for (final status in [
        ProfileStatus.draftUnverified,
        ProfileStatus.candidate,
      ]) {
        final set = _setOf([
          for (final profile in seedProfiles())
            profile.copyWith(status: status),
        ]);
        for (final channel in ReleaseChannel.values) {
          final allowed =
              channel == ReleaseChannel.dev || channel == ReleaseChannel.lab;
          expect(
            _check(set, channel) is Ok,
            allowed,
            reason: '$status on $channel',
          );
        }
      }
    });

    test('loads an all-approved set on every channel', () {
      final set = _setOf([
        for (final profile in seedProfiles())
          profile.copyWith(status: ProfileStatus.approved),
      ]);
      for (final channel in ReleaseChannel.values) {
        expect(
          _check(set, channel),
          Result<ProfileSet, ProfileFailure>.ok(set),
        );
      }
    });
  });
}
