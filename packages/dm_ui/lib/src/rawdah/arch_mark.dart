import 'package:dm_ui/src/rawdah/arch_position.dart';
import 'package:meta/meta.dart';

/// One prayer on the arch.
@immutable
final class ArchMark {
  /// [label] at [position]; [isNext] for the awaited prayer.
  const new({
    required this.label,
    required this.position,
    this.isNext = false,
  });

  /// Localised prayer name.
  final String label;

  /// Where it sits.
  final ArchPosition position;

  /// Whether this is the next prayer.
  final bool isNext;
}
