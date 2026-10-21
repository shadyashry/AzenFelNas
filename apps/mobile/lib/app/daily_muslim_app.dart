import 'package:flutter/material.dart';

/// Root widget. Composition root, routing and theming arrive in slice S16
/// (DESIGN.md §7.1); until then it renders an empty surface and no copy.
final class DailyMuslimApp extends StatelessWidget {
  /// Creates the root widget.
  const new({super.key});

  @override
  Widget build(BuildContext context) =>
      const MaterialApp(home: Scaffold(body: SizedBox.shrink()));
}
