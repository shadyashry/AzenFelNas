import 'package:daily_muslim/features/contexts/domain/gazetteer_hit.dart';
import 'package:meta/meta.dart';

/// The city chosen in the first-run city picker (§15 D126): none yet, or
/// [hit], being stored while [saving].
@immutable
final class CityPick {
  /// The pick.
  const new({this.hit, this.saving = false});

  /// The chosen city, or `null` before the user taps one.
  final GazetteerHit? hit;

  /// The city is being pinned; the confirm button shows progress.
  final bool saving;
}
