import 'dart:convert';
import 'dart:io';

import 'package:daily_muslim/features/shell/application/describe_failure.dart';
import 'package:daily_muslim/features/shell/domain/needs_attention.dart';
import 'package:daily_muslim/features/shell/domain/remediation.dart';
import 'package:daily_muslim/features/shell/presentation/remediation_copy.dart';
import 'package:daily_muslim/features/storage/domain/storage_failure.dart';
import 'package:daily_muslim/l10n/app_localizations.dart';
import 'package:dm_core_types/dm_core_types.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, Object?> _arb(String locale) =>
    switch (jsonDecode(File('lib/l10n/app_$locale.arb').readAsStringSync())) {
      final Map<String, Object?> arb => arb,
      _ => throw const FormatException('ARB'),
    };

void main() {
  test('every Appendix J failure code has a remediation (REQ-ERR-002)', () {
    final used = {for (final c in FailureCode.values) DescribeFailure.of(c)};
    expect(FailureCode.values, hasLength(27));
    expect(used, Remediation.values.toSet());
  });

  test('a typed failure keeps its code (REQ-ERR-001)', () {
    expect(
      const DescribeFailure()(const MigrationFailed('dm.sqlite')),
      const NeedsAttention(
        code: FailureCode.dbMigrationFailed,
        remediation: Remediation.updateApp,
      ),
    );
  });

  test('every remediation has distinct copy in en and ar', () async {
    for (final locale in AppLocalizations.supportedLocales) {
      final l = await AppLocalizations.delegate.load(locale);
      final texts = {
        for (final r in Remediation.values) RemediationCopy.of(l, r),
      };
      expect(texts, hasLength(Remediation.values.length), reason: '$locale');
      expect(texts.every((t) => t.trim().isNotEmpty), isTrue);
    }
  });

  test('en and ar ARB files have the same keys; ar is Arabic', () {
    final en = _arb('en').keys.where((k) => !k.startsWith('@')).toSet();
    final ar = _arb('ar').keys.where((k) => !k.startsWith('@')).toSet();
    expect(ar, en);
    expect(
      AppLocalizations.supportedLocales,
      unorderedEquals(const [Locale('ar'), Locale('en')]),
    );
  });

  test('shell copy never uses a status word outside §18.5 (REQ-UX-040)', () {
    for (final locale in ['en', 'ar']) {
      final values = _arb(locale).entries
          .where((e) => !e.key.startsWith('@'))
          .map((e) => '${e.value}'.toLowerCase());
      for (final word in [
        'verified',
        'official',
        'confirmed',
        'موثّق',
        'رسمي',
      ]) {
        expect(values.where((v) => v.contains(word)), isEmpty, reason: word);
      }
    }
  });
}
