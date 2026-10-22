import 'package:daily_muslim/features/shell/domain/remediation.dart';
import 'package:dm_core_types/dm_core_types.dart';
import 'package:meta/meta.dart';

/// A failure as the user sees it: its Appendix J [code] and what to do.
@immutable
final class NeedsAttention {
  /// The notice for [code].
  const new({required this.code, required this.remediation});

  /// The Appendix J code (shown in the details and the diagnostics).
  final FailureCode code;

  /// The action offered.
  final Remediation remediation;

  @override
  bool operator ==(Object other) =>
      other is NeedsAttention &&
      other.code == code &&
      other.remediation == remediation;

  @override
  int get hashCode => Object.hash(code, remediation);
}
