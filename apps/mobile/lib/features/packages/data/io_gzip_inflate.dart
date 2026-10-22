import 'dart:io';

import 'package:dm_core_types/dm_core_types.dart';
import 'package:dm_packages/dm_packages.dart';

/// [InflatePayload] with `dart:io`'s gzip codec (§15 D63: the pure set
/// keeps the codec behind a port).
final class IoGzipInflate implements InflatePayload {
  /// The adapter.
  const new();

  @override
  Result<List<int>, PackageFailure> call(
    List<int> dmpkg, {
    required int maxBytes,
  }) {
    try {
      final payload = gzip.decode(dmpkg);
      if (payload.length > maxBytes) {
        return Result.err(
          PackageFailure.hashMismatch('payload exceeds $maxBytes bytes'),
        );
      }
      return Result.ok(payload);
    } on FormatException catch (error) {
      return Result.err(PackageFailure.hashMismatch(error.message));
    }
  }
}
