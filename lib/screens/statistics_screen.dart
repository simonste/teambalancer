import 'package:flutter/material.dart';
import 'package:teambalancer/common/constants.dart';
import 'package:teambalancer/common/localization.dart';
import 'package:teambalancer/common/sorting.dart';
import 'package:teambalancer/common/utils.dart';
import 'package:teambalancer/data/data.dart';
import 'package:teambalancer/data/group_data.dart';
import 'package:teambalancer/data/preference_data.dart';
import 'package:teambalancer/data/team_key.dart';
import 'dart:developer' as developer;

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen(
      {required this.teamKey, required this.data, super.key});

  final TeamKey teamKey;
  final Data data;
  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  PlayerSorting sortingKind = PlayerSorting.name;

  Widget getPlayersTitle(PlayerSorting sortingKind) {
    return ListTile(
        title: Text(context.l10n.players),
        trailing: IconButton(
          icon: const Icon(Icons.sort_by_alpha),
          onPressed: () {
            final nextSortingKind = PlayerSorting
                .values[(sortingKind.index + 1) % PlayerSorting.values.length];
            widget.data.preferenceData.teams[widget.teamKey.key]!
                .playerSorting = nextSortingKind;
            setState(() {});
          },
        ));
  }

  @override
  Widget build(BuildContext context) {
    final team = widget.data.get().team(widget.teamKey);
    final players = team.players;
    developer.log('build team screen ${players.length} players',
        name: 'teambalancer data');

    final sorted = players.keys.toList()
      ..sort((a, b) => sorting(sortingKind, players, a, b));

    var columnHeaders = {
      PlayerSorting.name: Text(context.l10n.name),
      PlayerSorting.games: Text(context.l10n.total, textAlign: TextAlign.right),
      PlayerSorting.won: Text(context.l10n.won, textAlign: TextAlign.right),
      PlayerSorting.lost: Text(context.l10n.lost, textAlign: TextAlign.right),
      PlayerSorting.winPercentage:
          Text(context.l10n.winPercentage, textAlign: TextAlign.right),
      PlayerSorting.form: getSkillIcon(
          Skill.form, 1.8, Sport.values[team.sport],
          color: Theme.of(context).iconTheme.color)
    };

    var headers = columnHeaders.entries.map((entry) {
      var value = entry.value;
      if (sortingKind == entry.key) {
        value = Row(children: [
          Expanded(child: value),
          Icon(
            Icons.south,
            size: 15.0,
          )
        ]);
      }
      return InkWell(
          child: value, onTap: () => setState(() => sortingKind = entry.key));
    }).toList();

    List<TableRow> rows = [TableRow(children: headers)];

    for (var i = 0; i < players.length; i++) {
      final name = sorted[i];
      final player = players[name]!;
      final history = players[name]!.history;

      final won = history.where((gr) => gr == GameResult.won).length;
      final draw = history.where((gr) => gr == GameResult.draw).length;
      final lost = history.where((gr) => gr == GameResult.lost).length;
      final noScore = history.where((gr) => gr == GameResult.noScore).length;
      final caps = won + draw + lost + noScore;
      final winPercentage = (100 * won / (won + lost)).round();
      final form = (player.skills[Skill.form]! * 10).roundToDouble() / 10;

      List<Widget> cells = [];
      cells.add(Text(name));
      cells.add(Text("$caps", textAlign: TextAlign.right));
      cells.add(Text("$won", textAlign: TextAlign.right));
      cells.add(Text("$lost", textAlign: TextAlign.right));
      cells.add(Text("$winPercentage", textAlign: TextAlign.right));
      cells.add(Text("$form", textAlign: TextAlign.right));
      rows.add(TableRow(children: cells));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(team.name),
      ),
      body: Table(
        defaultColumnWidth: FlexColumnWidth(1),
        columnWidths: {0: FlexColumnWidth(2)},
        children: rows,
      ),
    );
  }
}
