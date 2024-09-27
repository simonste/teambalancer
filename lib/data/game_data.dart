import 'dart:convert';

import 'package:teambalancer/data/backend.dart';
import 'package:teambalancer/data/group_data.dart';

class Game {
  Game({required this.date, required this.groups, required this.historyId});

  DateTime date;
  List<GroupData> groups = [];
  final int historyId;

  void moveToNextGroup(int playerId) {
    for (var groupNo = 0; groupNo < groups.length; groupNo++) {
      for (var playerName in groups[groupNo].members.keys) {
        if (groups[groupNo].members[playerName]!.playerId == playerId) {
          final newGroupNo = (groupNo + 1) % groups.length;
          groups[newGroupNo].members[playerName] =
              groups[groupNo].members.remove(playerName)!;
          return;
        }
      }
    }
  }

  void remove(teamKey) async {
    Map<String, dynamic> body = {
      'teamKey': teamKey,
      'historyId': historyId,
    };
    await Backend.removeGame(jsonEncode(body));
  }

  void save() async {
    Map<String, dynamic> body = {
      'historyId': historyId,
      'date': date.toString(),
      'groupData': groups
    };
    await Backend.updateGame(jsonEncode(body));
  }

  String result() {
    var res = "";
    for (var group in groups) {
      if (group.score != null) {
        if (res.isNotEmpty) {
          res += ":";
        }
        res += "${group.score}";
      }
    }
    return res;
  }

  GameResult getResult(int groupNo) {
    var scores = groups.map((g) => g.score).toList();
    if (scores.any((s) => s == null)) {
      return GameResult.noScore;
    }
    var sortedScores = List.from(scores);
    sortedScores.sort((a, b) => b.compareTo(a));

    if (scores[groupNo]! < sortedScores[0]) {
      return GameResult.lost;
    } else if (sortedScores[0] == sortedScores[1]) {
      return GameResult.draw;
    } else {
      return GameResult.won;
    }
  }

  void setResult(String result) {
    var scores =
        result.isEmpty ? [] : result.split(":").map(int.parse).toList();
    if (scores.length == groups.length) {
      for (int i = 0; i < scores.length; i++) {
        groups[i].score = scores[i];
      }
    }
  }
}
