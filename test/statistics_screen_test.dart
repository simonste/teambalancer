import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teambalancer/common/constants.dart';
import 'package:teambalancer/common/localization.dart';
import 'package:teambalancer/data/data.dart';
import 'package:teambalancer/data/group_data.dart';
import 'package:teambalancer/data/player_data.dart';
import 'package:teambalancer/data/preference_data.dart';
import 'package:teambalancer/data/team_data.dart';
import 'package:teambalancer/data/team_key.dart';
import 'package:teambalancer/screens/statistics_screen.dart';

void main() {
  const teamKey = "ABCDEF";

  /// [results] per player: won, lost, missed games
  Data createData(Map<String, List<int>> results) {
    final players = <String, PlayerData>{};
    var id = 1;
    results.forEach((name, r) {
      final player = PlayerData({for (var s in Skill.values) s: 3.0}, [], id++);
      player.history = [
        for (var i = 0; i < r[0]; i++) GameResult.won,
        for (var i = 0; i < r[1]; i++) GameResult.lost,
        for (var i = 0; i < r[2]; i++) GameResult.miss,
      ];
      player.updateForm();
      players[name] = player;
    });
    final data = Data();
    data.data.addTeam(TeamData("Team", 1, players, {}, [], teamKey));
    data.preferenceData = PreferenceData({teamKey: PreferenceTeamData()});
    return data;
  }

  Future<void> pumpScreen(WidgetTester tester, Data data) async {
    // a small phone
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: StatisticsScreen(teamKey: TeamKey(teamKey), data: data),
    ));
    await tester.pumpAndSettle();
  }

  List<String> namesInOrder(WidgetTester tester, List<String> names) {
    final found = names.map((n) => (n, tester.getTopLeft(find.text(n)).dy));
    return (found.toList()..sort((a, b) => a.$2.compareTo(b.$2)))
        .map((e) => e.$1)
        .toList();
  }

  testWidgets('fits a small phone without overflow', (tester) async {
    await pumpScreen(
        tester,
        createData({
          "Christopher Robinson-Smith": [123, 456, 7],
          "Anna": [0, 0, 3],
          for (var i = 0; i < 30; i++) "Player $i": [i, 30 - i, 0],
        }));

    expect(tester.takeException(), isNull);
    expect(find.text("Anna"), findsOneWidget);
    // no decided game: no win percentage
    expect(find.text("–"), findsOneWidget);
    // many players scroll vertically
    expect(find.byType(ListView), findsOneWidget);
  });

  testWidgets('sort by a column and reverse on a second tap', (tester) async {
    await pumpScreen(
        tester,
        createData({
          "Bea": [5, 1, 0],
          "Cid": [1, 5, 0],
          "Ada": [3, 3, 0],
          "Dan": [0, 0, 6],
        }));
    final names = ["Ada", "Bea", "Cid", "Dan"];
    expect(namesInOrder(tester, names), ["Ada", "Bea", "Cid", "Dan"]);

    await tester.tap(find.text("Name"));
    await tester.pumpAndSettle();
    expect(namesInOrder(tester, names), ["Dan", "Cid", "Bea", "Ada"]);

    // highest win percentage first, without a decided game last
    await tester.tap(find.text("%"));
    await tester.pumpAndSettle();
    expect(namesInOrder(tester, names), ["Bea", "Ada", "Cid", "Dan"]);

    await tester.tap(find.text("%"));
    await tester.pumpAndSettle();
    expect(namesInOrder(tester, names), ["Dan", "Cid", "Ada", "Bea"]);
  });
}
