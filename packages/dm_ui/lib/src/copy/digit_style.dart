/// How numerals are written (Appendix K `digits`).
enum DigitStyle {
  /// 0–9.
  western,

  /// ٠–٩.
  arabicIndic;

  /// [text] with its western digits written in this style.
  String apply(String text) => switch (this) {
    western => text,
    arabicIndic => String.fromCharCodes(
      text.codeUnits.map(
        (u) => u >= 0x30 && u <= 0x39 ? u - 0x30 + 0x0660 : u,
      ),
    ),
  };
}
