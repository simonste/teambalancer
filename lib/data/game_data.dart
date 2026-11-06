import 'dart:convert';

import 'package:teambalancer/data/backend.dart';
import 'package:teambalancer/data/group_data.dart';
import 'package:teambalancer/data/player_data.dart';

class Game {
  Game({required this.date, required this.groups, required this.historyId});

  DateTime date;
  List<GroupData> groups = [];
  final int historyId;

  /// Index of the group [playerId] plays in, or null if not part of the game.
  int? groupOf(int playerId) {
    for (var groupNo = 0; groupNo < groups.length; groupNo++) {
      if (groups[groupNo].members.values.any((p) => p.playerId == playerId)) {
        return groupNo;
      }
    }
    return null;
  }

  bool contains(int playerId) => groupOf(playerId) != null;

  void moveToGroup(int playerId, int newGroupNo) {
    final groupNo = groupOf(playerId);
    if (groupNo == null || groupNo == newGroupNo) return;
    final members = groups[groupNo].members;
    final name =
        members.keys.firstWhere((n) => members[n]!.playerId == playerId);
    groups[newGroupNo].members[name] = members.remove(name)!;
  }

  void removePlayer(int playerId) {
    for (var group in groups) {
      group.members.removeWhere((_, p) => p.playerId == playerId);
    }
  }

  /// Adds [player] to the smallest group, the first one on a tie.
  void addPlayer(String name, PlayerData player) {
    if (contains(player.playerId)) return;
    var smallest = groups.first;
    for (var group in groups) {
      if (group.members.length < smallest.members.length) smallest = group;
    }
    // a copy: the game keeps the skills the player had when added
    smallest.members[name] = PlayerData.fromJson(player.toJson());
  }

  void remove(Map<String, dynamic> keys) async {
    Map<String, dynamic> body = {
      ...keys,
      'historyId': historyId,
    };
    await Backend.removeGame(jsonEncode(body));
  }

  void save(Map<String, dynamic> keys) async {
    Map<String, dynamic> body = {
      ...keys,
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
