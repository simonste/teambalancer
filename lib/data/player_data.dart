import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:teambalancer/common/constants.dart';
import 'package:teambalancer/data/backend.dart';
import 'package:teambalancer/data/game_data.dart';
import 'package:teambalancer/data/team_key.dart';
part 'player_data.g.dart';

@JsonSerializable()
class PlayerData {
  Map<String, dynamic> toJson() => _$PlayerDataToJson(this);
  factory PlayerData.fromJson(Map<String, dynamic> json) =>
      _$PlayerDataFromJson(json);

  Map<Skill, double> skills;
  List<String> tags;
  int playerId;

  @JsonKey(includeFromJson: false, includeToJson: false)
  late List<GameResult> history = [];

  PlayerData(this.skills, this.tags, this.playerId);

  PlayerData.init(this.playerId)
      : skills = {for (var key in Skill.values) key: Constants.defaultSkill},
        tags = [];

  Future<void> setSkill(Skill skill, int value, TeamKey teamKey) async {
    skills[skill] = value.toDouble();

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

  void updateForm() {
    const checkWindow = 10;
    var form = 0.0;
    for (int i = 0; i < checkWindow; i++) {
      if (history.length > i) {
        final gameWeight = 0.1 * (checkWindow - i);
        switch (history[history.length - i - 1]) {
          case GameResult.won:
            form += gameWeight;
            break;
          case GameResult.draw:
            form += 0.5 * gameWeight;
            break;
          case GameResult.lost:
          case GameResult.miss:
          case GameResult.noScore:
        }
      }
    }
    skills[Skill.form] = (form * 10).roundToDouble() / 10;
  }

  double getWinPercentage() {
    int wins = history.where((element) => element == GameResult.won).length;
    int lost = history.where((element) => element == GameResult.lost).length;
    return wins / (wins + lost);
  }
}
