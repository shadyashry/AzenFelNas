import 'package:dm_ui/dm_ui.dart';
import 'package:flutter/material.dart';
import 'package:geo_salah_core/geo_salah_core.dart';

/// A Home-like composition of every S15 component: the sky header over a
/// static content surface with time rows, in one brightness and direction.
final class HomeSample extends StatelessWidget {
  /// Creates the sample.
  const new({
    required this.phase,
    required this.brightness,
    required this.direction,
    super.key,
  });

  /// Sky phase.
  final SkyPhase phase;

  /// Content brightness.
  final Brightness brightness;

  /// Layout direction; RTL uses the Arabic copy.
  final TextDirection direction;

  StatusLocale get _locale => switch (direction) {
    TextDirection.ltr => StatusLocale.en,
    TextDirection.rtl => StatusLocale.ar,
  };

  @override
  Widget build(BuildContext context) {
    final rtl = direction == TextDirection.rtl;
    final digits = rtl ? DigitStyle.arabicIndic : DigitStyle.western;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: DmTheme.of(brightness, _locale),
      home: Directionality(
        textDirection: direction,
        child: Scaffold(
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SkyHeader(
                sky: SkyTheme.forPhase(phase),
                title: rtl ? 'العصر' : 'Asr',
                subtitle: rtl ? 'بعد ساعة' : 'in 1 h',
              ),
              TimeRow(
                eventName: rtl ? 'الظهر' : 'Dhuhr',
                timeText: '12:04',
                label: const ConfidenceLabel.calculated(),
                locale: _locale,
                digits: digits,
              ),
              TimeRow(
                eventName: rtl ? 'العشاء' : 'Isha',
                timeText: '19:41',
                label: const ConfidenceLabel.estimated(rangeMinutes: 5),
                locale: _locale,
                digits: digits,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
