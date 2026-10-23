import 'package:daily_muslim/features/home/presentation/display_style.dart';
import 'package:daily_muslim/features/passport/domain/import_mismatch.dart';
import 'package:daily_muslim/features/passport/domain/passport_entry.dart';
import 'package:daily_muslim/features/passport/presentation/passport_providers.dart';
import 'package:daily_muslim/features/passport/presentation/passport_state.dart';
import 'package:daily_muslim/features/passport/presentation/passport_view.dart';
import 'package:daily_muslim/features/shell/domain/app_route.dart';
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
    padding: const EdgeInsets.all(24),
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
    final text = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        ListTile(
          title: SelectableText(entry.calculationId, style: text.titleMedium),
          subtitle: entry.origin == PassportOrigin.importedMatch
              ? Text(l.passportImportMatch)
              : null,
          trailing: IconButton(
            tooltip: l.passportCopyLink,
            icon: const Icon(Icons.link),
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
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 4),
        child: Text(title, style: Theme.of(context).textTheme.titleMedium),
      ),
      for (final (label, value) in rows)
        ListTile(
          dense: true,
          title: Text(label),
          subtitle: SelectableText(value, textDirection: TextDirection.ltr),
        ),
    ],
  );
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
      if (event.sensitivitySeconds case final int s) l.passportSensitivity(s),
      if (time.flags.isEmpty) l.passportNoFlags,
      for (final flag in ResultFlag.values)
        if (time.flags.contains(flag)) flagText(l, flag),
    ];
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: focused
          ? RoundedRectangleBorder(
              side: BorderSide(color: scheme.primary, width: 2),
              borderRadius: BorderRadius.circular(12),
            )
          : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    DisplayStyle.eventName(l, time.event),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                ConfidenceChip(
                  label: time.confidence,
                  locale: style.locale,
                  digits: style.digits,
                ),
              ],
            ),
            for (final line in lines)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(line),
              ),
          ],
        ),
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
