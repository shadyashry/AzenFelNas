import 'package:daily_muslim/features/quran/domain/build_search_index.dart';
import 'package:daily_muslim/features/quran/domain/highlight.dart';
import 'package:daily_muslim/features/quran/domain/mushaf_index_entries.dart';
import 'package:daily_muslim/features/quran/domain/quran_edition_pin.dart';
import 'package:daily_muslim/features/quran/domain/quran_notes.dart';
import 'package:daily_muslim/features/quran/domain/quran_origin.dart';
import 'package:daily_muslim/features/quran/domain/quran_package_disk.dart';
import 'package:daily_muslim/features/quran/domain/quran_package_status.dart';
import 'package:daily_muslim/features/quran/domain/read_mushaf_index.dart';
import 'package:daily_muslim/features/quran/presentation/quran_format.dart';
import 'package:daily_muslim/features/quran/presentation/quran_package_controller.dart';
import 'package:dm_core_types/dm_core_types.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The package on disk, bound in `app/di.dart`.
final quranPackageDiskProvider = Provider<QuranPackageDisk>(
  (ref) => throw UnimplementedError('bound in app/di.dart'),
);

/// The CDN, bound in `app/di.dart`; only the download uses it.
final quranOriginProvider = Provider<QuranOrigin>(
  (ref) => throw UnimplementedError('bound in app/di.dart'),
);

/// Free space, bound in `app/di.dart`.
final readFreeSpaceProvider = Provider<ReadFreeSpace>(
  (ref) => throw UnimplementedError('bound in app/di.dart'),
);

/// The search index builder, bound in `app/di.dart`.
final buildSearchIndexProvider = Provider<BuildSearchIndex>(
  (ref) => throw UnimplementedError('bound in app/di.dart'),
);

/// Whether a package directory holds a current search index, bound in
/// `app/di.dart`.
final searchIndexIsCurrentProvider = Provider<bool Function(String)>(
  (ref) => throw UnimplementedError('bound in app/di.dart'),
);

/// Opens the index of a package directory, bound in `app/di.dart`.
final openMushafIndexProvider = Provider<ReadMushafIndex Function(String)>(
  (ref) => throw UnimplementedError('bound in app/di.dart'),
);

/// Bookmarks, bound in `app/di.dart`.
final bookmarkStoreProvider = Provider<BookmarkStore>(
  (ref) => throw UnimplementedError('bound in app/di.dart'),
);

/// Highlights, bound in `app/di.dart`.
final highlightStoreProvider = Provider<HighlightStore>(
  (ref) => throw UnimplementedError('bound in app/di.dart'),
);

/// The last page read, bound in `app/di.dart`.
final readingPositionStoreProvider = Provider<ReadingPositionStore>(
  (ref) => throw UnimplementedError('bound in app/di.dart'),
);

/// The reader's choices, bound in `app/di.dart`.
final readerPreferencesStoreProvider = Provider<ReaderPreferencesStore>(
  (ref) => throw UnimplementedError('bound in app/di.dart'),
);

/// The package status and its actions.
final NotifierProvider<QuranPackageController, QuranPackageStatus>
quranPackageProvider =
    NotifierProvider<QuranPackageController, QuranPackageStatus>(
      QuranPackageController.new,
    );

/// The index of the active package; `null` until it is ready.
final Provider<ReadMushafIndex?> mushafIndexProvider = Provider((ref) {
  final status = ref.watch(quranPackageProvider);
  if (status is! QuranReady) return null;
  final index = ref.read(openMushafIndexProvider)(status.installed.directory);
  ref.onDispose(index.close);
  return index;
});

/// The 114 surahs of the active package.
final FutureProvider<List<SuraEntry>> surasProvider = FutureProvider((
  ref,
) async {
  final index = ref.watch(mushafIndexProvider);
  if (index == null) return const [];
  return switch (await index.suras()) {
    Ok(:final value) => value,
    Err() => const [],
  };
});

/// The 30 juz of the active package.
final FutureProvider<List<JuzEntry>> juzProvider = FutureProvider((
  ref,
) async {
  final index = ref.watch(mushafIndexProvider);
  if (index == null) return const [];
  return switch (await index.juz()) {
    Ok(:final value) => value,
    Err() => const [],
  };
});

/// Bookmarks of the pinned layout, newest first.
final StreamProvider<List<Bookmark>> bookmarksProvider = StreamProvider(
  (ref) =>
      ref.watch(bookmarkStoreProvider).watchBookmarks(QuranEditionPin.layoutId),
);

/// Highlights of the pinned layout, in Mushaf order.
final StreamProvider<List<Highlight>> highlightsProvider = StreamProvider(
  (ref) => ref
      .watch(highlightStoreProvider)
      .watchHighlights(QuranEditionPin.layoutId),
);

/// Whether the package's KFGQPC font is registered (once per package).
final FutureProvider<bool> quranFontProvider = FutureProvider((ref) async {
  final status = ref.watch(quranPackageProvider);
  if (status is! QuranReady) return false;
  return QuranFont.load(status.installed);
});
