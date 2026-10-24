// The ApplySchedulePlan contract (§7.8), run against the fake the rollback
// drill uses; the Kotlin `PlanStoreTest` holds the native store to the same
// rules (generation order, whole-document replace).
import 'package:daily_muslim/features/athan/application/apply_schedule_plan.dart';
import 'package:flutter_test/flutter_test.dart';

import 'plan_fixtures.dart';
import 'support/fake_plan_host.dart';

void main() {
  void contract(String name, FakePlanHost Function() host) {
    group(name, () {
      test('REQ-ALM-035 a newer plan replaces the stored one whole', () async {
        final ApplySchedulePlan apply = host();
        final first = planBuilder()(cairoRequest());
        final second = planBuilder()(cairoRequest(generation: 2));
        expect(await apply(first), isTrue);
        expect(await apply(second), isTrue);
        expect((apply as FakePlanHost).stored, second);
      });

      test('REQ-ALM-035 an older generation is refused and the stored plan '
          'stays', () async {
        final fake = host();
        final newer = planBuilder()(cairoRequest(generation: 3));
        await fake(newer);
        expect(await fake(planBuilder()(cairoRequest(generation: 2))), isFalse);
        expect(fake.stored, newer);
      });

      test('REQ-ALM-035 the same generation is written again', () async {
        final fake = host();
        final plan = planBuilder()(cairoRequest());
        await fake(plan);
        expect(await fake(plan), isTrue);
      });
    });
  }

  contract('FakePlanHost', FakePlanHost.new);
}
