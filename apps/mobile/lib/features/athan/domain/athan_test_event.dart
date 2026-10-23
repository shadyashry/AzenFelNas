import 'package:meta/meta.dart';

/// Inputs of the Athan Test state machine (`AdvanceAthanTest`).
@immutable
sealed class AthanTestEvent {
  const new();
}

/// The platform armed Test [testId] at [nowUtcMs] for [fireAtUtcMs].
final class TestArmed extends AthanTestEvent {
  /// Armed.
  const new({
    required this.testId,
    required this.fireAtUtcMs,
    required this.nowUtcMs,
  });

  /// When it was armed (UTC epoch ms).
  final int nowUtcMs;

  /// The Test id.
  final String testId;

  /// When it fires (UTC epoch ms).
  final int fireAtUtcMs;
}

/// The platform refused to arm the Test.
final class TestRefused extends AthanTestEvent {
  /// Refused.
  const new();
}

/// The injected clock reads [nowUtcMs].
final class ClockTicked extends AthanTestEvent {
  /// A tick.
  const new(this.nowUtcMs);

  /// Now (UTC epoch ms).
  final int nowUtcMs;
}

/// The user answered "Did you hear it?".
final class HeardAnswered extends AthanTestEvent {
  /// The answer [heard] at [nowUtcMs]; [presentedByOs] from the receipts.
  const new({
    required this.heard,
    required this.presentedByOs,
    required this.nowUtcMs,
  });

  /// The user's answer.
  final bool heard;

  /// Receipt evidence (null: none available).
  final bool? presentedByOs;

  /// Now (UTC epoch ms).
  final int nowUtcMs;
}

/// The user closed the result or cancelled the question.
final class TestReset extends AthanTestEvent {
  /// Reset.
  const new();
}
