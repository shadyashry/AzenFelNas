import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:daily_muslim/features/quran/domain/quran_edition_pin.dart';
import 'package:daily_muslim/features/quran/domain/quran_manifest.dart';
import 'package:daily_muslim/features/quran/domain/quran_manifest_file.dart';
import 'package:daily_muslim/features/quran/domain/quran_page_geometry.dart';
import 'package:dm_contracts/dm_contracts.dart';
import 'package:json_annotation/json_annotation.dart';

/// Reads `manifest.json` (`quran_package.v1`, §15 D106) into the domain's
/// [QuranManifest].
abstract final class QuranManifestCodec {
  /// [bytes] decoded, or `null` when they do not have the schema's shape.
  static QuranManifest? decode(List<int> bytes) {
    try {
      final wire = switch (jsonDecode(utf8.decode(bytes))) {
        final Map<String, Object?> json => QuranPackageManifest.fromJson(json),
        _ => null,
      };
      if (wire == null) return null;
      return QuranManifest(
        packageId: wire.packageId,
        version: wire.version,
        layoutId: wire.layoutId,
        printEdition: wire.edition.printEdition,
        pageCount: wire.edition.pageCount,
        pageImage: QuranPageGeometry(
          width: wire.pageImage.width,
          height: wire.pageImage.height,
          pathPattern: wire.pageImage.pathPattern,
        ),
        files: [
          for (final f in wire.files)
            QuranManifestFile(path: f.path, bytes: f.bytes, sha256: f.sha256),
        ],
      );
    } on FormatException {
      return null;
    } on CheckedFromJsonException {
      return null;
    }
  }

  /// [bytes] decoded when they are the manifest this build pins (size and
  /// SHA-256) of the pinned package: every page present once and every path
  /// inside the package (REQ-QRN-011).
  static QuranManifest? acceptPinned(List<int> bytes) {
    if (bytes.length != QuranEditionPin.manifestBytes ||
        sha256.convert(bytes).toString() != QuranEditionPin.manifestSha256) {
      return null;
    }
    final manifest = decode(bytes);
    if (manifest == null) return null;
    final paths = manifest.files.map((f) => f.path).toSet();
    const pages = QuranEditionPin.layout;
    final ok =
        manifest.packageId == QuranEditionPin.packageId &&
        manifest.version == QuranEditionPin.version &&
        manifest.layoutId == QuranEditionPin.layoutId &&
        manifest.pageCount == pages.pageCount &&
        paths.length == manifest.files.length &&
        paths.every(_safePath.hasMatch) &&
        paths.contains('quran.sqlite') &&
        [
          for (var p = 1; p <= pages.pageCount; p++)
            manifest.pageImage.pathOf(p),
        ].every(paths.contains);
    return ok ? manifest : null;
  }

  static final _safePath = RegExp(
    r'^[a-z0-9][a-z0-9_.-]*(/[a-z0-9_-][a-z0-9_.-]*)*$',
  );
}
