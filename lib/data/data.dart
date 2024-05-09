import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:teambalancer/common/constants.dart';
import 'package:teambalancer/data/backend.dart';
import 'package:teambalancer/data/preference_data.dart';
import 'package:teambalancer/data/team_data.dart';

Future<Map<String, TeamData>> getTeamData(String key) async {
  final json = await Backend.getTeam(key);
  if (json.isEmpty) {
    // e.g. team removed from server
    return {};
  }
  return {json['name']: TeamData.fromJson(json)};
}

class Data {
  final _dataVersion = 0.2;
  final _key = "data";
  PreferenceData preferenceData = PreferenceData([]);
  TeamsData data = TeamsData({});

  void restoreData(notify) async {
    final preferences = await SharedPreferences.getInstance();

    var defaultStr = '{}';
    final str = preferences.getString(_key) ?? defaultStr;
    if (str.length > 2) {
      Map<String, dynamic> json = jsonDecode(str);
      if (json['data_version'] == _dataVersion) {
        preferenceData = PreferenceData.fromJson(json);

        List<PreferenceTeamData> obsoleteTeams = [];
        for (var team in preferenceData.teams) {
          var teamData = await getTeamData(team.key);
          if (teamData.isEmpty) {
            obsoleteTeams.add(team);
          } else {
            data.teams.addAll(teamData);
          }
        }
        for (var team in obsoleteTeams) {
          // teams deleted from server
          preferenceData.teams.remove(team);
        }
        notify();
      } else {
        preferenceData.teams.add(PreferenceTeamData('A4GH4902'));
        _save();
        notify();
      }
    }
  }

  void _save() async {
    var json = preferenceData.toJson();
    json['data_version'] = _dataVersion;
    final str = jsonEncode(json);
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_key, str);
  }

  TeamsData get() {
    return data;
  }

  Future<void> addTeam(String name, Sport sport) async {
    Map<String, dynamic> body = {'name': name, 'sport': sport.index};
    final json = await Backend.addTeam(jsonEncode(body));
    data.teams[name] = TeamData.fromJson(json);
    preferenceData.teams
        .add(PreferenceTeamData(json['key'], adminKey: json['admin_key']));
    _save();
  }

  bool isAdmin(String name) {
    final team = data.teams[name]!;
    return preferenceData.teams
        .firstWhere((el) => el.key == team.key)
        .adminKey
        .isNotEmpty;
  }

  Future<void> removeTeam(String name, {bool admin = false}) async {
    if (admin) {
      final team = data.teams[name]!;
      Map<String, dynamic> body = {
        'key': team.key,
        'admin_key': preferenceData.teams
            .firstWhere((el) => el.key == team.key)
            .adminKey,
      };
      await Backend.removeTeam(jsonEncode(body));
    }
    data.teams.remove(name);
    _save();
  }

  Future<void> renameTeam(String from, String to, Sport sport) async {
    final team = data.teams[from]!;
    team.sport = sport.index;
    if (to != from) {
      data.teams[to] = team;
      data.teams.remove(from);
    }
    Map<String, dynamic> body = {
      'key': team.key,
      'name': to,
      'sport': sport.index
    };
    await Backend.renameTeam(jsonEncode(body));
  }
}
