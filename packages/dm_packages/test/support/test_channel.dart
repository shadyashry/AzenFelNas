import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:cryptography/cryptography.dart';
import 'package:dm_core_types/dm_core_types.dart';
import 'package:dm_packages/dm_packages.dart';

/// One signing key of the test channel: ephemeral, generated per test run
/// (never the dev keys).
final class TestKey {
  const new _(this.id, this.publicHex, this._pair);

  /// A fresh Ed25519 key.
  static Future<TestKey> generate() async {
    final pair = await _ed25519.newKeyPair();
    final public = (await pair.extractPublicKey()).bytes;
    return TestKey._(
      sha256.convert(public).toString(),
      _hex(public),
      pair,
    );
  }

  /// keyId: SHA-256 of the raw public key (§15 D17).
  final String id;

  /// Lowercase hex of the raw public key.
  final String publicHex;

  final SimpleKeyPair _pair;

  Future<Map<String, Object?>> sign(List<int> message) async {
    final signature = await _ed25519.sign(message, keyPair: _pair);
    return {'keyId': id, 'sig': base64.encode(signature.bytes)};
  }

  static final Ed25519 _ed25519 = Ed25519();
}

/// A published target in the test channel.
final class TestTarget {
  const new({required this.custom, required this.dmpkg});

  final Map<String, Object?> custom;
  final List<int> dmpkg;
}

/// A complete TUF-lite channel signed with ephemeral keys (Appendix C), to
/// drive the client end to end without the dev keys or the network.
final class TestChannel {
  new _(this._rootKeys, this._roleKey)
    : embeddedRoot = TrustedRoot(
        publicKeysById: {for (final k in _rootKeys) k.id: k.publicHex},
        threshold: 2,
      );

  /// A channel with three fresh root keys (threshold 2) and one key for the
  /// other roles.
  static Future<TestChannel> create() async => TestChannel._(
    [for (var i = 0; i < 3; i++) await TestKey.generate()],
    await TestKey.generate(),
  );

  List<TestKey> _rootKeys;
  List<TestKey> _signingRootKeys = const [];
  final TestKey _roleKey;
  int rootVersion = 1;

  /// Published targets by name, as `targets.json` will list them.
  final Map<String, TestTarget> targets = {};

  /// The root keys an app built against this channel embeds: the first
  /// root's, whatever rotations follow.
  final TrustedRoot embeddedRoot;

  /// Publishes [payload] as [type] [version].
  void publish(
    PackageType type,
    String version,
    List<int> payload, {
    String effectiveFrom = '2026-01-01',
    String priority = 'normal',
    String minApp = '0.1.0',
    int schemaVersion = 1,
    int minEngineSchema = 1,
    String? rollbackOf,
  }) {
    targets['${type.wire}/$version'] = TestTarget(
      dmpkg: gzip.encode(payload),
      custom: {
        'schemaVersion': schemaVersion,
        'payloadFormat': 'json',
        'compat': {'minApp': minApp, 'minEngineSchema': minEngineSchema},
        'effectiveFrom': effectiveFrom,
        'priority': priority,
        'changeNote': {'ar': 'تحديث', 'en': 'Update'},
        'rollbackOf': ?rollbackOf,
      },
    );
  }

  /// Replaces the root keys: the next root is signed by two old keys and two
  /// new ones (Appendix C rotation).
  Future<void> rotateRoot() async {
    _signingRootKeys = _rootKeys;
    _rootKeys = [for (var i = 0; i < 3; i++) await TestKey.generate()];
    rootVersion += 1;
  }

  /// Signs later roots with the current root keys only.
  void retireOldRootKeys() => _signingRootKeys = const [];

  /// The four metadata files, every role at [sequence], expiring at
  /// [expires].
  Future<Map<MetadataRole, List<int>>> sign({
    required int sequence,
    String expires = '2099-01-01T00:00:00Z',
  }) async {
    final role = {
      'keyIds': [_roleKey.id],
      'threshold': 1,
    };
    final root = await _envelope(
      {
        'type': 'root',
        'version': rootVersion,
        'expires': expires,
        'keys': {
          for (final k in [..._rootKeys, _roleKey])
            k.id: {'scheme': 'ed25519', 'public': k.publicHex},
        },
        'roles': {
          'root': {
            'keyIds': [for (final k in _rootKeys) k.id],
            'threshold': 2,
          },
          'targets': role,
          'snapshot': role,
          'timestamp': role,
        },
      },
      [..._signingRootKeys.take(2), ..._rootKeys.take(2)],
    );
    final targetsFile = await _envelope(
      {
        'type': 'targets',
        'sequence': sequence,
        'expires': expires,
        'targets': {
          for (final MapEntry(key: name, value: t) in targets.entries)
            name: {
              'length': t.dmpkg.length,
              'sha256': sha256.convert(t.dmpkg).toString(),
              'custom': t.custom,
            },
        },
      },
      [_roleKey],
    );
    final snapshot = await _envelope(
      _pinning('snapshot', sequence, expires, 'targets.json', targetsFile),
      [_roleKey],
    );
    final timestamp = await _envelope(
      _pinning('timestamp', sequence, expires, 'snapshot.json', snapshot),
      [_roleKey],
    );
    return {
      MetadataRole.root: root,
      MetadataRole.targets: targetsFile,
      MetadataRole.snapshot: snapshot,
      MetadataRole.timestamp: timestamp,
    };
  }

  static Map<String, Object?> _pinning(
    String type,
    int sequence,
    String expires,
    String pinned,
    List<int> file,
  ) => {
    'type': type,
    'sequence': sequence,
    'expires': expires,
    'meta': {
      pinned: {'version': sequence, 'sha256': sha256.convert(file).toString()},
    },
  };

  static Future<List<int>> _envelope(
    Map<String, Object?> signed,
    List<TestKey> keys,
  ) async {
    final message = utf8.encode(CanonicalJson.encode(signed));
    return utf8.encode(
      jsonEncode({
        'signed': signed,
        'signatures': [for (final k in keys) await k.sign(message)],
      }),
    );
  }
}

String _hex(List<int> bytes) =>
    bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
