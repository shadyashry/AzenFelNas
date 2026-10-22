import 'package:dm_core_types/dm_core_types.dart';
import 'package:dm_packages/src/tuf/tuf_signed.dart';
import 'package:dm_packages/src/verify/chain_checks.dart';
import 'package:dm_packages/src/verify/freshness_warning.dart';
import 'package:dm_packages/src/verify/metadata_files.dart';
import 'package:dm_packages/src/verify/metadata_role.dart';
import 'package:dm_packages/src/verify/package_failure.dart';
import 'package:dm_packages/src/verify/signed_envelope.dart';
import 'package:dm_packages/src/verify/trusted_root.dart';
import 'package:dm_packages/src/verify/trusted_sequences.dart';
import 'package:dm_packages/src/verify/verified_metadata.dart';
import 'package:dm_packages/src/verify/verify_ed25519.dart';

/// Verifies one channel's TUF-lite metadata bottom-up (Appendix C,
/// ADR-009): `root.json` against the [TrustedRoot]'s threshold; `timestamp`,
/// `snapshot` and `targets` against the root's roles; each file against the
/// SHA-256 and sequence its parent pins; every sequence strictly after the
/// trusted one, except an unchanged file
/// (REQ-DIST-001..004, REQ-PKG-005). Expiry is a [FreshnessWarning], never
/// a failure (REQ-PKG-002).
///
/// Root rotation (Appendix C, §15 D74): a `root.json` whose root role names
/// other keys than the [TrustedRoot] must carry the trusted root's
/// threshold and its own; a lower root version is `PKG_SEQUENCE_REGRESSION`.
/// Pure apart from the injected [VerifyEd25519]; deterministic for equal
/// inputs.
final class VerifyMetadataChain {
  /// The use case, checking signatures with [_ed25519].
  const new(this._ed25519);

  final VerifyEd25519 _ed25519;

  /// The verified chain, or the first failure.
  Future<Result<VerifiedMetadata, PackageFailure>> call({
    required MetadataFiles files,
    required TrustedRoot trustedRoot,
    required TrustedSequences trusted,
    required int nowUtcMs,
  }) async {
    final _Root root;
    switch (await _root(files.root, trustedRoot)) {
      case Ok(:final value):
        root = value;
      case Err(:final failure):
        return Result.err(failure);
    }
    final _Docs docs;
    switch (await _roles(files, root)) {
      case Ok(:final value):
        docs = value;
      case Err(:final failure):
        return Result.err(failure);
    }
    final sequences = TrustedSequences(
      timestamp: docs.timestamp.sequence,
      snapshot: docs.snapshot.sequence,
      targets: docs.targets.sequence,
      timestampSha256: docs.timestampSha256,
      snapshotSha256: docs.snapshotSha256,
      targetsSha256: docs.targetsSha256,
    );
    if (_regression(sequences, trusted) case final PackageFailure failure) {
      return Result.err(failure);
    }
    return _freshness(root.doc, docs, nowUtcMs).map(
      (warnings) => VerifiedMetadata(
        root: root.doc,
        targets: docs.targets,
        sequences: sequences,
        warnings: warnings,
      ),
    );
  }

  Future<Result<_Root, PackageFailure>> _root(
    List<int> file,
    TrustedRoot trusted,
  ) async {
    final SignedEnvelope envelope;
    switch (SignedEnvelope.parse(MetadataRole.root, file)) {
      case Ok(:final value):
        envelope = value;
      case Err(:final failure):
        return Result.err(failure);
    }
    if (envelope.metadata.signed case final TufRootSigned doc) {
      final anchorFailure = await checkThreshold(
        _ed25519,
        'root.json (trusted root)',
        envelope,
        trusted.publicKeys,
        trusted.publicKeys.keys.toSet(),
        trusted.threshold,
      );
      if (anchorFailure != null) return Result.err(anchorFailure);
      if (doc.version < trusted.version) {
        return Result.err(
          PackageFailure.sequenceRegression(
            role: MetadataRole.root,
            sequence: doc.version,
            trusted: trusted.version,
          ),
        );
      }
      final Map<String, List<int>> keys;
      switch (rootKeys(doc)) {
        case Ok(:final value):
          keys = value;
        case Err(:final failure):
          return Result.err(failure);
      }
      final ownIds = doc.roles.root.keyIds.toSet();
      final rotated =
          ownIds.length != trusted.publicKeys.length ||
          !ownIds.every(trusted.publicKeys.containsKey);
      if (rotated) {
        final ownFailure = await checkThreshold(
          _ed25519,
          'root.json (its own root role)',
          envelope,
          keys,
          ownIds,
          doc.roles.root.threshold,
        );
        if (ownFailure != null) return Result.err(ownFailure);
      }
      return Result.ok(_Root(doc, keys));
    }
    return const Result.err(
      PackageFailure.signatureInvalid('root.json holds another role'),
    );
  }

  Future<Result<_Docs, PackageFailure>> _roles(
    MetadataFiles files,
    _Root root,
  ) async {
    final timestamp = await _role<TufTimestampSigned>(
      MetadataRole.timestamp,
      files.timestamp,
      root,
    );
    final snapshot = await _role<TufSnapshotSigned>(
      MetadataRole.snapshot,
      files.snapshot,
      root,
    );
    final targets = await _role<TufTargetsSigned>(
      MetadataRole.targets,
      files.targets,
      root,
    );
    switch ((timestamp, snapshot, targets)) {
      case (Err(:final failure), _, _) ||
          (_, Err(:final failure), _) ||
          (_, _, Err(:final failure)):
        return Result.err(failure);
      case (
        Ok(value: (final ts, final tsEnvelope)),
        Ok(value: (final sn, final snEnvelope)),
        Ok(value: (final tg, final tgEnvelope)),
      ):
        final pinFailure =
            checkPinned(
              MetadataRole.snapshot,
              snEnvelope,
              sn.sequence,
              ts.meta.snapshotJson,
            ) ??
            checkPinned(
              MetadataRole.targets,
              tgEnvelope,
              tg.sequence,
              sn.meta.targetsJson,
            );
        return pinFailure == null
            ? Result.ok(
                _Docs(
                  ts,
                  sn,
                  tg,
                  tsEnvelope.sha256Hex,
                  snEnvelope.sha256Hex,
                  tgEnvelope.sha256Hex,
                ),
              )
            : Result.err(pinFailure);
    }
  }

  Future<Result<(T, SignedEnvelope), PackageFailure>>
  _role<T extends TufSigned>(
    MetadataRole name,
    List<int> file,
    _Root root,
  ) async {
    final SignedEnvelope envelope;
    switch (SignedEnvelope.parse(name, file)) {
      case Ok(:final value):
        envelope = value;
      case Err(:final failure):
        return Result.err(failure);
    }
    if (envelope.metadata.signed case final T doc) {
      final role = roleOf(root.doc, name);
      final failure = await checkThreshold(
        _ed25519,
        '${name.name}.json',
        envelope,
        root.keys,
        role.keyIds.toSet(),
        role.threshold,
      );
      return failure == null ? Result.ok((doc, envelope)) : Result.err(failure);
    }
    return Result.err(
      PackageFailure.signatureInvalid('${name.name}.json holds another role'),
    );
  }

  static PackageFailure? _regression(
    TrustedSequences received,
    TrustedSequences trusted,
  ) {
    final checks = [
      (
        MetadataRole.timestamp,
        received.timestamp,
        trusted.timestamp,
        _unchanged(received.timestampSha256, trusted.timestampSha256),
      ),
      (
        MetadataRole.snapshot,
        received.snapshot,
        trusted.snapshot,
        _unchanged(received.snapshotSha256, trusted.snapshotSha256),
      ),
      (
        MetadataRole.targets,
        received.targets,
        trusted.targets,
        _unchanged(received.targetsSha256, trusted.targetsSha256),
      ),
    ];
    for (final (role, sequence, trustedSequence, unchanged) in checks) {
      if (sequence < 1) {
        return PackageFailure.signatureInvalid(
          '${role.name}.json sequence $sequence',
        );
      }
      final equalAllowed = unchanged && sequence == trustedSequence;
      if (trustedSequence > 0 && sequence <= trustedSequence && !equalAllowed) {
        return PackageFailure.sequenceRegression(
          role: role,
          sequence: sequence,
          trusted: trustedSequence,
        );
      }
    }
    return null;
  }

  /// Whether a file hashing to [received] is the trusted one, [trusted].
  static bool _unchanged(String? received, String? trusted) =>
      trusted != null && received == trusted;

  static Result<List<FreshnessWarning>, PackageFailure> _freshness(
    TufRootSigned root,
    _Docs docs,
    int nowUtcMs,
  ) {
    final warnings = <FreshnessWarning>[];
    final roles = [
      (MetadataRole.root, root.expires),
      (MetadataRole.timestamp, docs.timestamp.expires),
      (MetadataRole.snapshot, docs.snapshot.expires),
      (MetadataRole.targets, docs.targets.expires),
    ];
    for (final (role, expires) in roles) {
      switch (parseExpires(role, expires)) {
        case Ok(:final value) when value <= nowUtcMs:
          warnings.add(FreshnessWarning(role: role, expiresUtcMs: value));
        case Ok():
          break;
        case Err(:final failure):
          return Result.err(failure);
      }
    }
    return Result.ok(List.unmodifiable(warnings));
  }
}

/// The verified root document and its keys by keyId.
final class _Root {
  const new(this.doc, this.keys);

  final TufRootSigned doc;
  final Map<String, List<int>> keys;
}

/// The three verified role documents and the hashes of their files.
final class _Docs {
  const new(
    this.timestamp,
    this.snapshot,
    this.targets,
    this.timestampSha256,
    this.snapshotSha256,
    this.targetsSha256,
  );

  final TufTimestampSigned timestamp;
  final TufSnapshotSigned snapshot;
  final TufTargetsSigned targets;
  final String timestampSha256;
  final String snapshotSha256;
  final String targetsSha256;
}
