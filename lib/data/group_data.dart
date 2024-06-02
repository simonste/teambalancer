import 'package:json_annotation/json_annotation.dart';
import 'package:teambalancer/common/constants.dart';
part 'group_data.g.dart';

@JsonSerializable()
class GroupData {
  Map<String, dynamic> toJson() => _$GroupDataToJson(this);
  factory GroupData.fromJson(Map<String, dynamic> json) =>
      _$GroupDataFromJson(json);

  final String name;
  final int capacity;
  Map<String, int> members = {};
  Map<Skill, int> skills = {};

  GroupData(this.name, this.capacity)
      : skills = {for (var key in Skill.values) key: 0};

  bool isComplete() {
    return members.length >= capacity;
  }
}
