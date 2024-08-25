import 'dart:convert';

import 'package:teambalancer/data/backend.dart';
import 'package:teambalancer/data/player_data.dart';

class Game {
  Game(this.date, groupsIds, this.result, this.historyId, this.players) {
    for (var group in groupsIds) {
      List<String> g = [];
      for (var member in group) {
        if (member > 0) {
          g.add(players.keys.firstWhere((k) => players[k]!.playerId == member));
        } else {
          // invalid member
        }
      }
      groups.add(g..sort());
    }
  }

  DateTime date;
  List<List<String>> groups = [];
  String result;
  int historyId;
  final Map<String, PlayerData> players;

  void moveToNextGroup(name) {
    final groupNo = groups.indexOf(groups.firstWhere((a) => a.contains(name)));
    final newGroupNo = (groupNo + 1) % groups.length;
    groups[newGroupNo].add(name);
    groups[groupNo].remove(name);
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
      for (var member in group) {
        g.add(players[member]!.playerId);
      }
      groupsIds.add(g);
    }

    Map<String, dynamic> body = {
      'historyId': historyId,
      'date': date.toString(),
      'result': result,
      'groups': groupsIds
    };
    await Backend.updateGame(jsonEncode(body));
  }
}
