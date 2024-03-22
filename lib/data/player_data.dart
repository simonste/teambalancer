import 'package:json_annotation/json_annotation.dart';
import 'package:teambalancer/common/constants.dart';
part 'player_data.g.dart';

@JsonSerializable()
class PlayerData {
  Map<String, dynamic> toJson() => _$PlayerDataToJson(this);
  factory PlayerData.fromJson(Map<String, dynamic> json) =>
      _$PlayerDataFromJson(json);

  Map<Skill, int> skills;
  List<String> tags;

  PlayerData(this.skills, this.tags);
}
