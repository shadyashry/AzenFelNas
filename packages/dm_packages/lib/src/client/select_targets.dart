import 'package:dm_packages/src/client/active_package.dart';
import 'package:dm_packages/src/client/package_type.dart';
import 'package:dm_packages/src/client/target_choice.dart';
import 'package:dm_packages/src/tuf/tuf_signed.dart';

/// Chooses, per package type, the target to install from a verified
/// `targets.json` (§15 D74). Pure and deterministic.
///
/// A type's candidates are its targets that are in effect
/// (`effectiveFrom` ≤ [call]'s `todayUtc`), that no other target names in
/// `rollbackOf`, and that the client has not refused. The candidate with
/// the latest `effectiveFrom` wins, ties going to the greater version in
/// byte order. Nothing is chosen when the winner is already active. Types
/// this build does not know are ignored.
final class SelectTargets {
  /// The use case.
  const new();

  /// The choices, ordered by type wire name.
  List<TargetChoice> call(
    TufTargetsSigned targets, {
    required Map<PackageType, ActivePackage> active,
    required Set<String> refusedNames,
    required String todayUtc,
  }) {
    final rolledBack = <String>{};
    for (final MapEntry(key: name, value: target) in targets.targets.entries) {
      if (target.custom.rollbackOf case final from?) {
        rolledBack.add('${name.split('/').first}/$from');
      }
    }
    final best = <PackageType, TargetChoice>{};
    for (final MapEntry(key: name, value: target) in targets.targets.entries) {
      final slash = name.indexOf('/');
      final type = PackageType.fromWire(name.substring(0, slash));
      if (type == null ||
          rolledBack.contains(name) ||
          refusedNames.contains(name) ||
          target.custom.effectiveFrom.compareTo(todayUtc) > 0) {
        continue;
      }
      final choice = TargetChoice(
        type: type,
        version: name.substring(slash + 1),
        target: target,
      );
      final current = best[type];
      if (current == null || _later(choice, current)) best[type] = choice;
    }
    final chosen = [
      for (final choice in best.values)
        if (active[choice.type]?.version != choice.version) choice,
    ]..sort((a, b) => a.type.wire.compareTo(b.type.wire));
    return List.unmodifiable(chosen);
  }

  static bool _later(TargetChoice a, TargetChoice b) {
    final byDate = a.target.custom.effectiveFrom.compareTo(
      b.target.custom.effectiveFrom,
    );
    return byDate != 0 ? byDate > 0 : a.version.compareTo(b.version) > 0;
  }
}
