import 'package:daily_muslim/features/quran/domain/ayah_highlight.dart';
import 'package:daily_muslim/features/quran/domain/build_search_index.dart';
import 'package:daily_muslim/features/quran/domain/highlight.dart';
import 'package:daily_muslim/features/quran/domain/highlight_color.dart';
import 'package:daily_muslim/features/quran/domain/mushaf_index_entries.dart';
import 'package:daily_muslim/features/quran/domain/mushaf_lines.dart';
import 'package:daily_muslim/features/quran/domain/quran_edition_pin.dart';
import 'package:daily_muslim/features/quran/domain/quran_manifest.dart';
import 'package:daily_muslim/features/quran/domain/quran_notes.dart';
import 'package:daily_muslim/features/quran/domain/quran_origin.dart';
import 'package:daily_muslim/features/quran/domain/quran_package_disk.dart';
import 'package:daily_muslim/features/quran/domain/quran_package_status.dart';
import 'package:daily_muslim/features/quran/domain/read_mushaf_index.dart';
import 'package:daily_muslim/features/quran/domain/read_verse_places.dart';
import 'package:daily_muslim/features/quran/domain/verse_place.dart';
import 'package:daily_muslim/features/quran/presentation/quran_format.dart';
import 'package:daily_muslim/features/quran/presentation/quran_package_controller.dart';
import 'package:dm_core_types/dm_core_types.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';

/// The package on disk, bound in `app/di.dart`.
final quranPackageDiskProvider = Provider<QuranPackageDisk>(
  (ref) => throw UnimplementedError('bound in app/di.dart'),
);

/// The CDN, bound in `app/di.dart`; only the download uses it.
final quranOriginProvider = Provider<QuranOrigin>(
  (ref) => throw UnimplementedError('bound in app/di.dart'),
);

/// Accepts the downloaded manifest when it is the pinned one, bound in
/// `app/di.dart`.
final acceptManifestProvider = Provider<QuranManifest? Function(List<int>)>(
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

/// Opens the verse placements of a package directory, bound in
/// `app/di.dart`.
final openVersePlacesProvider = Provider<ReadVersePlaces Function(String)>(
  (ref) => throw UnimplementedError('bound in app/di.dart'),
);

/// Verse highlights, bound in `app/di.dart`.
final ayahHighlightStoreProvider = Provider<AyahHighlightStore>(
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
  final installed = readablePackage(ref.watch(quranPackageProvider));
  if (installed == null) return null;
  final index = ref.read(openMushafIndexProvider)(installed.directory);
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
  final installed = readablePackage(ref.watch(quranPackageProvider));
  if (installed == null) return false;
  return await QuranFont.load(installed);
});

/// The page the reader was last left on, for Home's "Continue Quran"
/// (§15 D108); `null` before the first read. Re-read each time Home is
/// built, so it follows the reader.
final FutureProvider<int?> lastQuranPageProvider = FutureProvider.autoDispose(
  (ref) => ref
      .watch(readingPositionStoreProvider)
      .readPosition(QuranEditionPin.layoutId),
);

/// The download's status as a plain value, for screens outside the Quran
/// tab that only read it (Home's "Continue Quran", §15 D108).
final Provider<QuranPackageStatus> quranStatusProvider = Provider(
  (ref) => ref.watch(quranPackageProvider),
);

/// Where verses stand in the active package; `null` until it is ready
/// (§15 D111).
final Provider<ReadVersePlaces?> versePlacesProvider = Provider((ref) {
  final installed = readablePackage(ref.watch(quranPackageProvider));
  if (installed == null) return null;
  final places = ref.read(openVersePlacesProvider)(installed.directory);
  ref.onDispose(places.close);
  return places;
});

/// The verses that touch a page, in Mushaf order; empty while the package
/// is not ready.
final FutureProviderFamily<List<VersePlace>, int> versesOnPageProvider =
    FutureProvider.family<List<VersePlace>, int>((
      ref,
      page,
    ) async {
      final places = ref.watch(versePlacesProvider);
      if (places == null) return const [];
      return switch (await places.versesOnPage(page)) {
        Ok(:final value) => value,
        Err() => const [],
      };
    });

/// The verse highlights of the pinned layout, in Mushaf order.
final StreamProvider<List<AyahHighlight>> ayahHighlightsProvider =
    StreamProvider(
      (ref) => ref
          .watch(ayahHighlightStoreProvider)
          .watchAyahHighlights(QuranEditionPin.layoutId),
    );

/// The verse highlights as bands over the lines each verse is on, by page
/// (§15 D111). Only the measured layout has line geometry.
final FutureProvider<Map<int, List<(HighlightRegion, HighlightColor)>>>
ayahRegionsProvider = FutureProvider((ref) async {
  final highlights =
      ref.watch(ayahHighlightsProvider).value ?? const <AyahHighlight>[];
  final places = ref.watch(versePlacesProvider);
  final map = <int, List<(HighlightRegion, HighlightColor)>>{};
  if (places == null || QuranEditionPin.layoutId != MushafLines.layoutId) {
    return map;
  }
  for (final h in highlights) {
    final place = switch (await places.verse(h.sura, h.aya)) {
      Ok(:final value) => value,
      Err() => null,
    };
    if (place == null) continue;
    for (final (:page, :line) in place.lines(MushafLines.linesOn)) {
      final band = MushafLines.band(page, line);
      if (band != null) (map[page] ??= []).add((band, h.color));
    }
  }
  return map;
});
