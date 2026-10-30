import 'package:daily_muslim/features/home/presentation/display_style.dart';
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
