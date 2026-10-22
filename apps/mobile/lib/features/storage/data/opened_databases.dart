import 'package:daily_muslim/features/storage/data/dm_database.dart';
import 'package:daily_muslim/features/storage/data/places_database.dart';

/// Both database files, open and migrated.
final class OpenedDatabases {
  /// The pair.
  const new({
    required this.dm,
    required this.places,
    required this.placesExcludedFromBackup,
  });

  /// `dm.sqlite`.
  final DmDatabase dm;

  /// `places.sqlite`.
  final PlacesDatabase places;

  /// Whether the platform confirmed the backup exclusion of `places/`.
  final bool placesExcludedFromBackup;

  /// Closes both files.
  Future<void> close() async {
    await dm.close();
    await places.close();
  }
}
