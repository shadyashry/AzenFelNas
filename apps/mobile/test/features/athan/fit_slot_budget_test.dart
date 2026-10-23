import 'package:daily_muslim/features/athan/application/fit_slot_budget.dart';
import 'package:dm_contracts/dm_contracts.dart';
import 'package:flutter_test/flutter_test.dart';

SchedulePlanEntry _entry(String id, int priority, int fireAtUtcMs) =>
    SchedulePlanEntry(
      id: id,
      day: '2026-10-22',
      kind: ScheduleEntryKind.athan,
      fireAtUtcMs: fireAtUtcMs,
      displayLocal: '00:00',
      title: const LocalizedText(ar: 'ع', en: 't'),
      body: const LocalizedText(ar: 'ع', en: 'b'),
      soundId: 's',
      priority: priority,
    );

void main() {
  const fit = FitSlotBudget();

  group('FitSlotBudget (REQ-ALM-032)', () {
    test('REQ-ALM-032 entries within the budget are kept unchanged', () {
      final entries = [_entry('a', 3, 1), _entry('b', 1, 2)];
      expect(fit(entries, 2), entries);
    });

    test('REQ-ALM-032 lower priorities are dropped first, from the '
        'farthest instant, and the order is kept', () {
      final entries = [
        _entry('remind-near', 3, 10),
        _entry('athan-near', 1, 20),
        _entry('imsak-mid', 2, 30),
        _entry('remind-far', 3, 40),
        _entry('athan-far', 1, 50),
      ];
      expect(fit(entries, 4).map((e) => e.id), [
        'remind-near',
        'athan-near',
        'imsak-mid',
        'athan-far',
      ]);
      expect(fit(entries, 3).map((e) => e.id), [
        'athan-near',
        'imsak-mid',
        'athan-far',
      ]);
      expect(fit(entries, 1).map((e) => e.id), ['athan-near']);
    });

    test('REQ-ALM-032 a budget of zero keeps nothing', () {
      expect(fit([_entry('a', 1, 1)], 0), isEmpty);
    });
  });
}
