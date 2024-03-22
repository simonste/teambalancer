import 'package:json_annotation/json_annotation.dart';
import 'package:teambalancer/common/constants.dart';
import 'package:teambalancer/data/player_data.dart';
part 'team_data.g.dart';

@JsonSerializable()
class TeamData {
  Map<String, dynamic> toJson() => _$TeamDataToJson(this);
  factory TeamData.fromJson(Map<String, dynamic> json) =>
      _$TeamDataFromJson(json);

  Sport sport;
  Map<String, PlayerData> players;
  Map<Skill, int> factors;
  List<String> tags;

  TeamData(this.sport, this.players, this.factors, this.tags);
}

@JsonSerializable()
class TeamsData {
  Map<String, dynamic> toJson() => _$TeamsDataToJson(this);
  factory TeamsData.fromJson(Map<String, dynamic> json) =>
      _$TeamsDataFromJson(json);

  Map<String, TeamData> teams;

  TeamsData(this.teams);
}
