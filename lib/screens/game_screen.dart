import 'package:flutter/material.dart';
import 'package:teambalancer/common/localization.dart';
import 'package:teambalancer/data/game_data.dart';
import 'package:teambalancer/data/team_data.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({required this.game, required this.teamData, super.key});

  final Game game;
  final TeamData teamData;
  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  @override
  Widget build(BuildContext context) {
    final dateFormatter = getDateFormatter(context);

    List<Widget> cols = [Text(dateFormatter.format(widget.game.date))];
    cols.add(IconButton(
        icon: const Icon(Icons.delete),
        onPressed: () {
          widget.game.remove(widget.teamData.teamKey);
          Navigator.of(context).pop();
        }));
    cols.add(Row(
        children: widget.game.groups
            .map((group) => Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: group.map((name) => Text(name)).toList()))
            .toList()));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.teamData.name),
      ),
      body: Column(children: cols),
    );
  }
}
