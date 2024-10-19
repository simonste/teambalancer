import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:teambalancer/common/constants.dart';
import 'package:teambalancer/data/backend.dart';
import 'package:teambalancer/data/game_data.dart';
import 'package:teambalancer/data/group_data.dart';
import 'package:teambalancer/data/player_data.dart';
import 'package:teambalancer/data/team_key.dart';
part 'team_data.g.dart';

@JsonSerializable()
class TeamData {
  Map<String, dynamic> toJson() => _$TeamDataToJson(this);
  factory TeamData.fromJson(Map<String, dynamic> json) =>
      _$TeamDataFromJson(json);

  String name;
  int sport;
  Map<String, PlayerData> players;
  Map<Skill, int> weights;
  List<String> tags;
  String teamKey;

  final List<Game> games = [];

  TeamData(
    this.name,
    this.sport,
    this.players,
    this.weights,
    this.tags,
    this.teamKey,
  );

  void loadGames(gamesHistory) {
    games.clear();
    for (var game in gamesHistory ?? []) {
      List<GroupData> groups = [];
      for (var g in game['groupData']) {
        groups.add(GroupData.fromJson(g));
      }

      games.add(Game(
        date: DateTime.parse(game['date']),
        groups: groups,
        historyId: game['historyId'],
      ));
    }
    refreshGames();
  }

  void refreshGames() {
    games.sort((a, b) => a.date.compareTo(b.date));

    players.forEach((player, data) => data.history.clear());
    for (var game in games) {
      players.forEach((player, data) {
        bool played = false;
        for (var g = 0; g < game.groups.length; g++) {
          var renamedPlayers = {};
          game.groups[g].members.forEach((n, member) {
            if (member.playerId == data.playerId) {
              played = true;
              data.history.add(game.getResult(g));
              if (n != player) {
                renamedPlayers[n] = player;
              }
            }
          });

          renamedPlayers.forEach((from, to) {
            final pd = game.groups[g].members.remove(from);
            game.groups[g].members[to] = pd!;
          });
        }
        if (!played) {
          data.history.add(GameResult.miss);
        }
      });
    }
    players.forEach((player, data) => data.updateForm());
  }

  Future<void> addPlayer(String name) async {
    Map<String, dynamic> body = {'name': name, 'teamKey': teamKey};
    final json = await Backend.addPlayer(jsonEncode(body));
    players[name] = PlayerData.fromJson(json);
    players[name]!.updateForm();
  }

  Future<void> removePlayer(String name) async {
    Map<String, dynamic> body = {
      'playerId': players[name]!.playerId,
      'teamKey': teamKey
    };
    players.remove(name);
    await Backend.removePlayer(jsonEncode(body));
  }

  Future<void> renamePlayer(String from, String to) async {
    players[to] = players[from]!;
    players.remove(from);
    Map<String, dynamic> body = {
      'teamKey': teamKey,
      'playerId': players[to]!.playerId,
      'name': to
    };
    refreshGames();
    await Backend.renamePlayer(jsonEncode(body));
  }

  Future<void> setWeight(Skill skill, int value) async {
    weights[skill] = value;

    return _save();
  }

  Future<void> removeTag(String tag) {
    tags.remove(tag);
    for (var player in players.values) {
      player.removeTag(tag, TeamKey(teamKey));
    }
    return _save();
  }

  Future<void> addTag(String tag) {
    tags.add(tag);
    tags.sort();
    return _save();
  }

  Future<void> renameTag(String from, String tag) {
    tags.remove(from);
    for (var player in players.values) {
      player.renameTag(from, tag, TeamKey(teamKey));
    }
    return addTag(tag);
  }

  Future<void> _save() async {
    var json = toJson();
    json.remove('players');
    json['teamKey'] = teamKey;
    await Backend.updateTeam(jsonEncode(json));
  }
}

class TeamsData {
  final Map<String, TeamData> _teams;

  TeamsData(this._teams);

  TeamData team(TeamKey teamKey) {
    return _teams[teamKey.key]!;
  }

  void addTeam(TeamData team) {
    _teams[team.teamKey] = team;
  }

  void removeTeam(TeamKey teamKey) {
    _teams.remove(teamKey.key);
  }

  List<TeamKey> getKeysSortedByName() {
    List<MapEntry<String, TeamData>> sortedEntries = _teams.entries.toList();
    sortedEntries.sort((a, b) => a.value.name.compareTo(b.value.name));
    return sortedEntries.map((e) => TeamKey(e.key)).toList();
  }
}
