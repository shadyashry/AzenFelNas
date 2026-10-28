import 'package:dm_ui/src/rawdah/rawdah_tab.dart';
import 'package:meta/meta.dart';

/// One destination's label.
@immutable
final class RawdahTabLabels {
  /// The four labels, already localised.
  const new({
    required this.home,
    required this.qibla,
    required this.athan,
    required this.settings,
  });

  /// Home.
  final String home;

  /// Qibla.
  final String qibla;

  /// Athan.
  final String athan;

  /// Settings.
  final String settings;

  /// The label of [tab].
  String of(RawdahTab tab) => switch (tab) {
    RawdahTab.home => home,
    RawdahTab.qibla => qibla,
    RawdahTab.athan => athan,
    RawdahTab.settings => settings,
  };
}
