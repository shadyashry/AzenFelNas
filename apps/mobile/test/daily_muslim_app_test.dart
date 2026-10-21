import 'package:daily_muslim/app/daily_muslim_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('app shell builds without user copy', (tester) async {
    await tester.pumpWidget(const DailyMuslimApp());

    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.byType(Text), findsNothing);
  });
}
