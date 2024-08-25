import 'package:flutter/material.dart';
import 'package:teambalancer/common/localization.dart';
import 'package:teambalancer/common/utils.dart';
import 'package:teambalancer/data/backend.dart';
import 'package:teambalancer/data/game_data.dart';
import 'package:teambalancer/data/team_data.dart';
import 'package:teambalancer/screens/game_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({required this.teamData, super.key});

  final TeamData teamData;
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
    final dateFormatter = getDateTimeFormatter(context);

    var listView = ListView.builder(
      itemCount: games.length,
      itemBuilder: (context, index) {
        final game = games[index];

        return Card(
          child: ListTile(
            title: Row(children: [
              Text("${dateFormatter.format(game.date)} ${game.result}")
            ]),
            subtitle: Row(
                children: game.groups
                    .map((group) => Expanded(
                        child: Column(
                            children: group
                                .map((name) => SizedBox(child: Text(name)))
                                .toList())))
                    .toList()),
            onTap: () => navigateTo(
              context,
              GameScreen(
                game: game,
                teamData: widget.teamData,
              ),
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
