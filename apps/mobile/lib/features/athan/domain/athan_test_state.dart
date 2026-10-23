import 'package:daily_muslim/features/athan/domain/athan_test_result.dart';
import 'package:meta/meta.dart';

/// The Athan Test screen state (§18.4): `idle`, `scheduled(countdown)`,
/// `fired`, `askHeard`, `recorded(result)`, plus `notArmed` when the
/// platform refused (§17.8 item 4).
@immutable
sealed class AthanTestState {
  const new();
}

/// No Test running.
final class AthanTestIdle extends AthanTestState {
  /// Idle.
  const new();

  @override
  bool operator ==(Object other) => other is AthanTestIdle;

  @override
  int get hashCode => (AthanTestIdle).hashCode;
}

/// Armed; fires at [fireAtUtcMs].
final class AthanTestScheduled extends AthanTestState {
  /// Test [testId] armed for [fireAtUtcMs], [secondsLeft] from now.
  const new({
    required this.testId,
    required this.fireAtUtcMs,
    required this.secondsLeft,
  });

  /// The Test id.
  final String testId;

  /// When the Test fires (UTC epoch ms).
  final int fireAtUtcMs;

  /// Whole seconds until [fireAtUtcMs], rounded up.
  final int secondsLeft;

  @override
  bool operator ==(Object other) =>
      other is AthanTestScheduled &&
      other.testId == testId &&
      other.fireAtUtcMs == fireAtUtcMs &&
      other.secondsLeft == secondsLeft;

  @override
  int get hashCode => Object.hash(testId, fireAtUtcMs, secondsLeft);
}

/// The fire time passed; the Athan should be sounding.
final class AthanTestFired extends AthanTestState {
  /// Test [testId] fired at [fireAtUtcMs].
  const new({required this.testId, required this.fireAtUtcMs});

  /// The Test id.
  final String testId;

  /// When the Test fired (UTC epoch ms).
  final int fireAtUtcMs;

  @override
  bool operator ==(Object other) =>
      other is AthanTestFired &&
      other.testId == testId &&
      other.fireAtUtcMs == fireAtUtcMs;

  @override
  int get hashCode => Object.hash(testId, fireAtUtcMs);
}

/// Asking "Did you hear it?".
final class AthanTestAskHeard extends AthanTestState {
  /// Asking about Test [testId].
  const new(this.testId);

  /// The Test id.
  final String testId;

  @override
  bool operator ==(Object other) =>
      other is AthanTestAskHeard && other.testId == testId;

  @override
  int get hashCode => testId.hashCode;
}

/// The answer is stored.
final class AthanTestRecorded extends AthanTestState {
  /// The recorded [result].
  const new(this.result);

  /// The stored result.
  final AthanTestResult result;

  @override
  bool operator ==(Object other) =>
      other is AthanTestRecorded && other.result == result;

  @override
  int get hashCode => result.hashCode;
}

/// The platform refused to arm the Test, or no native layer answered.
final class AthanTestNotArmed extends AthanTestState {
  /// Not armed.
  const new();

  @override
  bool operator ==(Object other) => other is AthanTestNotArmed;

  @override
  int get hashCode => (AthanTestNotArmed).hashCode;
}
