import 'package:dm_ui/src/rawdah/rawdah_tab.dart';
import 'package:meta/meta.dart';

/// One destination's label.
@immutable
final class RawdahTabLabels {
  /// The six labels, already localised.
  const new({
    required this.home,
    required this.quran,
    required this.radio,
    required this.qibla,
    required this.athan,
    required this.settings,
  });

  /// Home.
  final String home;

  /// Quran.
  final String quran;

  /// Radio.
  final String radio;

  /// Qibla.
  final String qibla;

  /// Athan.
  final String athan;

  /// Settings.
  final String settings;

  /// The label of [tab].
  String of(RawdahTab tab) => switch (tab) {
    RawdahTab.home => home,
    RawdahTab.quran => quran,
    RawdahTab.radio => radio,
    RawdahTab.qibla => qibla,
    RawdahTab.athan => athan,
    RawdahTab.settings => settings,
  };
}
