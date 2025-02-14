import 'package:flutter/material.dart';
import 'package:teambalancer/data/group_data.dart';

class PlayerHistory extends StatelessWidget {
  final List<GameResult> history;

  const PlayerHistory(this.history, {super.key});

  @override
  Widget build(BuildContext context) {
    var row = <Widget>[];

    getColor(gameResult) {
      switch (gameResult) {
        case GameResult.won:
          return Colors.green;
        case GameResult.lost:
          return Colors.red;
        case GameResult.draw:
          return Colors.yellow;
        case GameResult.miss:
        case GameResult.noScore:
          return Colors.black;
      }
    }

    for (int i = 0; i < history.length; i++) {
      row.add(Container(
        width: 10,
        height: 3,
        decoration: BoxDecoration(
            color: getColor(history[i]),
            border:
                const Border(right: BorderSide(color: Colors.white, width: 1))),
      ));
    }
    return SizedBox(
        child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      reverse: true,
      child: Row(children: row),
    ));
  }
}
