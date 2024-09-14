import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teambalancer/common/constants.dart';

import 'overall_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.clear();
  });

  tearDown(() async {
    await tearDownTest();
  });

  testWidgets('admin team', (tester) async {
    await tester.quickSetup(
      "Team X",
      Sport.football,
      players: ["P1", "P2", "P3", "P4", "P5", "P6", "P7", "P8"],
      admin: true,
    );

    await tester.launchAndWaitTeam("Team X");
    expect(find.text("Team X"), findsOneWidget);
    expect(find.byIcon(Icons.settings), findsOneWidget);
    expect(find.byIcon(Icons.info_outline), findsNothing);
  });

  testWidgets('test admin demo', (tester) async {
    await tester.loadDemoTeam(admin: true);

    await tester.launchAndWaitTeam("Demo Team");
    expect(find.text("Demo Team"), findsOneWidget);
    await tester.tap(find.byIcon(Icons.history));
    await tester.pumpAndSettle();
    expect(find.text("Thu, Sep 12, 2024"), findsOneWidget);
  });
}
