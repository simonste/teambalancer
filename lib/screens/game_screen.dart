import 'package:flutter/material.dart';
import 'package:teambalancer/common/localization.dart';
import 'package:teambalancer/data/game_data.dart';
import 'package:teambalancer/data/team_data.dart';
import 'package:teambalancer/dialog/string_dialog.dart';
import 'package:teambalancer/widgets/player_card.dart';

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

    final noOfGroups = widget.game.groups.length;
    var noOfPlayers =
        widget.game.groups.fold(0, (s, group) => s + group.length);
    var gridView = GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: noOfGroups,
          mainAxisSpacing: 8.0,
          crossAxisSpacing: 8.0,
          childAspectRatio: 3 / 1,
        ),
        itemCount: noOfPlayers,
        itemBuilder: (context, index) {
          final groupNo = index % noOfGroups;
          final playerIdx = (index / noOfGroups).floor();
          final name = widget.game.groups[groupNo][playerIdx];
          return PlayerCard(name, no: groupNo, theme: Theme.of(context));
        });

    cols.add(InkWell(
        onTap: () => dialog(widget.game.result),
        child: Text(context.l10n.result + ": " + widget.game.result)));
    cols.add(Expanded(child: gridView));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.teamData.name),
      ),
      body: Column(children: cols),
    );
  }

  void dialog(String? defaultText) async {
    String? input;
    if (defaultText != null) {
      input = await stringDialog(
        context,
        title: context.l10n.result,
        defaultText: defaultText,
      );
    } else {
      input = await stringDialog(context,
          title: context.l10n.createPlayer, hintText: context.l10n.playerName);
    }
    if (input == null) return; // empty name not allowed
    // if (defaultText != null) {
    //   if (team.players.containsKey(input)) {
    //     return;
    //   }
    //   team.renamePlayer(defaultText, input);
    // } else {
    //   await team.addPlayer(input);
    // }
    widget.game.result = input;
    widget.game.setResult(widget.game.result);
    setState(() {});
  }
}
