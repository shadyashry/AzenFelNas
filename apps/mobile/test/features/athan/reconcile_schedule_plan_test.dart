import 'dart:convert';

import 'package:daily_muslim/features/athan/application/reconcile_schedule_plan.dart';
import 'package:daily_muslim/features/athan/domain/write_schedule_plan.dart';
import 'package:dm_contracts/dm_contracts.dart';
import 'package:flutter_test/flutter_test.dart';

import 'plan_fixtures.dart';

final class _Host implements WriteSchedulePlan {
  new({required this.accepts});

  final bool accepts;
  final written = <EncodedPlan>[];

  @override
  Future<bool> call(EncodedPlan plan) async {
    written.add(plan);
    return accepts;
  }
}

void main() {
  group('ReconcileSchedulePlan (§7.8, §15 D94)', () {
    test('REQ-ALM-002 hands the host the plan as schedule_plan.v1 JSON that '
        'decodes to the same plan', () async {
      final plan = planBuilder()(cairoRequest());
      final host = _Host(accepts: true);

      expect(await ReconcileSchedulePlan(host)(plan), isTrue);
      expect(
        SchedulePlan.fromJson(
          jsonDecode(host.written.single.json) as Map<String, Object?>,
        ),
        plan,
      );
    });

    test('a refusing host is reported as not applied', () async {
      expect(
        await ReconcileSchedulePlan(_Host(accepts: false))(
          planBuilder()(cairoRequest()),
        ),
        isFalse,
      );
    });
  });
}
