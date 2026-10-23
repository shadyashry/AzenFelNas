import 'package:daily_muslim/features/home/domain/time_row_view.dart';
import 'package:dm_core_types/dm_core_types.dart';
import 'package:meta/meta.dart';

/// One prayer day as Home and the timeline show it.
@immutable
final class DayView {
  /// [rows] of prayer day [date].
  const new({
    required this.date,
    required this.calculationId,
    required this.rows,
  });

  /// The civil date of the prayer day.
  final CivilDate date;

  /// The day's Calculation ID (Passport, S18).
  final String calculationId;

  /// The events in prayer order.
  final List<TimeRowView> rows;
}
