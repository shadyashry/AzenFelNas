import 'package:daily_muslim/features/contexts/presentation/manual_place_view.dart';
import 'package:daily_muslim/features/shell/domain/app_route.dart';
import 'package:daily_muslim/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// The Manual place screen (§18.4): pins a place and returns to Home.
final class ManualPlacePage extends StatelessWidget {
  /// The page.
  const new({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(AppLocalizations.of(context).placeTitle)),
    body: ManualPlaceView(
      onPinned: (_) => context.go(const HomeRoute().location),
    ),
  );
}
