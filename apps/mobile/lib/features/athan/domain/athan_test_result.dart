import 'package:meta/meta.dart';

/// The outcome of one Athan Test (§8.3, REQ-ALM-040): what the OS reported
/// and what the user answered are kept apart.
@immutable
final class AthanTestResult {
  /// The result of Test [testId].
  const new({
    required this.testId,
    required this.heardByUser,
    required this.presentedByOs,
    required this.answeredAtUtcMs,
  });

  /// `TEST_RESULT` `state` of a heard Test.
  static const String heardState = 'heard';

  /// `TEST_RESULT` `state` of a Test the user did not hear.
  static const String notHeardState = 'notHeard';

  /// The Test id (16 hex digits).
  final String testId;

  /// The user's answer to "Did you hear it?".
  final bool heardByUser;

  /// A native `ALARM_PRESENTED` receipt was seen (true), or not (null: the
  /// iOS notification path has no receipt while the app is not running).
  final bool? presentedByOs;

  /// UTC epoch ms of the answer.
  final int answeredAtUtcMs;

  @override
  bool operator ==(Object other) =>
      other is AthanTestResult &&
      other.testId == testId &&
      other.heardByUser == heardByUser &&
      other.presentedByOs == presentedByOs &&
      other.answeredAtUtcMs == answeredAtUtcMs;

  @override
  int get hashCode =>
      Object.hash(testId, heardByUser, presentedByOs, answeredAtUtcMs);
}
