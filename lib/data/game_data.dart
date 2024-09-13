import 'dart:convert';

import 'package:teambalancer/data/backend.dart';
import 'package:teambalancer/data/player_data.dart';

class Group {
  Group(this.members, {this.score});

  int? score;
  List<String> members;
}

class Game {
  Game(this.date, groupsIds, result, this.historyId, this.players) {
    for (var group in groupsIds) {
      List<String> members = [];
      for (var member in group) {
        if (member > 0) {
          members.add(
              players.keys.firstWhere((k) => players[k]!.playerId == member));
        } else {
          // invalid member
        }
      }
      groups.add(Group(members..sort()));
    }
    setResult(result);
  }

  DateTime date;
  List<Group> groups = [];
  int historyId;
  final Map<String, PlayerData> players;

  void moveToNextGroup(name) {
    final groupNo =
        groups.indexOf(groups.firstWhere((a) => a.members.contains(name)));
    final newGroupNo = (groupNo + 1) % groups.length;
    groups[newGroupNo].members.add(name);
    groups[groupNo].members.remove(name);
  }

  void remove(teamKey) async {
    Map<String, dynamic> body = {
      'teamKey': teamKey,
      'historyId': historyId,
    };
    await Backend.removeGame(jsonEncode(body));
  }

  void save() async {
    List<List<int>> groupsIds = [];
    for (var group in groups) {
      List<int> g = [];
      for (var member in group.members) {
        g.add(players[member]!.playerId);
      }
      groupsIds.add(g);
    }

    Map<String, dynamic> body = {
      'historyId': historyId,
      'date': date.toString(),
      'result': result(),
      'groups': groupsIds
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

  void setResult(String result) {
    var scores = result.split(":");
    if (scores.length == groups.length) {
      for (int i = 0; i < scores.length; i++) {
        groups[i].score = int.parse(scores[i]);
      }
    }
  }
}
