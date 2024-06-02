import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:teambalancer/common/constants.dart';
import 'package:teambalancer/data/backend.dart';
import 'package:teambalancer/data/team_key.dart';
part 'player_data.g.dart';

@JsonSerializable()
class PlayerData {
  Map<String, dynamic> toJson() => _$PlayerDataToJson(this);
  factory PlayerData.fromJson(Map<String, dynamic> json) =>
      _$PlayerDataFromJson(json);

  Map<Skill, int> skills;
  List<String> tags;
  int playerId;

  PlayerData(this.skills, this.tags, this.playerId);

  PlayerData.init(this.playerId)
      : skills = {for (var key in Skill.values) key: Constants.defaultSkill},
        tags = [];

  Future<void> setSkill(Skill skill, int value, TeamKey teamKey) async {
    skills[skill] = value;

    var json = toJson();
    json['teamKey'] = teamKey.key;
    await Backend.updatePlayer(jsonEncode(json));
  }

  Future<void> toggleTag(String tag) async {
    if (tags.contains(tag)) {
      tags.remove(tag);
    } else {
      tags.add(tag);
    }
    throw Exception('Backend not implemented');
  }
}
