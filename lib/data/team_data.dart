import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:teambalancer/common/constants.dart';
import 'package:teambalancer/data/backend.dart';
import 'package:teambalancer/data/player_data.dart';
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
  String key;

  TeamData(
    this.name,
    this.sport,
    this.players,
    this.weights,
    this.tags,
    this.key,
  );

  Future<void> addPlayer(String name) async {
    Map<String, dynamic> body = {'name': name, 'team': key};
    final json = await Backend.addPlayer(jsonEncode(body));
    players[name] = PlayerData.fromJson(json);
  }

  Future<void> removePlayer(String name) async {
    Map<String, dynamic> body = {'id': players[name]!.id, 'team': key};
    players.remove(name);
    await Backend.removePlayer(jsonEncode(body));
  }

  Future<void> renamePlayer(String from, String to) async {
    players[to] = players[from]!;
    players.remove(from);
    Map<String, dynamic> body = {
      'team': key,
      'id': players[to]!.id,
      'name': to
    };
    await Backend.renamePlayer(jsonEncode(body));
  }

  Future<void> setWeight(Skill skill, int value) async {
    weights[skill] = value;

    var json = toJson();
    json.remove('players');
    json['key'] = key;
    await Backend.updateTeam(jsonEncode(json));
  }
}

@JsonSerializable()
class TeamsData {
  Map<String, dynamic> toJson() => _$TeamsDataToJson(this);
  factory TeamsData.fromJson(Map<String, dynamic> json) =>
      _$TeamsDataFromJson(json);

  Map<String, TeamData> teams;

  TeamsData(this.teams);
}
