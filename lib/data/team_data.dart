import 'package:json_annotation/json_annotation.dart';
import 'package:teambalancer/common/constants.dart';
import 'package:teambalancer/data/player_data.dart';
part 'team_data.g.dart';

@JsonSerializable()
class TeamData {
  Map<String, dynamic> toJson() => _$TeamDataToJson(this);
  factory TeamData.fromJson(Map<String, dynamic> json) =>
      _$TeamDataFromJson(json);

  int sport;
  Map<String, PlayerData> players;
  Map<Skill, int> weights;
  List<String> tags;

  TeamData(this.sport, this.players, this.weights, this.tags);

  TeamData.init(this.sport, List<String> players)
      : players = {for (var key in players) key: PlayerData.init()},
        weights = {for (var key in Skill.values) key: Constants.defaultWeight},
        tags = [];
}

@JsonSerializable()
class TeamsData {
  Map<String, dynamic> toJson() => _$TeamsDataToJson(this);
  factory TeamsData.fromJson(Map<String, dynamic> json) =>
      _$TeamsDataFromJson(json);

  Map<String, TeamData> teams;

  TeamsData(this.teams);
}
