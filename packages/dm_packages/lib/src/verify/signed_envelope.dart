import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:dm_core_types/dm_core_types.dart';
import 'package:dm_packages/src/tuf/tuf_metadata.dart';
import 'package:dm_packages/src/verify/metadata_role.dart';
import 'package:dm_packages/src/verify/package_failure.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

/// One decoded metadata file: the typed envelope, the canonical bytes its
/// signatures cover and the SHA-256 of the file's exact bytes.
@immutable
final class SignedEnvelope {
  const new _(this.metadata, this.canonicalSigned, this.sha256Hex);

  /// Decodes [file] as [role]'s metadata. Signatures cover the JCS form of
  /// the file's own `signed` member, not of a re-encoded model
  /// (REQ-DIST-004).
  static Result<SignedEnvelope, PackageFailure> parse(
    MetadataRole role,
    List<int> file,
  ) {
    try {
      final (envelope, signed) = switch (jsonDecode(
        utf8.decode(file),
        reviver: _finiteNumbersOnly,
      )) {
        final Map<String, Object?> envelope => switch (envelope['signed']) {
          final Map<String, Object?> signed => (envelope, signed),
          _ => throw const FormatException('no signed object'),
        },
        _ => throw const FormatException('not a JSON object'),
      };
      return Result.ok(
        SignedEnvelope._(
          TufMetadata.fromJson(envelope),
          utf8.encode(CanonicalJson.encode(signed)),
          sha256.convert(file).toString(),
        ),
      );
    } on FormatException catch (e) {
      return Result.err(_malformed(role, e.message));
    } on CheckedFromJsonException catch (e) {
      return Result.err(_malformed(role, '${e.key}: ${e.message}'));
    }
  }

  /// JSON numbers beyond the double range decode to infinity, which RFC 8785
  /// cannot write; they are malformed metadata.
  static Object? _finiteNumbersOnly(Object? key, Object? value) =>
      value is double && !value.isFinite
      ? throw FormatException('number out of range at $key')
      : value;

  /// The typed envelope.
  final TufMetadata metadata;

  /// UTF-8 of JCS(`signed`), what each signature signs.
  final List<int> canonicalSigned;

  /// Lowercase hex SHA-256 of the file as read.
  final String sha256Hex;

  static PackageFailure _malformed(MetadataRole role, String why) =>
      PackageFailure.signatureInvalid('${role.name}.json is malformed: $why');
}
