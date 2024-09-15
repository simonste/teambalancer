import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'overall_test.dart';

void main() {
  setUp(() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.clear();
  });

  tearDown(() async {});

  testWidgets('test user', (tester) async {
    await tester.launchApp();
    await tester.sendDeepLink("https://teambalancer.simonste.ch/#DEMO99");

    expect(find.text("Demo Team"), findsOneWidget);
    expect(find.byIcon(Icons.settings), findsNothing);
    expect(find.byIcon(Icons.info_outline), findsOneWidget);
  });

  testWidgets('test admin', (tester) async {
    await tester.launchApp();
    await tester.sendDeepLink("https://teambalancer.simonste.ch/#DEMO99DEMO99");

    expect(find.text("Demo Team"), findsOneWidget);
    expect(find.byIcon(Icons.settings), findsOneWidget);
    expect(find.byIcon(Icons.info_outline), findsNothing);
  });
}
