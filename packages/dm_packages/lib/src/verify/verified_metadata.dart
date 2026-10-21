import 'package:dm_packages/src/tuf/tuf_signed.dart';
import 'package:dm_packages/src/verify/freshness_warning.dart';
import 'package:dm_packages/src/verify/trusted_sequences.dart';
import 'package:meta/meta.dart';

/// A channel's metadata after a successful chain check.
@immutable
final class VerifiedMetadata {
  /// The verified chain.
  const new({
    required this.root,
    required this.targets,
    required this.sequences,
    required this.warnings,
  });

  /// The verified `root.json` document; it becomes the next trusted root.
  final TufRootSigned root;

  /// The verified `targets.json` document: what may be downloaded.
  final TufTargetsSigned targets;

  /// The sequences to trust from now on.
  final TrustedSequences sequences;

  /// Expired roles; never a reason to stop calculating (REQ-PKG-002).
  final List<FreshnessWarning> warnings;
}
