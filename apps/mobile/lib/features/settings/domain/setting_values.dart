/// `locale` (Appendix K).
enum LocaleSetting {
  /// Arabic (Egyptian tone, §7.11).
  ar,

  /// English.
  en,

  /// The device language when it is Arabic or English, else English.
  system,
}

/// `digits` (Appendix K).
enum DigitsSetting {
  /// The digits of the displayed language.
  locale,

  /// 0–9.
  western,

  /// ٠–٩.
  arabicIndic,
}

/// `themeMode` (Appendix K).
enum ThemeModeSetting {
  /// The sky header follows the sun (Appendix G); content follows the system.
  sky,

  /// Light content theme.
  light,

  /// Dark content theme.
  dark,

  /// Follows the system.
  system,
}
