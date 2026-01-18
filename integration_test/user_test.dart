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

  testWidgets('test history', (tester) async {
    await tester.quickSetup(
      "Team X",
      Sport.football,
      players: ["P1", "P2", "P3", "P4", "P5", "P6", "P7", "P8"],
    );

    await tester.launchAndWaitTeam("Team X");
    expect(find.text("Team X"), findsOneWidget);
    expect(find.byIcon(Icons.settings), findsNothing);
    expect(find.byIcon(Icons.info_outline), findsOneWidget);
  });

  testWidgets('test user demo', (tester) async {
    await tester.loadDemoTeam();

    await tester.launchAndWaitTeam("Demo Team");
    expect(find.text("Demo Team"), findsOneWidget);
    await tester.tap(find.byIcon(Icons.history));
    await tester.pumpAndSettle();
    expect(find.text("Thu, Sep 12, 2024"), findsOneWidget);
  });

  testWidgets('test shuffle', (tester) async {
    await tester.quickSetup(
      "Team X",
      Sport.football,
      players: ["P1", "P2", "P3", "P4", "P5", "P6", "P7", "P8"],
    );

    await tester.launchAndWaitTeam("Team X");
    await tester.tap(find.byIcon(Icons.shuffle));
    await tester.pumpAndSettle();

    expect(find.text("8 players"), findsOneWidget);
    await tester.tap(find.text("P3"));
    await tester.tap(find.text("P8"));
    await tester.tap(find.text("P6"));
    await tester.pumpAndSettle();
    expect(find.text("5 players"), findsOneWidget);

    await tester.tap(find.byIcon(Icons.shuffle));
    await tester.pumpAndSettle();

    expect(find.text("Group 1"), findsOneWidget);
    expect(find.text("Group 2"), findsOneWidget);

    await tester.tap(find.byIcon(Icons.save));
    await tester.pumpAndSettle();

    // Wait for the game screen to load
    await tester.pumpAndSettle(const Duration(seconds: 2));

    await tester.tap(find.text("Add result"));
    await tester.pumpAndSettle();

    await tester.scrollNumberPicker('picker_0', 5);
    await tester.scrollNumberPicker('picker_1', 3);
    await tester.tap(find.text("Ok"));

    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip("Back"));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.history));
    await tester.pumpAndSettle();

    expect(find.text("5"), findsOneWidget);
    expect(find.text("3"), findsOneWidget);

    await tester.tap(find.byTooltip("Back"));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.shuffle));
    await tester.pumpAndSettle();

    expect(find.text("5 players"), findsOneWidget);
  });
}
