/// The English names of the 114 surahs in Mushaf order (§15 D110), for the
/// interface only (Home's Continue Quran); the Mushaf and its headers are
/// never changed. The common modern transliteration ("Al-Kahf"), each name
/// checked by number against the `tname` of the Tanzil Quran metadata
/// (tanzil.net, CC BY 3.0; the file pinned by sha256 in
/// `data-pipelines/config/quran.v1.toml`): 112 agree letter for letter once
/// doubled vowels are folded, and 40 *Ghafir* and 93 *Ad-Duha* differ only
/// in spelling (Tanzil: *Al-Ghaafir*, *Ad-Dhuhaa*).
abstract final class SurahNames {
  /// The names; surah n is at index n − 1.
  static const List<String> english = [
    'Al-Fatihah', 'Al-Baqarah', "Ali 'Imran", 'An-Nisa', "Al-Ma'idah", //
    "Al-An'am", "Al-A'raf", 'Al-Anfal', 'At-Tawbah', 'Yunus', //
    'Hud', 'Yusuf', "Ar-Ra'd", 'Ibrahim', 'Al-Hijr', //
    'An-Nahl', 'Al-Isra', 'Al-Kahf', 'Maryam', 'Taha', //
    'Al-Anbiya', 'Al-Hajj', "Al-Mu'minun", 'An-Nur', 'Al-Furqan', //
    "Ash-Shu'ara", 'An-Naml', 'Al-Qasas', "Al-'Ankabut", 'Ar-Rum', //
    'Luqman', 'As-Sajdah', 'Al-Ahzab', 'Saba', 'Fatir', //
    'Ya-Sin', 'As-Saffat', 'Sad', 'Az-Zumar', 'Ghafir', //
    'Fussilat', 'Ash-Shura', 'Az-Zukhruf', 'Ad-Dukhan', 'Al-Jathiyah', //
    'Al-Ahqaf', 'Muhammad', 'Al-Fath', 'Al-Hujurat', 'Qaf', //
    'Adh-Dhariyat', 'At-Tur', 'An-Najm', 'Al-Qamar', 'Ar-Rahman', //
    "Al-Waqi'ah", 'Al-Hadid', 'Al-Mujadilah', 'Al-Hashr', 'Al-Mumtahanah', //
    'As-Saff', "Al-Jumu'ah", 'Al-Munafiqun', 'At-Taghabun', 'At-Talaq', //
    'At-Tahrim', 'Al-Mulk', 'Al-Qalam', 'Al-Haqqah', "Al-Ma'arij", //
    'Nuh', 'Al-Jinn', 'Al-Muzzammil', 'Al-Muddaththir', 'Al-Qiyamah', //
    'Al-Insan', 'Al-Mursalat', 'An-Naba', "An-Nazi'at", "'Abasa", //
    'At-Takwir', 'Al-Infitar', 'Al-Mutaffifin', 'Al-Inshiqaq', 'Al-Buruj', //
    'At-Tariq', "Al-A'la", 'Al-Ghashiyah', 'Al-Fajr', 'Al-Balad', //
    'Ash-Shams', 'Al-Layl', 'Ad-Duha', 'Ash-Sharh', 'At-Tin', //
    "Al-'Alaq", 'Al-Qadr', 'Al-Bayyinah', 'Az-Zalzalah', "Al-'Adiyat", //
    "Al-Qari'ah", 'At-Takathur', "Al-'Asr", 'Al-Humazah', 'Al-Fil', //
    'Quraysh', "Al-Ma'un", 'Al-Kawthar', 'Al-Kafirun', 'An-Nasr', //
    'Al-Masad', 'Al-Ikhlas', 'Al-Falaq', 'An-Nas', //
  ];

  /// The English name of surah [number] (1–114); `null` outside the Mushaf.
  static String? englishOf(int number) =>
      number >= 1 && number <= english.length ? english[number - 1] : null;
}
