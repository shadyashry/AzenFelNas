import 'package:daily_muslim/features/home/presentation/display_style.dart';
import 'package:daily_muslim/features/passport/domain/import_mismatch.dart';
import 'package:daily_muslim/features/passport/domain/passport_entry.dart';
import 'package:daily_muslim/features/passport/presentation/passport_providers.dart';
import 'package:daily_muslim/features/passport/presentation/passport_state.dart';
import 'package:daily_muslim/features/passport/presentation/passport_view.dart';
import 'package:daily_muslim/features/shell/domain/app_route.dart';
import 'package:daily_muslim/features/shell/presentation/scroll_insets.dart';
import 'package:daily_muslim/l10n/app_localizations.dart';
import 'package:dm_ui/dm_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geo_salah_core/geo_salah_core.dart';

/// The Accuracy Passport (P1, US-08, US-09) of [route].
final class PassportPage extends ConsumerWidget {
  /// The Passport of [route].
  const new(this.route, {super.key});

  /// The Calculation ID, focus and shared inputs.
  final CalculationRoute route;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final style = DisplayStyle.of(context, ref);
    return Scaffold(
      appBar: AppBar(title: Text(l.passportTitle)),
      body: switch (ref.watch(passportStateProvider(route))) {
        PassportLoading() => const Center(child: CircularProgressIndicator()),
        PassportReady(:final entry) => _Ready(entry: entry, style: style),
        PassportImportMismatch(:final details) => _Message(
          title: l.passportMismatchTitle,
          lines: _mismatchLines(l, details),
        ),
        PassportNotFound() => _Message(
          title: l.passportNotFoundTitle,
          lines: [
            l.passportNotFoundBody,
            l.passportLinkId(route.calculationId),
          ],
        ),
      },
    );
  }

  static List<String> _mismatchLines(AppLocalizations l, ImportMismatch d) => [
    switch (d.reason) {
      MismatchReason.differentVersions => l.passportMismatchVersions,
      MismatchReason.profileUnavailable => l.passportMismatchProfile(
        d.profileId,
        d.profileVersion,
      ),
      MismatchReason.zoneUnavailable => l.passportMismatchZone,
    },
    l.passportLinkId(d.linkId),
    if (d.localId case final String id) l.passportLocalId(id),
    l.passportThisDevice(d.engineVersion, d.tzdbVersion),
  ];
}

final class _Message extends StatelessWidget {
  const new({required this.title, required this.lines});

  final String title;
  final List<String> lines;

  @override
  Widget build(BuildContext context) => ListView(
    padding: scrollInsets(context, horizontal: 24, top: 24),
    children: [
      Text(title, style: Theme.of(context).textTheme.titleLarge),
      for (final line in lines)
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: SelectableText(line),
        ),
    ],
  );
}

final class _Ready extends StatelessWidget {
  const new({required this.entry, required this.style});

  final PassportView entry;
  final DisplayStyle style;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final inputs = entry.inputs;
    final p = entry.provenance;
    final theme = Theme.of(context);
    final text = theme.textTheme;
    return ListView(
      padding: scrollInsets(context, bottom: 32),
      children: [
        // The Calculation ID in a cartouche: the address of every minute on
        // this page (P1, §15 D89).
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 14, 8, 6),
          child: Row(
            children: [
              Expanded(
                child: Center(
                  child: Cartouche(
                    fill: RawdahPalette.emerald,
                    child: SelectableText(
                      entry.calculationId,
                      textDirection: TextDirection.ltr,
                      style: const TextStyle(
                        fontFamily: DmTheme.latinFamily,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.1,
                        color: RawdahPalette.ivory,
                      ),
                    ),
                  ),
                ),
              ),
              IconButton(
                tooltip: l.passportCopyLink,
                icon: Icon(Icons.link, color: theme.colorScheme.secondary),
                onPressed: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  await Clipboard.setData(
                    ClipboardData(text: entry.shareLink.toString()),
                  );
                  messenger.showSnackBar(
                    SnackBar(content: Text(l.passportLinkCopied)),
                  );
                },
              ),
            ],
          ),
        ),
        if (entry.origin == PassportOrigin.importedMatch)
          Text(
            l.passportImportMatch,
            textAlign: TextAlign.center,
            style: text.labelMedium,
          ),
        for (final event in entry.events)
          _EventCard(
            event: event,
            focused: event.time.event == entry.focus,
            style: style,
          ),
        _Section(
          title: l.passportInputsTitle,
          rows: [
            (
              l.passportCoordinates,
              '${inputs.latitudeDeg.toStringAsFixed(6)}, '
                  '${inputs.longitudeDeg.toStringAsFixed(6)}',
            ),
            (l.passportZone, inputs.zoneId),
            (l.passportDay, inputs.day.toJson()),
            (l.passportProfile, '${inputs.profileId} ${inputs.profileVersion}'),
            (
              l.passportHijri,
              '${_hijri(inputs.hijri.dateAtDawn)} / '
                  '${_hijri(inputs.hijri.dateAtNight)}',
            ),
          ],
          style: style,
        ),
        _Section(
          title: l.passportVersionsTitle,
          rows: [
            (l.passportEngine, p.engineVersion),
            (l.passportDeltaT, p.deltaTModel),
            (l.passportTzdb, p.tzdbVersion),
            (l.passportInputsHash, p.inputsHash),
          ],
          style: style,
        ),
      ],
    );
  }

  static String _hijri(HijriDate d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}

final class _Section extends StatelessWidget {
  const new({required this.title, required this.rows, required this.style});

  final String title;
  final List<(String, String)> rows;
  final DisplayStyle style;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return RawdahSection(
      title: title,
      children: [
        for (final (label, value) in rows)
          ListTile(
            dense: true,
            title: Text(label, style: text.labelMedium),
            subtitle: SelectableText(
              value,
              textDirection: TextDirection.ltr,
              style: text.bodyLarge,
            ),
          ),
      ],
    );
  }
}

final class _EventCard extends StatelessWidget {
  const new({required this.event, required this.focused, required this.style});

  final PassportEventView event;
  final bool focused;
  final DisplayStyle style;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final time = event.time;
    final scheme = Theme.of(context).colorScheme;
    final lines = <String>[
      if (event.displayedLocal case final String shown)
        l.passportShown(style.digits.apply(shown)),
      if (event.rawLocal case final String raw)
        l.passportRaw(style.digits.apply(raw)),
      if (time.rawUtcMs != null)
        switch (event.rounding) {
          RoundingMode.ceil => l.passportRoundingCeil,
          RoundingMode.floor => l.passportRoundingFloor,
          RoundingMode.nearest => l.passportRoundingNearest,
        },
      switch (time.origin) {
        Primary() => l.passportOriginPrimary,
        Fallback(:final method) => l.passportOriginFallback(_method(method)),
        NoEvent(:final reason) => l.passportOriginNoEvent(reason.name),
      },
      for (final step in event.adjustments)
        l.passportAdjustment(
          _kind(l, step.kind),
          style.digits.apply(_signedSeconds(step.deltaMs)),
        ),
      if (event.sensitivitySeconds case final int s)
        style.digits.apply(l.passportSensitivity(s)),
      if (time.flags.isEmpty) l.passportNoFlags,
      for (final flag in ResultFlag.values)
        if (time.flags.contains(flag)) flagText(l, flag),
    ];
    final text = Theme.of(context).textTheme;
    final rawdah = RawdahScheme.of(context);
    // A gold-hairline panel per prayer; the one the user tapped is framed in
    // gilded gold on the Rawdah wash (§15 D89).
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 6, 16, 6),
      decoration: BoxDecoration(
        color: focused ? rawdah.wash : rawdah.panel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: focused ? RawdahPalette.gold : rawdah.hairline,
          width: focused ? 2 : 1,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 10,
            children: [
              Text(
                DisplayStyle.eventName(l, time.event),
                style: DmTheme.naskh(
                  size: 22,
                  color: scheme.primary,
                  bold: true,
                ),
              ),
              ConfidenceChip(
                label: time.confidence,
                locale: style.locale,
                digits: style.digits,
              ),
            ],
          ),
          const SizedBox(height: 4),
          for (final line in lines)
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsetsDirectional.only(top: 7, end: 8),
                    child: Transform.rotate(
                      angle: 0.785,
                      child: Container(
                        width: 6,
                        height: 6,
                        color: RawdahPalette.gold,
                      ),
                    ),
                  ),
                  Expanded(child: Text(line, style: text.bodyLarge)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  static String _signedSeconds(int ms) {
    final seconds = ms / 1000;
    final text = seconds == seconds.roundToDouble()
        ? seconds.toStringAsFixed(0)
        : seconds.toStringAsFixed(3);
    return ms > 0 ? '+$text' : text;
  }

  static String _method(HighLatitudeMethod method) => switch (method) {
    AnglePortion() => 'anglePortion',
    MiddleOfNight() => 'middleOfNight',
    SeventhOfNight() => 'seventhOfNight',
    NearestLatitude(:final latDeg) => 'nearestLatitude($latDeg°)',
    NearestValidDay(:final maxDays) => 'nearestValidDay($maxDays)',
  };

  static String _kind(AppLocalizations l, AdjustmentKind kind) =>
      switch (kind) {
        AdjustmentKind.perEventOffset => l.passportAdjustOffset,
        AdjustmentKind.ramadanRuleReplacement => l.passportAdjustRamadan,
        AdjustmentKind.highLatitudeFallback => l.passportAdjustHighLatitude,
        AdjustmentKind.rounding => l.passportAdjustRounding,
      };
}

/// The plain-language copy of [flag] (US-08).
String flagText(AppLocalizations l, ResultFlag flag) => switch (flag) {
  ResultFlag.nearRoundingBoundary => l.flagNearRoundingBoundary,
  ResultFlag.highLatitudeFallback => l.flagHighLatitudeFallback,
  ResultFlag.lowLocationAccuracy => l.flagLowLocationAccuracy,
  ResultFlag.dstTransitionDay => l.flagDstTransitionDay,
  ResultFlag.staleTzdb => l.flagStaleTzdb,
  ResultFlag.hijriExpected => l.flagHijriExpected,
  ResultFlag.referenceModeAuthorityPoint => l.flagReferenceModeAuthorityPoint,
  ResultFlag.manualCoordinateResolution => l.flagManualCoordinateResolution,
  ResultFlag.zoneBoundaryProximity => l.flagZoneBoundaryProximity,
  ResultFlag.noLocalProfile => l.flagNoLocalProfile,
};
