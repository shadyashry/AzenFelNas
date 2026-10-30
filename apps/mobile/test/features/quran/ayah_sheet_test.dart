import 'dart:async';

import 'package:daily_muslim/features/quran/domain/ayah_highlight.dart';
import 'package:daily_muslim/features/quran/domain/highlight_color.dart';
import 'package:daily_muslim/features/quran/domain/mushaf_index_entries.dart';
import 'package:daily_muslim/features/quran/domain/verse_place.dart';
import 'package:daily_muslim/features/quran/presentation/ayah_sheet.dart';
import 'package:daily_muslim/features/quran/presentation/quran_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/state_harness.dart';

const _kursi = VersePlace(
  sura: 2,
  aya: 255,
  page: 42,
  lineStart: 7,
  pageEnd: 42,
  lineEnd: 14,
  text: 'ٱللَّهُ لَآ إِلَٰهَ إِلَّا هُوَ',
);

const _baqarah = SuraEntry(
  number: 2,
  header: 'سُورَةُ البَقَرَةِ',
  startPage: 2,
  verseCount: 286,
);

/// Keeps verse highlights in memory and replays them to watchers.
final class _FakeStore implements AyahHighlightStore {
  final _rows = <(int, int), AyahHighlight>{};
  final _changes = StreamController<List<AyahHighlight>>.broadcast();

  List<AyahHighlight> get rows => _rows.values.toList();

  @override
  Stream<List<AyahHighlight>> watchAyahHighlights(String layoutId) async* {
    yield rows;
    yield* _changes.stream;
  }

  @override
  Future<void> setAyahHighlight(
    String layoutId,
    int sura,
    int aya,
    HighlightColor color, {
    required int nowUtcMs,
  }) async {
    _rows[(sura, aya)] = AyahHighlight(
      layoutId: layoutId,
      sura: sura,
      aya: aya,
      color: color,
      createdUtcMs: nowUtcMs,
      updatedUtcMs: nowUtcMs,
    );
    _changes.add(rows);
  }

  @override
  Future<void> removeAyahHighlight(String layoutId, int sura, int aya) async {
    _rows.remove((sura, aya));
    _changes.add(rows);
  }
}

Future<_FakeStore> _open(WidgetTester tester) async {
  final store = _FakeStore();
  await tester.pumpWidget(
    localizedApp(
      Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => showAyahSheet(
              context,
              title: 'Ayahs on this line',
              places: const [_kursi],
            ),
            child: const Text('open'),
          ),
        ),
      ),
      overrides: [
        ayahHighlightStoreProvider.overrideWithValue(store),
        surasProvider.overrideWith((ref) async => const [_baqarah]),
        quranFontProvider.overrideWith((ref) async => false),
      ],
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  return store;
}

void main() {
  group('The ayahs sheet (§15 D113)', () {
    testWidgets('it names the verse and shows its text from the package', (
      tester,
    ) async {
      await _open(tester);
      expect(find.text('Al-Baqarah 2:255'), findsOneWidget);
      expect(find.text(_kursi.text), findsOneWidget);
      expect(find.text('Remove highlight'), findsNothing);
    });

    testWidgets('REQ-QRN-052 a colour highlights the verse; it can then be '
        'removed', (tester) async {
      final store = await _open(tester);

      await tester.tap(find.bySemanticsLabel('Green'));
      await tester.pumpAndSettle();
      expect(
        [for (final h in store.rows) (h.sura, h.aya, h.color)],
        [
          (2, 255, HighlightColor.green),
        ],
      );

      await tester.tap(find.text('Remove highlight'));
      await tester.pumpAndSettle();
      expect(store.rows, isEmpty);
    });

    testWidgets('copy puts the verse text and its reference on the '
        'clipboard', (tester) async {
      String? copied;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'Clipboard.setData') {
            copied =
                (call.arguments as Map<Object?, Object?>)['text'] as String?;
          }
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );
      await _open(tester);

      await tester.tap(find.text('Copy ayah'));
      await tester.pumpAndSettle();

      expect(copied, '﴿${_kursi.text}﴾\nAl-Baqarah 2:255');
      expect(find.text('Ayah copied'), findsOneWidget);
    });
  });
}
