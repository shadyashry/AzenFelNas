import 'dart:async';

import 'package:daily_muslim/features/quran/domain/highlight.dart';
import 'package:daily_muslim/features/quran/domain/highlight_color.dart';
import 'package:daily_muslim/features/quran/domain/quran_edition_pin.dart';
import 'package:daily_muslim/features/quran/domain/reader_preferences.dart';
import 'package:daily_muslim/features/quran/domain/verse_place.dart';
import 'package:daily_muslim/features/quran/presentation/quran_providers.dart';
import 'package:daily_muslim/features/schedule/presentation/schedule_providers.dart';
import 'package:dm_core_types/dm_core_types.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';

/// A highlight being drawn: its colour and the areas so far, possibly on
/// several pages.
@immutable
final class HighlightDraft {
  /// The draft.
  const new({required this.color, this.regions = const []});

  /// Colour.
  final HighlightColor color;

  /// Areas drawn so far, in drawing order.
  final List<HighlightRegion> regions;
}

/// What the reader shows (§15 D107).
@immutable
final class ReaderState {
  /// The state.
  const new({
    required this.page,
    required this.restored,
    this.chromeVisible = true,
    this.preferences = const ReaderPreferences(),
    this.showHighlights = true,
    this.draft,
    this.mark,
  });

  /// The current page (the right page of a spread).
  final int page;

  /// Whether the last position and preferences were read.
  final bool restored;

  /// Whether the bars and buttons are shown.
  final bool chromeVisible;

  /// Fit and facing pages.
  final ReaderPreferences preferences;

  /// Whether saved highlights are drawn; off shows the pages untouched.
  final bool showHighlights;

  /// The highlight being drawn, or `null` outside drawing mode.
  final HighlightDraft? draft;

  /// The verse whose lines are outlined for a moment after it was opened
  /// from search, the index or the ayahs sheet (§15 D114); `null` most of
  /// the time.
  final VersePlace? mark;

  ReaderState _with({
    int? page,
    bool? restored,
    bool? chromeVisible,
    ReaderPreferences? preferences,
    bool? showHighlights,
    HighlightDraft? Function()? draft,
    VersePlace? Function()? mark,
  }) => ReaderState(
    page: page ?? this.page,
    restored: restored ?? this.restored,
    chromeVisible: chromeVisible ?? this.chromeVisible,
    preferences: preferences ?? this.preferences,
    showHighlights: showHighlights ?? this.showHighlights,
    draft: draft == null ? this.draft : draft(),
    mark: mark == null ? this.mark : mark(),
  );
}

/// The reader's page, chrome, preferences and highlight drawing; saves the
/// page as it changes so the last position is restored after a restart
/// (REQ-QRN-021).
final class ReaderController extends Notifier<ReaderState> {
  Timer? _save;
  Timer? _unmark;

  /// How long an opened verse stays outlined.
  static const markFor = Duration(seconds: 4);

  @override
  ReaderState build() {
    ref.onDispose(() {
      _save?.cancel();
      _unmark?.cancel();
    });
    unawaited(_restore());
    return const ReaderState(page: 1, restored: false);
  }

  Future<void> _restore() async {
    final page = await ref
        .read(readingPositionStoreProvider)
        .readPosition(QuranEditionPin.layoutId);
    final preferences = await ref
        .read(readerPreferencesStoreProvider)
        .readPreferences();
    if (!ref.mounted) return;
    state = state._with(
      page: QuranEditionPin.layout.clamp(page ?? state.page),
      restored: true,
      preferences: preferences,
    );
  }

  /// Shows [page] (clamped to the Mushaf) and saves it shortly after.
  void goTo(int page) {
    final clamped = QuranEditionPin.layout.clamp(page);
    if (clamped == state.page && state.restored) return;
    state = state._with(page: clamped, restored: true);
    _save?.cancel();
    _save = Timer(const Duration(milliseconds: 400), () {
      unawaited(
        ref
            .read(readingPositionStoreProvider)
            .writePosition(
              QuranEditionPin.layoutId,
              clamped,
              nowUtcMs: ref.read(clockProvider).nowUtcMs(),
            ),
      );
    });
  }

  /// Opens the page of [place] and outlines its lines for [markFor]
  /// (§15 D114); the outline is drawn over the page, never into it.
  void showVerse(VersePlace place) {
    goTo(place.page);
    state = state._with(mark: () => place);
    _unmark?.cancel();
    _unmark = Timer(markFor, () {
      if (ref.mounted) state = state._with(mark: () => null);
    });
  }

  /// Opens verse [aya] of [sura] as [showVerse] does; when the package
  /// cannot place it, opens [fallbackPage] without an outline.
  Future<void> showVerseAt(
    int sura,
    int aya, {
    required int fallbackPage,
  }) async {
    final places = ref.read(versePlacesProvider);
    final place = places == null
        ? null
        : switch (await places.verse(sura, aya)) {
            Ok(:final value) => value,
            Err() => null,
          };
    if (!ref.mounted) return;
    if (place == null) {
      goTo(fallbackPage);
    } else {
      showVerse(place);
    }
  }

  /// Shows or hides the bars.
  void toggleChrome() =>
      state = state._with(chromeVisible: !state.chromeVisible);

  /// Saves and applies [preferences].
  void setPreferences(ReaderPreferences preferences) {
    state = state._with(preferences: preferences);
    unawaited(
      ref.read(readerPreferencesStoreProvider).writePreferences(preferences),
    );
  }

  /// Shows or hides saved highlights.
  void toggleHighlights() =>
      state = state._with(showHighlights: !state.showHighlights);

  /// Enters drawing mode with [color].
  void startDraft(HighlightColor color) => state = state._with(
    draft: () => HighlightDraft(color: color),
    chromeVisible: true,
    showHighlights: true,
  );

  /// Adds an area to the draft.
  void addRegion(HighlightRegion region) {
    final draft = state.draft;
    if (draft == null) return;
    state = state._with(
      draft: () => HighlightDraft(
        color: draft.color,
        regions: [...draft.regions, region],
      ),
    );
  }

  /// Removes the last area of the draft.
  void undoRegion() {
    final draft = state.draft;
    if (draft == null || draft.regions.isEmpty) return;
    state = state._with(
      draft: () => HighlightDraft(
        color: draft.color,
        regions: draft.regions.sublist(0, draft.regions.length - 1),
      ),
    );
  }

  /// Changes the draft's colour.
  void setDraftColor(HighlightColor color) {
    final draft = state.draft;
    if (draft == null) return;
    state = state._with(
      draft: () => HighlightDraft(color: color, regions: draft.regions),
    );
  }

  /// Saves the draft as one highlight (if it has an area) and leaves
  /// drawing mode.
  Future<void> saveDraft() async {
    final draft = state.draft;
    state = state._with(draft: () => null);
    if (draft == null || draft.regions.isEmpty) return;
    await ref
        .read(highlightStoreProvider)
        .addHighlight(
          QuranEditionPin.layoutId,
          draft.color,
          draft.regions,
          nowUtcMs: ref.read(clockProvider).nowUtcMs(),
        );
  }

  /// Leaves drawing mode without saving.
  void cancelDraft() => state = state._with(draft: () => null);
}

/// The reader state, for the life of the app.
final NotifierProvider<ReaderController, ReaderState> readerProvider =
    NotifierProvider<ReaderController, ReaderState>(ReaderController.new);
