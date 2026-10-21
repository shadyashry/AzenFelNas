import 'package:geo_salah_core/geo_salah_core.dart';
import 'package:geo_salah_core/src/policy/confidence_mapper.dart';
import 'package:test/test.dart';

import '../support/engine_fixtures.dart';

const ConfidenceMapper _mapper = ConfidenceMapper();

ConfidenceLabel _label(
  EventOrigin origin,
  PrayerProfile profile, {
  int perturbationMinutes = 0,
}) => _mapper.labelOf(
  origin,
  profile,
  perturbationMinutes: perturbationMinutes,
);

void main() {
  group('ConfidenceMapper (§6.2, REQ-DOM-050)', () {
    final aligned = testProfile.copyWith(
      status: ProfileStatus.approved,
      authorityType: AuthorityType.government,
      benchmarkReportId: 'zz-report-1',
    );
    const primary = EventOrigin.primary();

    test('labels a primary time of an approved government or recognised '
        'body profile with a benchmark report Authority aligned', () {
      for (final authority in [
        AuthorityType.government,
        AuthorityType.recognizedBody,
      ]) {
        expect(
          _label(primary, aligned.copyWith(authorityType: authority)),
          const ConfidenceLabel.authorityAligned(
            benchmarkReportId: 'zz-report-1',
          ),
        );
      }
    });

    test('labels every other primary time Calculated', () {
      for (final profile in [
        testProfile,
        aligned.copyWith(status: ProfileStatus.candidate),
        aligned.copyWith(status: ProfileStatus.draftUnverified),
        aligned.copyWith(status: ProfileStatus.retired),
        aligned.copyWith(authorityType: AuthorityType.communityConvention),
        aligned.copyWith(authorityType: AuthorityType.engineDefault),
        aligned.copyWith(benchmarkReportId: null),
      ]) {
        expect(
          _label(primary, profile),
          const ConfidenceLabel.calculated(),
          reason: '$profile',
        );
      }
    });

    test('labels a fallback Estimated with a range of at least 5 minutes '
        '(REQ-UX-001)', () {
      const fallback = EventOrigin.fallback(HighLatitudeMethod.middleOfNight());
      expect(
        _label(fallback, aligned, perturbationMinutes: 2),
        const ConfidenceLabel.estimated(rangeMinutes: 5),
      );
      expect(
        _label(fallback, aligned, perturbationMinutes: 12),
        const ConfidenceLabel.estimated(rangeMinutes: 12),
      );
    });

    test('labels a missing time Unknown with its reason, whatever the '
        'profile', () {
      for (final reason in NoEventReason.values) {
        expect(
          _label(EventOrigin.noEvent(reason), aligned),
          ConfidenceLabel.unknown(reasonCode: reason.code),
        );
      }
    });
  });
}
