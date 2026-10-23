import 'package:daily_muslim/features/contexts/domain/context_kind.dart';
import 'package:meta/meta.dart';

/// What Home says about the place it calculated for (§18.3 "Manual place"
/// chip, US-02).
@immutable
final class PlaceView {
  /// A place of [kind] named [label].
  const new({required this.kind, required this.label});

  /// Current, pinned or manual.
  final ContextKind kind;

  /// The user-visible name; empty for the device location.
  final String label;

  @override
  bool operator ==(Object other) =>
      other is PlaceView && other.kind == kind && other.label == label;

  @override
  int get hashCode => Object.hash(kind, label);
}
