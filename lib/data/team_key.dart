import 'package:json_annotation/json_annotation.dart';
part 'team_key.g.dart';

@JsonSerializable()
class TeamKey {
  Map<String, dynamic> toJson() => _$TeamKeyToJson(this);
  factory TeamKey.fromJson(Map<String, dynamic> json) =>
      _$TeamKeyFromJson(json);

  String key;
  TeamKey(this.key);
}
