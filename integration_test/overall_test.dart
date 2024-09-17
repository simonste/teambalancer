import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg_test/flutter_svg_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teambalancer/common/constants.dart';
import 'package:teambalancer/common/utils.dart';
import 'package:teambalancer/data/backend.dart';
import 'package:teambalancer/data/data.dart';
import 'package:teambalancer/data/team_data.dart';
import 'package:teambalancer/data/team_key.dart';
import 'package:teambalancer/main.dart' as app;

String? text(Key key, {int? elementNo}) {
  var elements = find.byKey(key).evaluate();
  Text textWidget;
  if (elementNo == null) {
    textWidget = elements.single.widget as Text;
  } else {
    textWidget = elements.elementAt(elementNo).widget as Text;
  }
  return textWidget.data;
}

List<String> testTeams = [];
Future<void> tearDownTest() async {
  for (var testTeam in testTeams) {
    await Backend.removeTeam(testTeam);
  }
  testTeams.clear();
}

extension AppHelper on WidgetTester {
  Future<void> launchApp() async {
    app.main();
    // pump and wait for AppBar to assure app is launched
    await pumpAndSettle();
    await waitFor(() => find.byType(AppBar).evaluate().isEmpty);
  }

  Future<void> waitFor(fun) async {
    while (fun()) {
      await Future.delayed(const Duration(milliseconds: 100));
      await pumpAndSettle();
    }
  }

  Future<void> waitForString(string) async {
    await waitFor(() => find.text(string).evaluate().isEmpty);
  }

  Future<void> launchAndWaitTeam(team) async {
    await launchApp();
    await waitForString(team);
  }

  Future<void> sendDeepLink(String link) async {
    final binding = WidgetsFlutterBinding.ensureInitialized();
    binding.handlePushRoute(link);
    await pumpAndSettle();
  }

  Future<void> slideTo(Skill skill, int value) async {
    final slider = find.byKey(Key(skill.name));
    final prefSlider = slider.evaluate().single.widget as Slider;
    const sliderPadding = 24;
    final totalWidth = getSize(slider).width - 2 * sliderPadding;
    final range = prefSlider.max - prefSlider.min;
    final distancePerIncrement = (totalWidth / range);
    final ticksFromCenter = prefSlider.value - prefSlider.min - (range / 2);
    final currentOffsetFromCenter = ticksFromCenter * distancePerIncrement;
    final sliderPos = getCenter(slider) + Offset(currentOffsetFromCenter, 0);
    final slideTicks = value - prefSlider.value;
    final offsetFromCurrent = slideTicks * distancePerIncrement;
    // overshoot seems to be necessary
    final overshoot = offsetFromCurrent.sign * 0.1 * distancePerIncrement;
    await dragFrom(sliderPos, Offset(offsetFromCurrent + overshoot, 0));
    await pumpAndSettle();
    expect((slider.evaluate().single.widget as Slider).value, value);
  }

  Future<void> addTeam(String teamName, Sport sport) async {
    await tap(find.byType(FloatingActionButton));
    await pumpAndSettle();
    expect(find.byType(TextField), findsOneWidget);
    await enterText(find.byType(TextField), teamName);
    await pumpAndSettle();
    await tap(find.svgAssetWithPath(getAsset(sport)));
    await pump();
    await tap(find.text('Ok'));
    await pumpAndSettle();
    await waitForString(teamName);
  }

  Future<void> deleteTeam(String teamName) async {
    await longPress(find.text(teamName));
    await pumpAndSettle();
    await tap(find.byIcon(Icons.delete));
    await pumpAndSettle();
    await tap(find.text('Delete for everyone'));
    await pumpAndSettle();
    await waitFor(() => find.text(teamName).evaluate().isNotEmpty);
  }

  Future<void> addPlayer(String playerName) async {
    await tap(find.byType(FloatingActionButton));
    await pumpAndSettle();
    await enterText(find.byType(TextField), playerName);
    await pump();
    await tap(find.text('Ok'));
    await pumpAndSettle();
    await waitForString(playerName);
  }

  Future<void> renamePlayer(String currentName, String newName) async {
    await longPress(find.text(currentName));
    await pumpAndSettle();
    await enterText(find.byType(TextField), newName);
    await pump();
    await tap(find.text('Ok'));
    await pumpAndSettle();
  }

  Future<void> deletePlayer(String playerName) async {
    await longPress(find.text(playerName));
    await pumpAndSettle();
    await tap(find.byIcon(Icons.delete));
    await pumpAndSettle();
  }

  Future<void> quickSetup(
    String teamName,
    Sport sport, {
    required List<String> players,
    bool admin = false,
  }) async {
    Map<String, dynamic> body = {'name': teamName, 'sport': sport.index};
    final json = await Backend.addTeam(jsonEncode(body));
    final teamData = TeamData.fromJson(json);
    for (var p in players) {
      await teamData.addPlayer(p);
    }
    expect(teamData.players.length, players.length);

    await Data().restoreData(
      updateCallback: () {},
      addTeamKey: admin
          ? TeamKey(json['teamKey'] + json['adminKey'])
          : TeamKey(json['teamKey']),
    );
    testTeams.add(
        jsonEncode({'teamKey': json['teamKey'], 'adminKey': json['adminKey']}));
  }

  Future<void> loadDemoTeam({bool admin = false}) async {
    await Data().restoreData(
      updateCallback: () {},
      addTeamKey: admin ? TeamKey("DEMO99DEMO99") : TeamKey("DEMO99"),
    );
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.clear();
  });

  testWidgets('create team', (tester) async {
    await tester.launchApp();

    await tester.addTeam("Team", Sport.floorball);

    expect(find.text("Team"), findsOneWidget);
    expect(find.svgAssetWithPath(getAsset(Sport.floorball)), findsOneWidget);

    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();

    await tester.addPlayer("Player one");
    await tester.addPlayer("Player two");
    await tester.addPlayer("Player three");
    await tester.addPlayer("Player four");

    await tester.tap(find.text("Player one"));
    await tester.pumpAndSettle();

    await tester.tap(find.svgAssetWithPath(getAsset(Tactics.defense)));
    await tester.slideTo(Skill.physical, 4);
    await tester.slideTo(Skill.technical, 1);
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip("Back"));
    await tester.pumpAndSettle();
    expect(find.svgAssetWithPath(getAsset(Tactics.defense)), findsOneWidget);

    await tester.addPlayer("Player six");
    await tester.renamePlayer("Player six", "Player five");
    expect(find.text("Player five"), findsOneWidget);
    await tester.deletePlayer("Player five");
    expect(find.text("Player five"), findsNothing);

    await tester.tap(find.byTooltip("Back"));
    await tester.pumpAndSettle();

    await tester.tap(find.text("Team"));
    await tester.pumpAndSettle();

    await tester.tap(find.text("Player three"));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.text("Group 1"), findsOneWidget);
    expect(find.text("Player three"), findsNothing);

    await tester.tap(find.byTooltip("Back"));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip("Back"));
    await tester.pumpAndSettle();
    await tester.deleteTeam("Team");

    expect(find.text("Team"), findsNothing);
  });
}
