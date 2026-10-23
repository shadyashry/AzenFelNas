import 'package:meta/meta.dart';

/// One piece of plan copy in both plan locales (§7.7): native code renders
/// [ar] or [en] as given and never formats text itself.
@immutable
final class PlanCopy {
  /// Copy with [ar] and [en] text, both non-empty.
  const new({required this.ar, required this.en});

  /// Arabic text.
  final String ar;

  /// English text.
  final String en;
}
