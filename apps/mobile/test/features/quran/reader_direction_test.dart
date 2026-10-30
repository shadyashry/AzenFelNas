import 'package:daily_muslim/features/quran/domain/reader_preferences.dart';
import 'package:daily_muslim/features/quran/presentation/mushaf_viewport.dart';
import 'package:daily_muslim/features/quran/presentation/mushaf_viewport_controller.dart';
import 'package:daily_muslim/features/quran/presentation/reader_bars.dart';
import 'package:daily_muslim/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The reader surface over ten plain items in [locale], recording turns.
Widget _reader(
  Locale locale,
  MushafViewportController controller,
  List<int> turns, {
  bool drawing = false,
}) => MaterialApp(
  locale: locale,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(
    body: Column(
      children: [
        Expanded(
          child: MushafViewport(
            itemCount: 10,
            item: 0,
            aspect: 0.7,
            fit: PageFit.page,
            controller: controller,
            drawing: drawing,
            semanticLabel: 'page',
            itemBuilder: (context, item, size) =>
                ColoredBox(color: Colors.white, child: Text('item $item')),
            onItemChanged: turns.add,
            onDraw: (_, _, _) {},
            onTap: (_, _) {},
          ),
        ),
        ReaderBottomBar(viewport: controller),
      ],
    ),
  ),
);

void main() {
  testWidgets('REQ-QRN-032: the zoom buttons still work after the viewport '
      'is replaced in the same frame', (tester) async {
    final controller = MushafViewportController();
    Widget viewport(Key key) => MushafViewport(
      key: key,
      itemCount: 10,
      item: 0,
      aspect: 0.7,
      fit: PageFit.page,
      controller: controller,
      drawing: false,
      semanticLabel: 'page',
      itemBuilder: (context, item, size) => const SizedBox.expand(),
      onItemChanged: (_) {},
      onDraw: (_, _, _) {},
      onTap: (_, _) {},
    );
    Widget app(Key key) => Directionality(
      textDirection: TextDirection.ltr,
      child: viewport(key),
    );
    await tester.pumpWidget(app(const ValueKey(1)));
    // As when the reader's bars hide: a new viewport mounts before the old
    // one is disposed.
    await tester.pumpWidget(app(const ValueKey(2)));
    await tester.pump();

    controller.send(ViewportCommand.zoomIn);
    await tester.pump();

    expect(controller.scale, greaterThan(1));
  });

  for (final locale in const [Locale('en'), Locale('ar')]) {
    group('interface ${locale.languageCode}', () {
      testWidgets('REQ-QRN-020: a swipe to the right turns to the next '
          'page', (tester) async {
        final turns = <int>[];
        final controller = MushafViewportController();
        await tester.pumpWidget(_reader(locale, controller, turns));

        await tester.drag(find.byType(MushafViewport), const Offset(300, 0));
        await tester.pumpAndSettle();
        await tester.drag(find.byType(MushafViewport), const Offset(300, 0));
        await tester.pumpAndSettle();
        await tester.drag(find.byType(MushafViewport), const Offset(-300, 0));
        await tester.pumpAndSettle();

        expect(turns, [1, 2, 1]);
      });

      testWidgets('REQ-QRN-020: Next page sits on the left and turns '
          'forward, Previous on the right', (tester) async {
        final turns = <int>[];
        final controller = MushafViewportController();
        await tester.pumpWidget(_reader(locale, controller, turns));
        final l = await AppLocalizations.delegate.load(locale);

        final next = find.byTooltip(l.quranNextPage);
        final previous = find.byTooltip(l.quranPreviousPage);
        expect(
          tester.getCenter(next).dx,
          lessThan(tester.getCenter(previous).dx),
        );

        await tester.tap(next);
        await tester.pumpAndSettle();
        await tester.tap(next);
        await tester.pumpAndSettle();
        await tester.tap(previous);
        await tester.pumpAndSettle();

        expect(turns, [1, 2, 1]);
      });

      testWidgets('REQ-QRN-032: one swipe turns one page, however fast', (
        tester,
      ) async {
        final turns = <int>[];
        final controller = MushafViewportController();
        await tester.pumpWidget(_reader(locale, controller, turns));

        await tester.fling(
          find.byType(MushafViewport),
          const Offset(600, 0),
          4000,
        );
        await tester.pumpAndSettle();

        expect(turns.last, 1);
      });

      testWidgets('REQ-QRN-032: while drawing a highlight a swipe does not '
          'turn the page', (tester) async {
        final turns = <int>[];
        final controller = MushafViewportController();
        await tester.pumpWidget(
          _reader(locale, controller, turns, drawing: true),
        );

        await tester.drag(find.byType(MushafViewport), const Offset(300, 0));
        await tester.pumpAndSettle();

        expect(turns, isEmpty);
      });
    });
  }
}
