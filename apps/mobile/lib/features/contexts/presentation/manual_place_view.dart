import 'package:daily_muslim/features/contexts/domain/gazetteer_hit.dart';
import 'package:daily_muslim/features/contexts/domain/resolved_context.dart';
import 'package:daily_muslim/features/contexts/presentation/manual_place_controller.dart';
import 'package:daily_muslim/features/contexts/presentation/manual_place_state.dart';
import 'package:daily_muslim/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Search field and the exhaustive rendering of [ManualPlaceState]; calls
/// [onPinned] with the new manual context. Used by the Manual place page and
/// the onboarding `place` step.
final class ManualPlaceView extends ConsumerWidget {
  /// The view.
  const new({required this.onPinned, super.key});

  /// Called once a place is pinned.
  final ValueChanged<ResolvedContext> onPinned;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final controller = ref.read(manualPlaceProvider.notifier);
    final state = ref.watch(manualPlaceProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            key: const Key('placeSearch'),
            decoration: InputDecoration(
              hintText: l.placeSearchHint,
              prefixIcon: const Icon(Icons.search),
            ),
            textInputAction: TextInputAction.search,
            onSubmitted: controller.search,
          ),
        ),
        Expanded(
          child: switch (state) {
            ManualPlaceIdle() => _Hint(text: l.placeIdle),
            ManualPlaceSearching() => const Center(
              child: CircularProgressIndicator(),
            ),
            ManualPlaceResults(:final hits) => ListView(
              children: [
                for (final hit in hits)
                  _HitTile(
                    hit: hit,
                    onTap: () async {
                      final pinned = await controller.pickHit(hit);
                      if (pinned != null) onPinned(pinned);
                    },
                  ),
              ],
            ),
            ManualPlaceEmpty() => _Hint(text: l.placeEmpty),
            ManualPlaceCoordinateEntry(:final invalid) => CoordinateForm(
              invalid: invalid,
              onPinned: onPinned,
            ),
            ManualPlaceError(:final failure) => _Hint(
              text: l.placeError(failure.code.wire),
            ),
          },
        ),
        if (state is! ManualPlaceCoordinateEntry)
          Padding(
            padding: const EdgeInsets.all(16),
            child: OutlinedButton(
              onPressed: controller.enterCoordinates,
              child: Text(l.placeEnterCoordinates),
            ),
          ),
      ],
    );
  }
}

final class _HitTile extends StatelessWidget {
  const new({required this.hit, required this.onTap});

  final GazetteerHit hit;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ListTile(
    title: Text(hit.matchedName),
    subtitle: Text(
      [hit.admin1, hit.country].where((s) => s.isNotEmpty).join(' · '),
    ),
    onTap: onTap,
  );
}

final class _Hint extends StatelessWidget {
  const new({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    child: Text(text, textAlign: TextAlign.center),
  );
}

/// Typed latitude, longitude and a name (`TypedCoordinates`).
final class CoordinateForm extends ConsumerStatefulWidget {
  /// The form; [invalid] shows the range hint.
  const new({required this.invalid, required this.onPinned, super.key});

  /// The last entry was out of range.
  final bool invalid;

  /// Called once the place is pinned.
  final ValueChanged<ResolvedContext> onPinned;

  @override
  ConsumerState<CoordinateForm> createState() => _CoordinateFormState();
}

final class _CoordinateFormState extends ConsumerState<CoordinateForm> {
  final _latitude = TextEditingController();
  final _longitude = TextEditingController();
  final _name = TextEditingController();

  @override
  void dispose() {
    _latitude.dispose();
    _longitude.dispose();
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    const numbers = TextInputType.numberWithOptions(
      signed: true,
      decimal: true,
    );
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextField(
          key: const Key('placeLatitude'),
          controller: _latitude,
          keyboardType: numbers,
          decoration: InputDecoration(labelText: l.placeLatitude),
        ),
        TextField(
          key: const Key('placeLongitude'),
          controller: _longitude,
          keyboardType: numbers,
          decoration: InputDecoration(labelText: l.placeLongitude),
        ),
        TextField(
          key: const Key('placeName'),
          controller: _name,
          decoration: InputDecoration(labelText: l.placeName),
        ),
        if (widget.invalid)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              l.placeCoordinatesInvalid,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        const SizedBox(height: 16),
        FilledButton(onPressed: _submit, child: Text(l.placeUse)),
      ],
    );
  }

  Future<void> _submit() async {
    final pinned = await ref
        .read(manualPlaceProvider.notifier)
        .pickCoordinates(
          latitudeDeg: double.tryParse(_latitude.text.trim()),
          longitudeDeg: double.tryParse(_longitude.text.trim()),
          label: _name.text,
        );
    if (pinned != null) widget.onPinned(pinned);
  }
}
