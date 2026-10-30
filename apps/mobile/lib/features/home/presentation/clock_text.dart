import 'package:daily_muslim/features/home/domain/time_row_view.dart';
import 'package:daily_muslim/features/home/presentation/display_style.dart';
import 'package:daily_muslim/l10n/app_localizations.dart';
import 'package:flutter/widgets.dart';

/// A displayed time split for typesetting (§15 D109): the [clock] digits,
/// the AM/PM [period] when the phone uses a 12-hour clock, and the day
/// [offset] ("+1") when the time falls on the next or previous civil day.
/// Only the presentation changes: the displayed minute is the row's own.
@immutable
final class ClockText {
  /// The parts.
  const new({required this.clock, this.period, this.offset});

  /// The time of [row] for [context]: 12-hour with "AM"/"PM" («ص»/«م»)
  /// unless the phone is set to a 24-hour clock, in [style]'s digits; a
  /// dash when the row has no time.
  factory of(
    BuildContext context,
    AppLocalizations l,
    TimeRowView row,
    DisplayStyle style,
  ) {
    final local = row.localTime;
    final offset = switch (row.dayOffset) {
      0 => null,
      final n when n > 0 => style.digits.apply('+$n'),
      final n => style.digits.apply('$n'),
    };
    final parts = local?.split(':');
    final hour = parts == null ? null : int.tryParse(parts.first);
    if (local == null || parts == null || hour == null || parts.length < 2) {
      return ClockText(clock: local ?? l.noTimeText, offset: offset);
    }
    if (MediaQuery.alwaysUse24HourFormatOf(context)) {
      return ClockText(clock: style.digits.apply(local), offset: offset);
    }
    final twelve = hour % 12 == 0 ? 12 : hour % 12;
    return ClockText(
      clock: style.digits.apply('$twelve:${parts[1]}'),
      period: hour < 12 ? l.timeAm : l.timePm,
      offset: offset,
    );
  }

  /// The digits, e.g. `3:42`; set them in a left-to-right [Text] so the
  /// colon never flips inside Arabic text.
  final String clock;

  /// "AM"/"PM" («ص»/«م»); `null` on a 24-hour clock or without a time.
  final String? period;

  /// "+1"/"−1"; `null` on the row's own day.
  final String? offset;

  /// All parts on one line, e.g. `3:42 PM +1`.
  String get plain => [clock, ?period, ?offset].join(' ');
}
