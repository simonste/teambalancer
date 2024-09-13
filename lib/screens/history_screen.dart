import 'package:flutter/material.dart';
import 'package:teambalancer/common/localization.dart';
import 'package:teambalancer/common/utils.dart';
import 'package:teambalancer/data/backend.dart';
import 'package:teambalancer/data/game_data.dart';
import 'package:teambalancer/data/team_data.dart';
import 'package:teambalancer/screens/game_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen(
      {required this.teamData, required this.isAdmin, super.key});

  final TeamData teamData;
  final bool isAdmin;
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final List<Game> games = [];

  @override
  void initState() {
    super.initState();

    restoreData(updateCallback: () {
      setState(() {});
    });
  }

  void restoreData({required updateCallback}) async {
    final json = await Backend.getHistory(widget.teamData.teamKey);
    final players = widget.teamData.players;

    if (json == null) {
      return;
    }
    for (var game in json) {
      games.add(Game(
        DateTime.parse(game['date']),
        game['groups'],
        game['result'],
        game['historyId'],
        players,
      ));
    }

    updateCallback();
  }

  @override
  Widget build(BuildContext context) {
    final dateFormatter = getDateFormatter(context);
    final timeFormatter = getTimeFormatter(context);

    var listView = ListView.builder(
      itemCount: games.length,
      itemBuilder: (context, index) {
        final game = games[index];

        var groups = <Widget>[];
        final maxGroupSize = game.groups.fold(0, (maxLength, group) {
          return group.members.length > maxLength
              ? group.members.length
              : maxLength;
        });
        for (var i = 0; i < game.groups.length; i++) {
          var column = <Widget>[];
          if (game.groups[i].score != null) {
            column.add(SizedBox(
                child: Text(
              "${game.groups[i].score}",
              style: const TextStyle(fontWeight: FontWeight.w100),
              textScaler: const TextScaler.linear(1.8),
            )));
          }
          for (var j = 0; j < maxGroupSize; j++) {
            var name = game.groups[i].members.length > j
                ? game.groups[i].members[j]
                : "";
            column.add(SizedBox(child: Text(name)));
          }
          groups.add(Expanded(child: Column(children: column)));
        }

        return Card(
          child: ListTile(
            title: Row(children: [
              Text(dateFormatter.format(game.date)),
              const Expanded(child: SizedBox()),
              Text(timeFormatter.format(game.date))
            ]),
            subtitle: Row(
              children: groups,
            ),
            onTap: () => navigateTo(
              context,
              GameScreen(
                game: game,
                teamData: widget.teamData,
                isAdmin: widget.isAdmin,
              ),
              callback: (toRemove) {
                if (toRemove != null) {
                  games.removeWhere((game) {
                    return game.historyId == toRemove;
                  });
                }
                setState(() {});
              },
            ),
          ),
        );
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.teamData.name),
      ),
      body: games.isNotEmpty
          ? listView
          : Center(
              child: Text(context.l10n.noGamesPlayedYet),
            ),
    );
  }
}
