// The S09 done-test in Dart (§13 S09): metadata and a package that gsctl
// (Go) built and signed with the dev keys verify here; one flipped byte or a
// sequence regression fails. The vector is tools/gsctl/testdata/roundtrip.
import 'dart:convert';
import 'dart:io';

import 'package:dm_core_types/dm_core_types.dart';
import 'package:dm_packages/dm_packages.dart';
import 'package:test/test.dart';

const _vector = '../../tools/gsctl/testdata/roundtrip/dev';
const VerifyMetadataChain _verify = VerifyMetadataChain(CryptographyEd25519());
const int _day = 24 * 60 * 60 * 1000;

const String _strangerKeyId =
    '21fe31dfa154a261626bf854046fd2271b7bed4b6abe45aa58877ef47f9721b9';
const String _strangerKey =
    'd75a980182b10ab7d54bfed3c964073a0ee172f3daa62325af021a68f707511a';

List<int> _read(String path) => File('$_vector/$path').readAsBytesSync();

final MetadataFiles _files = MetadataFiles(
  root: _read('metadata/root.json'),
  timestamp: _read('metadata/timestamp.json'),
  snapshot: _read('metadata/snapshot.json'),
  targets: _read('metadata/targets.json'),
);

final TrustedRoot _devRoot = TrustedRoot.fromRootKeysJson(
  File('../../tools/gsctl/keys/dev/root-keys.json').readAsStringSync(),
);

/// A day before the vector's timestamp expires, read from the vector so the
/// test does not age.
final int _now = switch (jsonDecode(utf8.decode(_files.timestamp))) {
  {'signed': {'expires': final String expires}} =>
    DateTime.parse(expires).millisecondsSinceEpoch - _day,
  _ => throw const FormatException('timestamp.json has no expires'),
};

Future<Result<VerifiedMetadata, PackageFailure>> _run(
  MetadataFiles files, {
  TrustedSequences trusted = TrustedSequences.none,
  int? now,
  TrustedRoot? root,
}) => _verify(
  files: files,
  trustedRoot: root ?? _devRoot,
  trusted: trusted,
  nowUtcMs: now ?? _now,
);

VerifiedMetadata _ok(Result<VerifiedMetadata, PackageFailure> result) =>
    switch (result) {
      Ok(:final value) => value,
      Err(:final failure) => fail('verification failed: $failure'),
    };

FailureCode _code(Result<VerifiedMetadata, PackageFailure> result) =>
    switch (result) {
      Ok() => fail('verification succeeded'),
      Err(:final failure) => failure.code,
    };

MetadataFiles _with(MetadataRole role, List<int> bytes) => MetadataFiles(
  root: role == MetadataRole.root ? bytes : _files.root,
  timestamp: role == MetadataRole.timestamp ? bytes : _files.timestamp,
  snapshot: role == MetadataRole.snapshot ? bytes : _files.snapshot,
  targets: role == MetadataRole.targets ? bytes : _files.targets,
);

List<int> _bytesOf(MetadataRole role) => switch (role) {
  MetadataRole.root => _files.root,
  MetadataRole.timestamp => _files.timestamp,
  MetadataRole.snapshot => _files.snapshot,
  MetadataRole.targets => _files.targets,
};

void main() {
  group('Go-signed metadata verifies in Dart (REQ-DIST-001, REQ-DIST-004)', () {
    test('the dev chain and its package verify', () async {
      // Act
      final verified = _ok(await _run(_files));

      // Assert
      expect(
        verified.sequences,
        const TrustedSequences(timestamp: 1, snapshot: 1, targets: 1),
      );
      expect(verified.warnings, isEmpty);
      expect(verified.targets.targets.keys, ['prayer_profiles/2026.10.1']);
      final target = verified.targets.targets.values.single;
      final package = _read(
        'packages/prayer_profiles/2026.10.1/${target.sha256}.dmpkg',
      );
      expect(
        const VerifyTargetFile()('prayer_profiles/2026.10.1', target, package),
        Ok<TufTarget, PackageFailure>(target),
      );
    });

    // §15 D60: the payload is the JCS array gsctl wrote; Dart's
    // CanonicalJson reproduces it byte for byte, decimals included.
    test('the profiles.json payload is canonical in Dart too', () async {
      final verified = _ok(await _run(_files));
      final target = verified.targets.targets.values.single;
      final payload = gzip.decode(
        _read('packages/prayer_profiles/2026.10.1/${target.sha256}.dmpkg'),
      );
      final profiles = jsonDecode(utf8.decode(payload));

      expect(CanonicalJson.encode(profiles), utf8.decode(payload));
      expect(
        [
          if (profiles case final List<Object?> list)
            for (final p in list)
              if (p case {'profileId': final String id}) id,
        ],
        [
          'ae.awqaf.standard',
          'eg.egas.standard',
          'engine.default',
          'sa.ummalqura.standard',
        ],
      );
    });
  });

  group('a tampered byte fails (REQ-DIST-003, REQ-DIST-004)', () {
    // Go flips every bit of every file (trust_test.go); pure-Dart Ed25519
    // costs ~6 ms per check, so Dart flips evenly spaced bytes of each file.
    // The dev root carries all three root signatures and needs two, so one
    // broken root signature is tolerated by design: root bytes are sampled
    // before its signatures, which the threshold test below covers.
    for (final role in MetadataRole.values) {
      test('${role.name}.json', () async {
        final original = _bytesOf(role);
        final end = role == MetadataRole.root
            ? utf8.decode(original).indexOf('"signatures"')
            : original.length;
        final step = (end / 24).ceil();
        for (var i = 0; i < end; i += step) {
          final changed = [...original]..[i] ^= 0x01;
          expect(
            _code(await _run(_with(role, changed))),
            anyOf(FailureCode.pkgSigInvalid, FailureCode.pkgHashMismatch),
            reason: 'byte $i of ${role.name}.json',
          );
        }
      });
    }

    test(
      'root.json needs two of its three signatures (REQ-DIST-001)',
      () async {
        List<int> breaking(int count) {
          final (root, entries) = switch (jsonDecode(
            utf8.decode(_files.root),
          )) {
            final Map<String, Object?> root => switch (root['signatures']) {
              final List<Object?> entries => (root, entries),
              _ => throw const FormatException('root.json has no signatures'),
            },
            _ => throw const FormatException('root.json is not an object'),
          };
          final signatures = [
            for (final (i, s) in entries.indexed)
              switch (s) {
                {'keyId': final String id, 'sig': final String sig} => {
                  'keyId': id,
                  'sig': i < count
                      ? sig.replaceRange(0, 1, sig[0] == 'A' ? 'B' : 'A')
                      : sig,
                },
                _ => throw FormatException('signature $s'),
              },
          ];
          return utf8.encode(jsonEncode({...root, 'signatures': signatures}));
        }

        expect(
          await _run(_with(MetadataRole.root, breaking(1))),
          isA<Ok<VerifiedMetadata, PackageFailure>>(),
        );
        expect(
          _code(await _run(_with(MetadataRole.root, breaking(2)))),
          FailureCode.pkgSigInvalid,
        );
      },
    );

    test('a reformatted targets.json breaks the snapshot pin', () async {
      final compact = utf8.encode(
        jsonEncode(jsonDecode(utf8.decode(_files.targets))),
      );
      expect(
        _code(await _run(_with(MetadataRole.targets, compact))),
        FailureCode.pkgHashMismatch,
      );
    });

    test('any changed package byte fails its target', () async {
      final target = _ok(await _run(_files)).targets.targets.values.single;
      final package = _read(
        'packages/prayer_profiles/2026.10.1/${target.sha256}.dmpkg',
      );
      for (var i = 0; i < package.length; i++) {
        final changed = [...package]..[i] ^= 0x80;
        expect(
          const VerifyTargetFile()('p', target, changed),
          isA<Err<TufTarget, PackageFailure>>(),
          reason: 'byte $i',
        );
      }
    });

    test('a root the trusted keys did not sign fails', () async {
      final stranger = TrustedRoot(
        // RFC 8032 §7.1 test 1 public key: not a dev root key.
        publicKeysById: const {_strangerKeyId: _strangerKey},
        threshold: 1,
      );
      expect(
        _code(await _run(_files, root: stranger)),
        FailureCode.pkgSigInvalid,
      );
    });
  });

  group('sequence regression is rejected (REQ-PKG-005, REQ-DIST-002)', () {
    final cases = {
      MetadataRole.timestamp: const TrustedSequences(timestamp: 1),
      MetadataRole.snapshot: const TrustedSequences(snapshot: 1),
      MetadataRole.targets: const TrustedSequences(targets: 2),
    };
    for (final MapEntry(key: role, value: trusted) in cases.entries) {
      test('${role.name} not after the trusted sequence', () async {
        final result = await _run(_files, trusted: trusted);
        expect(
          result,
          isA<Err<VerifiedMetadata, PackageFailure>>().having(
            (e) => e.failure,
            'failure',
            isA<PackageSequenceRegression>()
                .having((f) => f.role, 'role', role)
                .having(
                  (f) => f.code,
                  'code',
                  FailureCode.pkgSequenceRegression,
                ),
          ),
        );
      });
    }
  });

  test('expired metadata warns and still verifies (REQ-PKG-002)', () async {
    final verified = _ok(await _run(_files, now: _now + 2 * _day));

    expect(verified.warnings.map((w) => w.role), [MetadataRole.timestamp]);
    expect(FreshnessWarning.code, FailureCode.pkgExpiredWarning);
  });
}
