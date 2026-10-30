import 'dart:async';

import 'package:daily_muslim/features/home/presentation/display_style.dart';
import 'package:daily_muslim/features/quran/domain/mushaf_index_entries.dart';
import 'package:daily_muslim/features/quran/domain/mushaf_layout.dart';
import 'package:daily_muslim/features/quran/domain/quran_edition_pin.dart';
import 'package:daily_muslim/features/quran/presentation/quran_format.dart';
import 'package:daily_muslim/features/quran/presentation/reader_controller.dart';
import 'package:daily_muslim/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Asks for a page number and opens it (REQ-QRN-022). Accepts Western and
/// Arabic-Indic digits; anything outside 1..604 is refused with a message.
/// Page navigation only: it never searches the text.
Future<void> showGoToPageDialog(BuildContext context, WidgetRef ref) async {
  final page = await showDialog<int>(
    context: context,
    builder: (context) => const _GoToPageDialog(),
  );
  if (page != null) ref.read(readerProvider.notifier).goTo(page);
}

final class _GoToPageDialog extends ConsumerStatefulWidget {
  const new();

  @override
  ConsumerState<_GoToPageDialog> createState() => _GoToPageDialogState();
}

final class _GoToPageDialogState extends ConsumerState<_GoToPageDialog> {
  final _field = TextEditingController();
  bool _invalid = false;

  @override
  void dispose() {
    _field.dispose();
    super.dispose();
  }

  void _submit() {
    final page = QuranEditionPin.layout.parsePage(_field.text);
    if (page == null) {
      setState(() => _invalid = true);
    } else {
      Navigator.of(context).pop(page);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final count = QuranFormat.number(
      QuranEditionPin.layout.pageCount,
      DisplayStyle.of(context, ref),
    );
    return AlertDialog(
      title: Text(l.quranGoToPage),
      content: TextField(
        controller: _field,
        autofocus: true,
        keyboardType: TextInputType.number,
        inputFormatters: [LengthLimitingTextInputFormatter(4)],
        textInputAction: TextInputAction.go,
        onSubmitted: (_) => _submit(),
        decoration: InputDecoration(
          hintText: l.quranGoToPageHint(count),
          errorText: _invalid ? l.quranGoToPageInvalid(count) : null,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
        ),
        FilledButton(onPressed: _submit, child: Text(l.quranGo)),
      ],
    );
  }
}

/// Asks for a verse of [sura] and opens it with its lines outlined, the
/// page kept whole (§15 D120, REQ-QRN-025). Accepts 1..its verse count in
/// any digits; anything else is refused with a message.
Future<void> showGoToAyahDialog(
  BuildContext context,
  WidgetRef ref,
  SuraEntry sura,
) async {
  final aya = await showDialog<int>(
    context: context,
    builder: (context) => _GoToAyahDialog(sura: sura),
  );
  if (aya == null) return;
  unawaited(
    ref
        .read(readerProvider.notifier)
        .showVerseAt(sura.number, aya, fallbackPage: sura.startPage),
  );
}

final class _GoToAyahDialog extends ConsumerStatefulWidget {
  const new({required this.sura});

  final SuraEntry sura;

  @override
  ConsumerState<_GoToAyahDialog> createState() => _GoToAyahDialogState();
}

final class _GoToAyahDialogState extends ConsumerState<_GoToAyahDialog> {
  final _field = TextEditingController();
  bool _invalid = false;

  @override
  void dispose() {
    _field.dispose();
    super.dispose();
  }

  void _submit() {
    final aya = parseTypedNumber(_field.text);
    if (aya == null || aya < 1 || aya > widget.sura.verseCount) {
      setState(() => _invalid = true);
    } else {
      Navigator.of(context).pop(aya);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final style = DisplayStyle.of(context, ref);
    final count = QuranFormat.number(widget.sura.verseCount, style);
    return AlertDialog(
      title: Text(l.quranGoToAyah),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(QuranFormat.surahName(widget.sura, style)),
          const SizedBox(height: 8),
          TextField(
            controller: _field,
            autofocus: true,
            keyboardType: TextInputType.number,
            inputFormatters: [LengthLimitingTextInputFormatter(3)],
            textInputAction: TextInputAction.go,
            onSubmitted: (_) => _submit(),
            decoration: InputDecoration(
              hintText: l.quranGoToPageHint(count),
              errorText: _invalid ? l.quranGoToAyahInvalid(count) : null,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
        ),
        FilledButton(onPressed: _submit, child: Text(l.quranGo)),
      ],
    );
  }
}
