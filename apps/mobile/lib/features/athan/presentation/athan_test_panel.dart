import 'package:daily_muslim/features/athan/domain/athan_test_state.dart';
import 'package:daily_muslim/features/athan/presentation/athan_test_controller.dart';
import 'package:daily_muslim/l10n/app_localizations.dart';
import 'package:dm_ui/dm_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The Athan Test section (§18.4 `idle | scheduled(countdown) | fired |
/// askHeard | recorded(result)`, REQ-ALM-040).
final class AthanTestPanel extends ConsumerWidget {
  /// The panel testing [soundId]; null disables the Test.
  const new({required this.soundId, super.key});

  /// The chosen Athan sound.
  final String? soundId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final test = ref.read(athanTestProvider.notifier);
    final sound = soundId;
    final state = ref.watch(athanTestProvider);
    final body = <Widget>[
      ...switch (state) {
        AthanTestIdle() || AthanTestNotArmed() => [
          if (state is AthanTestNotArmed) Text(l.athanTestNotArmed),
          if (sound == null)
            Text(l.athanTestNeedsSound)
          else
            FilledButton(
              onPressed: () => test.start(sound),
              child: Text(l.athanTestStart),
            ),
        ],
        AthanTestScheduled(:final secondsLeft) => [
          Text(l.athanTestScheduled(secondsLeft)),
        ],
        AthanTestFired() => [Text(l.athanTestFired), _Answer(l, test)],
        AthanTestAskHeard() => [_Answer(l, test)],
        AthanTestRecorded(:final result) => [
          Text(result.heardByUser ? l.athanTestHeard : l.athanTestNotHeard),
          TextButton(onPressed: test.reset, child: Text(l.athanTestAgain)),
        ],
      },
    ];
    return RawdahSection(
      title: l.athanTestTitle,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 10,
            children: body,
          ),
        ),
      ],
    );
  }
}

final class _Answer extends StatelessWidget {
  const new(this.l, this.test);

  final AppLocalizations l;
  final AthanTestController test;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(l.athanTestAsk),
      Row(
        spacing: 8,
        children: [
          FilledButton(
            onPressed: () => test.answer(heard: true),
            child: Text(l.athanTestYes),
          ),
          OutlinedButton(
            onPressed: () => test.answer(heard: false),
            child: Text(l.athanTestNo),
          ),
        ],
      ),
    ],
  );
}
