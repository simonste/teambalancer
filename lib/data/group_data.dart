import 'package:json_annotation/json_annotation.dart';
import 'package:teambalancer/common/constants.dart';
import 'package:teambalancer/data/player_data.dart';
part 'group_data.g.dart';

enum GameResult { noScore, won, lost, draw, miss }

@JsonSerializable()
class GroupData {
  Map<String, dynamic> toJson() => _$GroupDataToJson(this);
  factory GroupData.fromJson(Map<String, dynamic> json) =>
      _$GroupDataFromJson(json);

  final String name;
  Map<String, PlayerData> members = {};
  Map<Skill, int> weights;
  int? score;

  GroupData(this.name, this.weights);

  double skill(Skill skill, List<String> ignoredMembers) {
    var val = 0.0;
    for (var playerName in members.keys) {
      if (!ignoredMembers.contains(playerName)) {
        val += weights[skill]! * members[playerName]!.skills[skill]!;
      }
    }
    return val;
  }

  @override
  String toString() {
    return members.keys.fold("", (str, k) => str + k);
  }
}
