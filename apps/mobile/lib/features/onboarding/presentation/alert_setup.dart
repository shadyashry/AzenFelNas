import 'package:meta/meta.dart';

/// The alert setup of this first run (§15 D127): whether the user went
/// through *Set up prayer alerts*, and whether a prompt or settings screen
/// is open now. Kept for the session only; nothing is stored, so skipping
/// never marks alerts as enabled.
@immutable
final class AlertSetup {
  /// The setup.
  const new({this.asked = false, this.busy = false});

  /// *Set up prayer alerts* ran at least once.
  final bool asked;

  /// A prompt or settings screen is open; the actions wait.
  final bool busy;
}
