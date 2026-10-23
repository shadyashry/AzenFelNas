import 'package:daily_muslim/features/athan/data/arb_plan_texts.dart';
import 'package:daily_muslim/features/athan/domain/plan_text_key.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geo_salah_core/geo_salah_core.dart';

void main() {
  final texts = ArbPlanTexts();
  final keys = <PlanTextKey>[
    for (final event in PrayerEvent.values) AthanText(event),
    const ImsakText(),
    for (final event in PrayerEvent.values) PreReminderText(event, 15),
    const HorizonText(),
  ];

  group('PlanTexts contract (ArbPlanTexts)', () {
    test('REQ-DOM-040 every key renders non-empty ar and en copy', () {
      for (final key in keys) {
        for (final text in [texts.title(key), texts.body(key)]) {
          expect(text.ar.trim(), isNotEmpty, reason: '$key');
          expect(text.en.trim(), isNotEmpty, reason: '$key');
        }
      }
    });

    test('REQ-DOM-040 the copy names the prayer and the offset', () {
      final title = texts.title(const PreReminderText(PrayerEvent.fajr, 15));
      expect(title.en, contains('Fajr'));
      expect(title.en, contains('15'));
      expect(
        texts.title(const AthanText(PrayerEvent.isha)).ar,
        contains('العشاء'),
      );
    });
  });
}
