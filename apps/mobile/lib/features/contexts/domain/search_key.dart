import 'package:meta/meta.dart';

/// The normalised form of a place name or query that gazetteer search
/// compares (§13 S12, §15 D72).
///
/// Arabic: harakat, superscript alef and tatweel are dropped; أ إ آ ٱ fold to
/// ا, ى and ی to ي, ئ to ي, ؤ to و, ة to ه and ک to ك; Arabic-Indic digits
/// become ASCII digits. Latin: lower case, Latin-1 and Latin Extended-A
/// diacritics removed (ß → ss, æ → ae, œ → oe, þ → th). Apostrophes are
/// dropped, other punctuation becomes a space, and runs of spaces collapse.
/// «القاهرة», «القاهره» and «القَاهِرَة» share one key, as do "Zürich" and
/// "zurich".
@immutable
final class SearchKey {
  const new _(this.value);

  /// The key of [text]; empty when [text] holds no letter or digit.
  factory of(String text) {
    final out = StringBuffer();
    var pendingSpace = false;
    for (final rune in text.toLowerCase().runes) {
      final folded = _fold(rune);
      if (folded == null) continue;
      if (folded == ' ') {
        pendingSpace = out.isNotEmpty;
        continue;
      }
      if (pendingSpace) out.write(' ');
      pendingSpace = false;
      out.write(folded);
    }
    return SearchKey._(out.toString());
  }

  /// The normalised text.
  final String value;

  /// Whether nothing searchable is left.
  bool get isEmpty => value.isEmpty;

  /// The keys a place name is stored under: its own key and, for an Arabic
  /// name whose first word starts with the article «ال», the key without it,
  /// so «قاهرة» finds «القاهرة».
  static Set<SearchKey> indexKeysOf(String name) {
    final key = SearchKey.of(name);
    if (key.isEmpty) return const {};
    final value = key.value;
    if (value.startsWith(_article) && value.length > _article.length + 1) {
      return {key, SearchKey._(value.substring(_article.length))};
    }
    return {key};
  }

  static const _article = 'ال';

  @override
  bool operator ==(Object other) => other is SearchKey && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'SearchKey($value)';
}

/// `null` drops the rune, `' '` separates words, anything else is kept.
String? _fold(int rune) {
  if (_isDropped(rune)) return null;
  if (rune >= 0x0660 && rune <= 0x0669) {
    return String.fromCharCode(rune - 0x0630); // Arabic-Indic digits
  }
  if (rune >= 0x06F0 && rune <= 0x06F9) {
    return String.fromCharCode(rune - 0x06C0); // Extended Arabic-Indic
  }
  final char = String.fromCharCode(rune);
  final mapped = _letters[char];
  if (mapped != null) return mapped;
  if (_isLetterOrDigit(rune)) return char;
  return ' ';
}

bool _isDropped(int rune) =>
    (rune >= 0x064B && rune <= 0x065F) || // harakat
    rune == 0x0670 || // superscript alef
    rune == 0x0640 || // tatweel
    rune == 0x0027 || // '
    rune == 0x2018 ||
    rune == 0x2019 ||
    rune == 0x02BB ||
    rune == 0x02BC ||
    rune == 0x00B4 ||
    rune == 0x0060;

bool _isLetterOrDigit(int rune) =>
    (rune >= 0x30 && rune <= 0x39) ||
    (rune >= 0x61 && rune <= 0x7A) ||
    (rune >= 0x00DF && rune <= 0x024F && rune != 0x00F7) ||
    (rune >= 0x0370 && rune <= 0x058F) || // Greek, Cyrillic, Armenian
    (rune >= 0x05D0 && rune <= 0x05EA) || // Hebrew letters
    (rune >= 0x0621 && rune <= 0x064A) ||
    (rune >= 0x0671 && rune <= 0x06D3) || // Arabic extended letters
    rune >= 0x0900; // other scripts are kept as they are

/// Single-letter folds (after `toLowerCase`).
final Map<String, String> _letters = {
  for (final MapEntry(:key, :value) in _folds.entries)
    for (final rune in value.runes) String.fromCharCode(rune): key,
  'ß': 'ss',
  'æ': 'ae',
  'œ': 'oe',
  'þ': 'th',
};

/// Target → the letters that fold to it.
const Map<String, String> _folds = {
  'a': 'àáâãäåāăą',
  'c': 'çćĉċč',
  'd': 'ďđð',
  'e': 'èéêëēĕėęě',
  'g': 'ĝğġģ',
  'h': 'ĥħ',
  'i': 'ìíîïĩīĭįı',
  'j': 'ĵ',
  'k': 'ķ',
  'l': 'ĺļľŀł',
  'n': 'ñńņňŉ',
  'o': 'òóôõöøōŏő',
  'r': 'ŕŗř',
  's': 'śŝşšſ',
  't': 'ţťŧ',
  'u': 'ùúûüũūŭůűų',
  'w': 'ŵ',
  'y': 'ýÿŷ',
  'z': 'źżž',
  'ا': 'أإآٱ',
  'ي': 'ىیئ',
  'و': 'ؤ',
  'ه': 'ة',
  'ك': 'ک',
};
