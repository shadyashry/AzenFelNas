import 'package:meta/meta.dart';

/// Which quarter of its hizb a [HizbQuarter] opens.
enum HizbPart {
  /// The hizb's first quarter: the hizb itself begins.
  start,

  /// The second quarter (ربع الحزب).
  quarter,

  /// The third quarter (نصف الحزب).
  half,

  /// The fourth quarter (ثلاثة أرباع الحزب).
  threeQuarters,
}

/// One of the 240 quarters of a hizb (§15 D123): where it starts, from the
/// Complex's own U+06DE (۞) marks in the package text. The printed Mushaf
/// shows these as medallions in the margin; the frameless pages leave the
/// medallions out and the reader shows the same information beside the
/// page.
@immutable
final class HizbQuarter {
  /// Quarter [number] (1..240), starting at verse [aya] of [sura] on
  /// [page].
  const new({
    required this.number,
    required this.sura,
    required this.aya,
    required this.page,
  });

  /// 1..240 in Mushaf order.
  final int number;

  /// Surah of the first verse.
  final int sura;

  /// The first verse.
  final int aya;

  /// Page of the first verse.
  final int page;

  /// The hizb (1..60).
  int get hizb => (number - 1) ~/ 4 + 1;

  /// Its place in the hizb.
  HizbPart get part => HizbPart.values[(number - 1) % 4];

  /// The quarter that starts on [page], if one does; the last when two do.
  static HizbQuarter? on(List<HizbQuarter> quarters, int page) {
    HizbQuarter? found;
    for (final q in quarters) {
      if (q.page == page) found = q;
      if (q.page > page) break;
    }
    return found;
  }

  @override
  bool operator ==(Object other) =>
      other is HizbQuarter &&
      other.number == number &&
      other.sura == sura &&
      other.aya == aya &&
      other.page == page;

  @override
  int get hashCode => Object.hash(number, sura, aya, page);
}
