import 'package:meta/meta.dart';

/// The search form of Arabic text (§15 D107, REQ-QRN-040).
///
/// Search runs on a separate, folded copy of the verses; the displayed text
/// is never changed. Folding drops every diacritic and Quranic mark, the
/// tatweel and every alef and hamza seat, maps teh marbuta to heh, alef
/// maksura to yeh and waw/yeh with hamza to waw/yeh, reads the small
/// high yeh as yeh, and drops the spaces: the Uthmani text joins words a
/// reader types apart (`يَٰٓأَيُّهَا` for `يا أيها`). Dropping the alef
/// lets the Uthmani spelling
/// (`ٱلصَّلَوٰةَ`, `ٱلۡكِتَٰبُ`) meet the everyday spelling a reader
/// types
/// (`الصلاة`, `الكتاب`); the price is that a few words with and without an
/// alef meet too (`قال` and `قل`), which the result context makes visible.
///
/// The same function folds the verses (when the index is built) and the
/// query, so the two always agree.
@immutable
final class FoldedText {
  const new _(this.text, this._sources);

  /// The folded text: Arabic letters without marks or spaces.
  final String text;

  /// For each code unit of [text], the index of the source code unit it
  /// came from.
  final List<int> _sources;

  /// The range of the source text that produced [text]`[start, end)`,
  /// extended over the marks that follow its last letter.
  ({int start, int end}) sourceRange(String source, int start, int end) {
    final from = _sources[start];
    var to = _sources[end - 1] + 1;
    while (to < source.length &&
        ArabicSearchText.isMark(source.codeUnitAt(to))) {
      to++;
    }
    return (start: from, end: to);
  }
}

/// Folds Arabic text for search; see [FoldedText].
abstract final class ArabicSearchText {
  static const int _waw = 0x0648;
  static const int _yeh = 0x064A;
  static const int _heh = 0x0647;
  static const int _superscriptAlef = 0x0670;
  static const int _smallHighYeh = 0x06E7;
  static const String _ornateOpen = '﴿';
  static const String _ornateClose = '﴾';

  /// [source] folded, with the source index of every folded code unit.
  static FoldedText fold(String source) {
    final out = StringBuffer();
    final sources = <int>[];
    for (var i = 0; i < source.length; i++) {
      final unit = source.codeUnitAt(i);
      if (_isSpace(unit)) continue;
      final next = i + 1 < source.length ? source.codeUnitAt(i + 1) : -1;
      final mapped = _map(unit, next);
      if (mapped == null) continue;
      out.writeCharCode(mapped);
      sources.add(i);
    }
    return FoldedText._(out.toString(), List.unmodifiable(sources));
  }

  /// [source] folded.
  static String normalize(String source) => fold(source).text;

  /// A search query folded. Text quoted in ornate parentheses (`﴿…﴾`, the
  /// form *Copy ayah* writes, §15 D111) is searched by what is inside them,
  /// so a pasted ayah finds itself without its reference.
  static String query(String source) {
    final open = source.indexOf(_ornateOpen);
    if (open < 0) return normalize(source);
    final close = source.indexOf(_ornateClose, open + 1);
    return normalize(
      source.substring(open + 1, close < 0 ? source.length : close),
    );
  }

  /// Whether [unit] is a mark that follows a letter (harakat, Quranic
  /// annotation marks, the superscript alef, tatweel).
  static bool isMark(int unit) =>
      (unit >= 0x064B && unit <= 0x065F) ||
      unit == _superscriptAlef ||
      unit == 0x0640 ||
      (unit >= 0x06D6 && unit <= 0x06ED && unit != 0x06DD && unit != 0x06DE) ||
      (unit >= 0x08D3 && unit <= 0x08FF);

  static bool _isSpace(int unit) =>
      unit == 0x20 || unit == 0xA0 || unit == 0x09 || unit == 0x0A;

  /// The folded code unit of [unit] (followed by [next]), or `null` when it
  /// is dropped.
  static int? _map(int unit, int next) {
    if (unit == _waw && next == _superscriptAlef) return null;
    if (unit == _smallHighYeh) return _yeh;
    if (isMark(unit)) return null;
    return switch (unit) {
      // Alef, alef with madda / hamza above / hamza below, alef wasla.
      0x0627 || 0x0622 || 0x0623 || 0x0625 || 0x0671 => null,
      // Hamza, end of ayah, start of rub el hizb, place of sajdah.
      0x0621 || 0x06DD || 0x06DE || 0x06E9 => null,
      0x0629 => _heh,
      0x0649 => _yeh,
      0x0624 => _waw,
      0x0626 => _yeh,
      // Arabic-Indic digits are verse numbers here, never words.
      >= 0x0660 && <= 0x0669 => null,
      // Ornate parentheses quote an ayah; they are never words.
      0xFD3E || 0xFD3F => null,
      // Latin letters fold to lower case; anything else stays.
      >= 0x41 && <= 0x5A => unit + 0x20,
      _ => unit,
    };
  }
}
