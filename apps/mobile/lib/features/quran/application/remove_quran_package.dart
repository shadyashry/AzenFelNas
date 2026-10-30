import 'package:daily_muslim/features/quran/domain/quran_failure.dart';
import 'package:daily_muslim/features/quran/domain/quran_package_disk.dart';
import 'package:dm_core_types/dm_core_types.dart';

/// Removes the downloaded Quran package and any partial download
/// (§15 D107, REQ-QRN-061). Bookmarks, highlights and the last page read
/// live in `quran_notes.sqlite` and are kept; they show again once the same
/// page layout is downloaded.
final class RemoveQuranPackage {
  /// The use case over [_disk].
  const new(this._disk);

  final QuranPackageDisk _disk;

  /// Removes everything downloaded.
  Future<Result<void, QuranFailure>> call() => _disk.removeAll();
}
