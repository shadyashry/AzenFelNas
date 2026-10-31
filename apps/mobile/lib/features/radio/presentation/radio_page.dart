import 'dart:async';
import 'dart:math' as math;

import 'package:daily_muslim/features/radio/domain/radio_station.dart';
import 'package:daily_muslim/features/radio/presentation/radio_header.dart';
import 'package:daily_muslim/features/radio/presentation/radio_player_card.dart';
import 'package:daily_muslim/features/radio/presentation/radio_providers.dart';
import 'package:daily_muslim/features/radio/presentation/radio_station_list.dart';
import 'package:daily_muslim/features/radio/presentation/radio_tokens.dart';
import 'package:daily_muslim/features/radio/presentation/radio_type.dart';
import 'package:daily_muslim/features/shell/presentation/app_tab_bar.dart';
import 'package:daily_muslim/l10n/app_localizations.dart';
import 'package:dm_ui/dm_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Quran radio (§15 D122): the player above the station list in portrait;
/// side by side when the window is wide enough (landscape phones, tablets,
/// unfolded and split windows), the player on the leading side. The
/// layout follows the window's size, never the device's.
final class RadioPage extends ConsumerStatefulWidget {
  /// The page.
  const new({super.key});

  /// From this width the player and the list sit side by side.
  static const double sideBySideWidth = 640;

  /// The widest the content grows on a large screen.
  static const double maxContentWidth = 1120;

  @override
  ConsumerState<RadioPage> createState() => _RadioPageState();
}

final class _RadioPageState extends ConsumerState<RadioPage> {
  final _query = TextEditingController();
  RadioListFilter _filter = RadioListFilter.all;

  @override
  void initState() {
    super.initState();
    _query.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = RadioTokens.of(context);
    return AnnotatedRegion(
      // Light status bar icons over the green header in both appearances.
      value: DmTheme.statusBarOn(Brightness.dark),
      child: Scaffold(
        backgroundColor: t.background,
        extendBody: true,
        bottomNavigationBar: const AppTabBar(current: RawdahTab.radio),
        body: LayoutBuilder(
          builder: (context, box) {
            final size = MediaQuery.sizeOf(context);
            final landscape = size.width > size.height;
            final sideBySide =
                box.maxWidth >= RadioPage.sideBySideWidth &&
                (landscape || box.maxWidth >= 840);
            return Stack(
              children: [
                if (sideBySide)
                  _wide(context, box, compactHeader: box.maxHeight < 560)
                else
                  _narrow(context),
                // Once the header scrolls away, the status bar keeps its
                // green, so its light icons stay readable.
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: MediaQuery.paddingOf(context).top,
                  child: ColoredBox(color: t.header),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _narrow(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return RefreshIndicator(
      onRefresh: _refresh,
      edgeOffset: MediaQuery.paddingOf(context).top,
      child: CustomScrollView(
        key: const PageStorageKey('radio-narrow'),
        slivers: [
          const SliverToBoxAdapter(child: RadioHeader()),
          const SliverPadding(
            padding: EdgeInsets.fromLTRB(18, 20, 18, 8),
            sliver: SliverToBoxAdapter(child: RadioPlayerCard()),
          ),
          ..._listSlivers(context, horizontal: 18),
          SliverPadding(padding: EdgeInsets.only(bottom: bottom + 12)),
        ],
      ),
    );
  }

  Widget _wide(
    BuildContext context,
    BoxConstraints box, {
    required bool compactHeader,
  }) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    final width = math.min(box.maxWidth, RadioPage.maxContentWidth);
    final playerWidth = math.min(420, width * 0.42).toDouble();
    return Column(
      children: [
        RadioHeader(compact: compactHeader),
        Expanded(
          child: Center(
            child: SizedBox(
              width: width,
              child: SafeArea(
                top: false,
                bottom: false,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: playerWidth,
                      child: SingleChildScrollView(
                        key: const PageStorageKey('radio-player'),
                        padding: EdgeInsetsDirectional.fromSTEB(
                          20,
                          16,
                          8,
                          bottom + 12,
                        ),
                        child: RadioPlayerCard(compact: compactHeader),
                      ),
                    ),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _refresh,
                        child: CustomScrollView(
                          key: const PageStorageKey('radio-list'),
                          slivers: [
                            const SliverPadding(
                              padding: EdgeInsets.only(top: 4),
                            ),
                            ..._listSlivers(context, horizontal: 12),
                            SliverPadding(
                              padding: EdgeInsets.only(bottom: bottom + 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _listSlivers(
    BuildContext context, {
    required double horizontal,
  }) {
    final l = AppLocalizations.of(context);
    final t = RadioTokens.of(context);
    final type = RadioType.of(context);
    final view = ref.watch(radioControllerProvider);
    final favorites = ref.watch(radioFavoritesProvider).value ?? const {};
    final catalog = view.catalog;
    final stations = <RadioStation>[
      for (final s in catalog?.stations ?? const <RadioStation>[])
        if ((_filter == RadioListFilter.all || favorites.contains(s.id)) &&
            RadioSearch.matches(s, _query.text))
          s,
    ];
    final pad = EdgeInsets.symmetric(horizontal: horizontal);
    Widget message(String text, {Widget? action}) => SliverPadding(
      padding: pad.add(const EdgeInsets.symmetric(vertical: 20)),
      sliver: SliverToBoxAdapter(
        child: Column(
          children: [
            Text(
              text,
              textAlign: TextAlign.center,
              style: type.body.copyWith(color: t.textMuted),
            ),
            if (action != null) ...[const SizedBox(height: 8), action],
          ],
        ),
      ),
    );
    final retry = TextButton(
      onPressed: () => unawaited(_refresh()),
      style: TextButton.styleFrom(foregroundColor: t.green),
      child: Text(l.radioTryAgain),
    );
    return [
      SliverPadding(
        padding: pad.add(const EdgeInsets.only(top: 12)),
        sliver: SliverToBoxAdapter(
          child: RadioListHeader(
            filter: _filter,
            onFilter: (f) => setState(() => _filter = f),
          ),
        ),
      ),
      SliverPadding(
        padding: pad.add(const EdgeInsets.only(top: 4, bottom: 8)),
        sliver: SliverToBoxAdapter(
          child: RadioSearchField(controller: _query),
        ),
      ),
      if (catalog != null && view.refreshFailed)
        SliverPadding(
          padding: pad,
          sliver: SliverToBoxAdapter(
            child: Row(
              children: [
                Icon(Icons.cloud_off_outlined, size: 16, color: t.textMuted),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l.radioSavedList,
                    style: type.secondary.copyWith(color: t.textMuted),
                  ),
                ),
                retry,
              ],
            ),
          ),
        ),
      if (catalog == null && (!view.loaded || view.refreshing))
        message(l.radioLoading)
      else if (catalog == null)
        message(l.radioLoadFailed, action: retry)
      else if (stations.isEmpty && _query.text.trim().isNotEmpty)
        message(l.radioNoMatches(_query.text.trim()))
      else if (stations.isEmpty)
        message(l.radioNoFavorites)
      else
        SliverPadding(
          padding: pad,
          sliver: SliverList.separated(
            itemCount: stations.length,
            itemBuilder: (context, i) => RadioStationRow(
              key: ValueKey(stations[i].id),
              station: stations[i],
              favorite: favorites.contains(stations[i].id),
            ),
            separatorBuilder: (context, i) => Divider(
              height: 1,
              indent: 54,
              color: t.border.withValues(alpha: 0.7),
            ),
          ),
        ),
      if (catalog != null) const SliverToBoxAdapter(child: RadioAttribution()),
    ];
  }

  Future<void> _refresh() async {
    await ref.read(radioControllerProvider.notifier).refresh();
  }
}
