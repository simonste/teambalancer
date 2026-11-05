import 'dart:convert';

import 'package:calc/calc.dart';
import 'package:flutter/material.dart';
import 'package:radar_chart_plus/radar_chart_plus.dart';
import 'package:teambalancer/common/constants.dart';
import 'package:teambalancer/common/localization.dart';
import 'package:teambalancer/data/backend.dart';
import 'package:teambalancer/data/game_data.dart';
import 'package:teambalancer/data/group_data.dart';
import 'package:teambalancer/data/team_data.dart';
import 'package:teambalancer/dialog/result_dialog.dart';
import 'package:teambalancer/widgets/player_card.dart';
import 'package:teambalancer/widgets/score_card.dart';

class GameScreen extends StatefulWidget {
  const GameScreen(
      {required this.game,
      required this.teamData,
      required this.isAdmin,
      super.key});

  final Game game;
  final TeamData teamData;
  final bool isAdmin;
  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  bool _isBusy = false;

  void save() {
    widget.game.save(widget.teamData.keys);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> cols = [
      Row(children: [
        Expanded(
            child: TextButton(
                onPressed: () => dateDialog(widget.game.date),
                child:
                    Text(getDateFormatter(context).format(widget.game.date)))),
        Expanded(
            child: TextButton(
                onPressed: () => timeDialog(widget.game.date),
                child:
                    Text(getTimeFormatter(context).format(widget.game.date)))),
        if (_isBusy)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          )
        else
          IconButton(icon: const Icon(Icons.copy), onPressed: _copyGame),
        widget.isAdmin
            ? IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  widget.game.remove(widget.teamData.keys);
                  Navigator.of(context).pop(widget.game.historyId);
                })
            : const SizedBox()
      ]),
    ];
    final result = widget.game.result();
    if (result.isEmpty) {
      cols.add(ScoreCard(
        context.l10n.addResult,
        theme: Theme.of(context),
        onTap: () => _resultDialog(widget.game.result()),
      ));
    } else {
      var elem = <Widget>[];
      for (var r in result.split(":")) {
        elem.add(Expanded(
            child: ScoreCard(r,
                theme: Theme.of(context), onTap: () => _resultDialog(result))));
      }
      cols.add(Row(children: elem));
    }

    final noOfGroups = widget.game.groups.length;
    final largestGroup =
        widget.game.groups.fold(0, (s, group) => max(s, group.members.length));
    var gridView = GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: noOfGroups,
          mainAxisSpacing: 8.0,
          crossAxisSpacing: 8.0,
          mainAxisExtent: 60,
        ),
        itemCount: noOfGroups * largestGroup,
        itemBuilder: (context, index) {
          final groupNo = index % noOfGroups;
          final members = widget.game.groups[groupNo].members.keys.sorted();
          final playerIdx = (index / noOfGroups).floor();
          if (widget.game.groups[groupNo].members.length <= playerIdx) {
            return const SizedBox();
          }
          final playerName = members.elementAt(playerIdx);
          final playerData = widget.game.groups[groupNo].members[playerName]!;
          return GestureDetector(
              onLongPress: _isBusy
                  ? null
                  : () {
                      widget.game.moveToNextGroup(playerData.playerId);
                      widget.teamData.refreshGames();
                      save();
                    },
              child: PlayerCard(
                playerName,
                data: playerData,
                no: groupNo,
                theme: Theme.of(context),
              ));
        });
    cols.add(Expanded(child: gridView));

    cols.add(Expanded(
        child: RadarChartPlus(
      labels: [
        context.l10n.tactical,
        context.l10n.physical,
        context.l10n.technical,
        context.l10n.form
      ],
      dotTapEnabled: false,
      dataSets: widget.game.groups.map((group) {
        final index = widget.game.groups.indexOf(group);
        final color = PlayerCard.cardColor(index, Theme.of(context));
        return RadarDataSet(
          data: [
            group.skill(Skill.tactical, []),
            group.skill(Skill.physical, []),
            group.skill(Skill.technical, []),
            group.skill(Skill.form, []),
          ],
          fillColor: color.withValues(alpha: 0.3),
          borderColor: color,
        );
      }).toList(),
    )));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.teamData.name),
      ),
      body: Column(children: cols),
    );
  }

  void dateDialog(DateTime time) async {
    var date = await showDatePicker(
        context: context,
        initialDate: time,
        firstDate: DateTime(2020),
        lastDate: DateTime(2049));

    if (date == null) return; // cancelled
    widget.game.date =
        DateTime(date.year, date.month, date.day, time.hour, time.minute);
    widget.teamData.refreshGames();
    save();
  }

  void timeDialog(DateTime time) async {
    var timeOfDay = await showTimePicker(
        context: context, initialTime: TimeOfDay.fromDateTime(time));

    if (timeOfDay == null) return; // cancelled
    widget.game.date = DateTime(
        time.year, time.month, time.day, timeOfDay.hour, timeOfDay.minute);
    widget.teamData.refreshGames();
    save();
  }

  void _resultDialog(String? result) async {
    String? input;
    if (result != null) {
      input = await resultDialog(
        context,
        noOfGroups: widget.game.groups.length,
        result: result,
      );
    }
    if (input == null) return; // empty name not allowed
    widget.game.setResult(input);
    widget.teamData.refreshGames();
    save();
  }

  void _copyGame() async {
    if (_isBusy) return;
    setState(() => _isBusy = true);
    try {
      var groups = widget.game.groups.map((g) {
        return GroupData.cloneWithoutScoresAndStats(g);
      }).toList();

      Map<String, dynamic> body = {
        ...widget.teamData.keys,
        'groupData': groups
      };
      final response = await Backend.addGame(jsonEncode(body));

      final teamData = widget.teamData;
      final isAdmin = widget.isAdmin;

      // Create new game from response instead of re-fetching all games
      final newGame = Game(
        date: DateTime.parse(response['date']),
        groups: groups,
        historyId: response['historyId'],
      );
      teamData.games.add(newGame);
      teamData.refreshGames();

      if (mounted) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) => GameScreen(
                      game: teamData.games.last,
                      teamData: teamData,
                      isAdmin: isAdmin,
                    )),
            // remove all routes except first
            (Route<dynamic> route) => route.settings.name == "/");
      }
    } catch (_) {
      if (mounted) setState(() => _isBusy = false);
      rethrow;
    }
  }
}
