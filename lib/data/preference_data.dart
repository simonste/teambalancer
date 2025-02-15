import 'package:json_annotation/json_annotation.dart';
part 'preference_data.g.dart';

enum PlayerSorting { name, form, games, won, lost, winPercentage }

@JsonSerializable()
class PreferenceTeamData {
  Map<String, dynamic> toJson() => _$PreferenceTeamDataToJson(this);
  factory PreferenceTeamData.fromJson(Map<String, dynamic> json) =>
      _$PreferenceTeamDataFromJson(json);

  String adminKey;
  PlayerSorting playerSorting;

  PreferenceTeamData(
      {this.adminKey = '', this.playerSorting = PlayerSorting.name});
}

@JsonSerializable()
class PreferenceData {
  Map<String, dynamic> toJson() => _$PreferenceDataToJson(this);
  factory PreferenceData.fromJson(Map<String, dynamic> json) =>
      _$PreferenceDataFromJson(json);

  Map<String, PreferenceTeamData> teams;

  PreferenceData(this.teams);
}
