import 'package:daily_muslim/features/contexts/domain/gazetteer_hit.dart';
import 'package:daily_muslim/features/contexts/domain/resolved_context.dart';
import 'package:daily_muslim/features/contexts/presentation/manual_place_controller.dart';
import 'package:daily_muslim/features/contexts/presentation/manual_place_state.dart';
import 'package:daily_muslim/features/contexts/presentation/manual_place_view.dart';
import 'package:daily_muslim/features/onboarding/presentation/city_selection.dart';
import 'package:daily_muslim/features/onboarding/presentation/welcome_action.dart';
import 'package:daily_muslim/features/shell/application/describe_failure.dart';
import 'package:daily_muslim/features/shell/presentation/needs_attention_card.dart';
import 'package:daily_muslim/l10n/app_localizations.dart';
import 'package:dm_ui/dm_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The first-run city picker in ivory and green (§15 D126): a title, the
/// offline city search (`SearchGazetteer`, the same list and states as the
/// Manual place page), each city with its region and country, the chosen
/// one marked, and *Use this city* pinned above the keyboard. Back returns
/// to the welcome screen. A full page, so it fits short windows; the
/// search stays pinned while the list scrolls.
final class CityPickerView extends ConsumerWidget {
  /// The picker; [onPinned] receives the stored context, [onBack] leaves.
  const new({required this.onPinned, required this.onBack, super.key});

  /// Called once the chosen city is stored.
  final ValueChanged<ResolvedContext> onPinned;

  /// Back to the welcome screen.
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final type = _typeOf(context);
    final coordinates =
        ref.watch(manualPlaceProvider) is ManualPlaceCoordinateEntry;
    // A landscape phone with the keyboard up leaves about 100 units: the
    // back row goes (system back still works) and *Use this city* moves to
    // the end of the list, so the results keep the room.
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;
    final cramped =
        keyboard > 0 && MediaQuery.sizeOf(context).height - keyboard < 320;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: DmTheme.statusBarOn(Brightness.light),
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) onBack();
        },
        child: Scaffold(
          backgroundColor: EmeraldPalette.panel,
          body: SafeArea(
            bottom: false,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (!cramped)
                      Align(
                        key: const Key('cityPickerHeader'),
                        alignment: AlignmentDirectional.centerStart,
                        child: Padding(
                          padding: const EdgeInsetsDirectional.only(start: 4),
                          child: IconButton(
                            key: const Key('cityPickerBack'),
                            onPressed: onBack,
                            color: EmeraldPalette.ink,
                            tooltip: MaterialLocalizations.of(
                              context,
                            ).backButtonTooltip,
                            icon: const Icon(Icons.arrow_back),
                          ),
                        ),
                      ),
                    Expanded(
                      key: const Key('cityPickerList'),
                      child: _CityList(
                        type: type,
                        onPinned: onPinned,
                        confirmInList: cramped,
                      ),
                    ),
                    if (!coordinates && !cramped)
                      _ConfirmBar(type: type, onPinned: onPinned),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

WelcomeType _typeOf(BuildContext context) => WelcomeType.of(
  Localizations.localeOf(context).languageCode == 'ar'
      ? StatusLocale.ar
      : StatusLocale.en,
  compact: MediaQuery.sizeOf(context).width < 360,
);

/// The title, the pinned search field and the exhaustive rendering of
/// [ManualPlaceState].
final class _CityList extends ConsumerWidget {
  const new({
    required this.type,
    required this.onPinned,
    required this.confirmInList,
  });

  final WelcomeType type;
  final ValueChanged<ResolvedContext> onPinned;

  /// *Use this city* is the list's last row instead of a fixed bar.
  final bool confirmInList;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final controller = ref.read(manualPlaceProvider.notifier);
    final state = ref.watch(manualPlaceProvider);
    final language = Localizations.localeOf(context).languageCode;
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 4, 24, 16),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Semantics(
                  header: true,
                  child: Text(
                    l.cityPickerTitle,
                    style: type.heading.copyWith(color: EmeraldPalette.ink),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l.cityPickerBody,
                  style: type.paragraph.copyWith(
                    color: EmeraldPalette.inkMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Pinned while the list scrolls, unless the window is too short to
        // show results under it once the keyboard is up. The keyboard
        // itself never changes this, or the field would lose its focus.
        if (MediaQuery.sizeOf(context).height >= 600)
          PinnedHeaderSliver(child: _SearchField(type: type))
        else
          SliverToBoxAdapter(child: _SearchField(type: type)),
        ...switch (state) {
          ManualPlaceIdle(suggestions: []) => [
            _Hint(text: l.placeIdle, type: type),
          ],
          // One tap for most users: the cities of the phone's time zone
          // (§15 D100).
          ManualPlaceIdle(:final suggestions) => [
            _Cities(
              heading: l.placeSuggestions,
              type: type,
              cities: [
                for (final hit in suggestions.map((h) => h.namedIn(language)))
                  (hit, hit.displayName),
              ],
            ),
          ],
          ManualPlaceSearching() => [
            const SliverPadding(
              padding: EdgeInsets.all(24),
              sliver: SliverToBoxAdapter(
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
          ],
          ManualPlaceResults(:final hits) => [
            _Cities(
              type: type,
              cities: [for (final hit in hits) (hit, titleOf(hit))],
            ),
          ],
          ManualPlaceEmpty() => [_Hint(text: l.cityPickerEmpty, type: type)],
          ManualPlaceCoordinateEntry(:final invalid) => [
            SliverFillRemaining(
              child: CoordinateForm(invalid: invalid, onPinned: onPinned),
            ),
          ],
          ManualPlaceError(:final failure) => [
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverToBoxAdapter(
                child: NeedsAttentionCard(const DescribeFailure()(failure)),
              ),
            ),
          ],
        },
        if (confirmInList && state is! ManualPlaceCoordinateEntry)
          SliverToBoxAdapter(
            child: _ConfirmBar(type: type, onPinned: onPinned),
          ),
        if (state is! ManualPlaceCoordinateEntry)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Center(
                child: TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: EmeraldPalette.ink,
                  ),
                  onPressed: controller.enterCoordinates,
                  child: Text(l.placeEnterCoordinates),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// A quiet line in the list: no city yet, or none found.
final class _Hint extends StatelessWidget {
  const new({required this.text, required this.type});

  final String text;
  final WelcomeType type;

  @override
  Widget build(BuildContext context) => SliverPadding(
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
    sliver: SliverToBoxAdapter(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: type.paragraph.copyWith(color: EmeraldPalette.inkMuted),
      ),
    ),
  );
}

/// The cities offered or found, each with its title.
final class _Cities extends StatelessWidget {
  const new({required this.cities, required this.type, this.heading});

  final List<(GazetteerHit, String)> cities;
  final WelcomeType type;

  /// A line above the list: why these cities are offered.
  final String? heading;

  @override
  Widget build(BuildContext context) => SliverPadding(
    padding: const EdgeInsets.symmetric(horizontal: 12),
    sliver: SliverList.list(
      children: [
        if (heading case final String line)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 6),
            child: Text(
              line,
              style: type.privacy.copyWith(color: EmeraldPalette.inkMuted),
            ),
          ),
        for (final (hit, title) in cities)
          _CityTile(hit: hit, title: title, type: type),
      ],
    ),
  );
}

/// The search field, pinned on the ivory page while the list scrolls.
final class _SearchField extends ConsumerWidget {
  const new({required this.type});

  final WelcomeType type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final controller = ref.read(manualPlaceProvider.notifier);
    OutlineInputBorder border(Color color, double width) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(17),
      borderSide: BorderSide(color: color, width: width),
    );
    return ColoredBox(
      color: EmeraldPalette.panel,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
        child: TextField(
          key: const Key('placeSearch'),
          style: type.paragraph.copyWith(color: EmeraldPalette.ink),
          cursorColor: EmeraldPalette.ink,
          decoration: InputDecoration(
            hintText: l.cityPickerSearch,
            hintStyle: type.paragraph.copyWith(color: EmeraldPalette.inkMuted),
            prefixIcon: const Icon(Icons.search, color: EmeraldPalette.ink),
            filled: true,
            fillColor: EmeraldPalette.surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 15,
            ),
            enabledBorder: border(EmeraldPalette.surfaceBorder, 1),
            focusedBorder: border(EmeraldPalette.action, 1.5),
            border: border(EmeraldPalette.surfaceBorder, 1),
          ),
          textInputAction: TextInputAction.search,
          onChanged: controller.queryChanged,
          onSubmitted: controller.search,
        ),
      ),
    );
  }
}

/// One city: its name and its region and country; the chosen one is
/// washed in green and checked.
final class _CityTile extends ConsumerWidget {
  const new({required this.hit, required this.title, required this.type});

  final GazetteerHit hit;
  final String title;
  final WelcomeType type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chosen = ref.watch(
      citySelectionProvider.select((pick) => pick.hit?.id == hit.id),
    );
    final detail = subtitleOf(hit);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: ListTile(
        selected: chosen,
        selectedTileColor: EmeraldPalette.wash,
        selectedColor: EmeraldPalette.ink,
        iconColor: EmeraldPalette.inkMuted,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        minTileHeight: 56,
        leading: Icon(
          chosen ? Icons.check_circle : Icons.location_city_outlined,
          color: chosen ? EmeraldPalette.action : EmeraldPalette.inkMuted,
        ),
        title: Text(
          title,
          style: type.cityName.copyWith(color: EmeraldPalette.ink),
        ),
        subtitle: detail.isEmpty
            ? null
            : Text(
                detail,
                style: type.privacy.copyWith(color: EmeraldPalette.inkMuted),
              ),
        onTap: () {
          ref.read(citySelectionProvider.notifier).choose(hit);
          // The keyboard goes, so *Use this city* is in view.
          FocusManager.instance.primaryFocus?.unfocus();
        },
      ),
    );
  }
}

/// The chosen city and *Use this city*, above the keyboard or the
/// navigation bar; disabled until a city is chosen.
final class _ConfirmBar extends ConsumerWidget {
  const new({required this.type, required this.onPinned});

  final WelcomeType type;
  final ValueChanged<ResolvedContext> onPinned;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final pick = ref.watch(citySelectionProvider);
    final hit = pick.hit;
    final name = hit
        ?.namedIn(Localizations.localeOf(context).languageCode)
        .displayName;
    Future<void> confirm() async {
      final pinned = await ref.read(citySelectionProvider.notifier).confirm();
      if (pinned != null) onPinned(pinned);
    }

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: EmeraldPalette.panel,
        border: Border(top: BorderSide(color: EmeraldPalette.divider)),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          10,
          24,
          12 + MediaQuery.paddingOf(context).bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (name != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Semantics(
                  liveRegion: true,
                  label: l.cityPickerSelected(name),
                  excludeSemantics: true,
                  child: Text(
                    name,
                    textAlign: TextAlign.center,
                    style: type.privacy.copyWith(
                      color: EmeraldPalette.inkMuted,
                    ),
                  ),
                ),
              ),
            WelcomeAction(
              key: const Key('cityPickerConfirm'),
              kind: WelcomeActionKind.primary,
              label: l.cityPickerConfirm,
              textStyle: type.action,
              icon: Icons.check,
              trailing: Icons.arrow_forward,
              loading: pick.saving,
              onPressed: hit == null ? null : confirm,
            ),
          ],
        ),
      ),
    );
  }
}
