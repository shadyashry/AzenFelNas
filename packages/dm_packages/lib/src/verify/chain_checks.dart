import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:dm_core_types/dm_core_types.dart';
import 'package:dm_packages/src/tuf/tuf_meta_ref.dart';
import 'package:dm_packages/src/tuf/tuf_role.dart';
import 'package:dm_packages/src/tuf/tuf_signed.dart';
import 'package:dm_packages/src/verify/hex.dart';
import 'package:dm_packages/src/verify/metadata_role.dart';
import 'package:dm_packages/src/verify/package_failure.dart';
import 'package:dm_packages/src/verify/signed_envelope.dart';
import 'package:dm_packages/src/verify/verify_ed25519.dart';

/// The Appendix C rules of a root document (REQ-DIST-001): three root keys
/// with threshold 2, threshold 1 for the other roles, distinct keys that the
/// root lists, and every keyId the SHA-256 of its key (§15 D17). Returns the
/// raw public keys by keyId.
Result<Map<String, List<int>>, PackageFailure> rootKeys(TufRootSigned root) {
  final keys = <String, List<int>>{};
  for (final MapEntry(key: id, value: key) in root.keys.entries) {
    final raw = hexBytes(key.public);
    if (raw == null ||
        raw.length != 32 ||
        sha256.convert(raw).toString() != id) {
      return Result.err(
        _malformed('root.json: key $id is not the SHA-256 of its key'),
      );
    }
    keys[id] = raw;
  }
  final roles = <(MetadataRole, TufRole)>[
    (MetadataRole.root, root.roles.root),
    (MetadataRole.targets, root.roles.targets),
    (MetadataRole.snapshot, root.roles.snapshot),
    (MetadataRole.timestamp, root.roles.timestamp),
  ];
  for (final (name, role) in roles) {
    final (wantThreshold, wantKeys) = name == MetadataRole.root
        ? (2, 3)
        : (1, null);
    final ids = role.keyIds.toSet();
    if (role.threshold != wantThreshold ||
        (wantKeys != null && role.keyIds.length != wantKeys) ||
        ids.length != role.keyIds.length ||
        ids.length < role.threshold ||
        !ids.every(keys.containsKey)) {
      return Result.err(
        _malformed('root.json: ${name.name} role breaks Appendix C'),
      );
    }
  }
  return Result.ok(keys);
}

/// The role entry of [name] in [root].
TufRole roleOf(TufRootSigned root, MetadataRole name) => switch (name) {
  MetadataRole.root => root.roles.root,
  MetadataRole.targets => root.roles.targets,
  MetadataRole.snapshot => root.roles.snapshot,
  MetadataRole.timestamp => root.roles.timestamp,
};

/// `null` when at least [threshold] distinct keys of [allowedIds] found in
/// [keys] have a valid signature on [envelope]; signatures by other keys
/// are ignored and a key counts once (REQ-DIST-001, REQ-DIST-004).
Future<PackageFailure?> checkThreshold(
  VerifyEd25519 ed25519,
  String label,
  SignedEnvelope envelope,
  Map<String, List<int>> keys,
  Set<String> allowedIds,
  int threshold,
) async {
  final valid = <String>{};
  for (final signature in envelope.metadata.signatures) {
    if (valid.length >= threshold) break;
    final key = keys[signature.keyId];
    if (key == null ||
        !allowedIds.contains(signature.keyId) ||
        valid.contains(signature.keyId)) {
      continue;
    }
    final sig = _base64(signature.sig);
    if (sig == null) continue;
    final ok = await ed25519(
      message: envelope.canonicalSigned,
      signature: sig,
      publicKey: key,
    );
    if (ok) valid.add(signature.keyId);
  }
  if (valid.length >= threshold && threshold >= 1) return null;
  return PackageFailure.signatureInvalid(
    '$label has ${valid.length} valid signature(s), needs $threshold',
  );
}

/// `null` when [envelope]'s bytes and [sequence] are what [pin] names.
PackageFailure? checkPinned(
  MetadataRole role,
  SignedEnvelope envelope,
  int sequence,
  TufMetaRef pin,
) {
  if (envelope.sha256Hex != pin.sha256 || sequence != pin.version) {
    return PackageFailure.hashMismatch(
      '${role.name}.json (${envelope.sha256Hex}, sequence $sequence) is not '
      'the one its parent pins (${pin.sha256}, sequence ${pin.version})',
    );
  }
  return null;
}

/// UTC epoch milliseconds of an `expires` value (`YYYY-MM-DDTHH:MM:SSZ`).
Result<int, PackageFailure> parseExpires(MetadataRole role, String expires) {
  if (!_expiresPattern.hasMatch(expires)) {
    return Result.err(_malformed('${role.name}.json: expires "$expires"'));
  }
  final parsed = DateTime.tryParse(expires);
  return parsed == null
      ? Result.err(_malformed('${role.name}.json: expires "$expires"'))
      : Result.ok(parsed.millisecondsSinceEpoch);
}

final RegExp _expiresPattern = RegExp(
  r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z$',
);

List<int>? _base64(String text) {
  try {
    return base64.decode(text);
  } on FormatException {
    return null; // an undecodable signature is simply not a valid one
  }
}

PackageFailure _malformed(String why) => PackageFailure.signatureInvalid(why);
