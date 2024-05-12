import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:teambalancer/common/constants.dart';
import 'package:teambalancer/data/backend.dart';
import 'package:teambalancer/data/preference_data.dart';
import 'package:teambalancer/data/team_data.dart';
import 'dart:developer' as developer;

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
  PreferenceData preferenceData = PreferenceData({});
  TeamsData data = TeamsData({});

  void restoreData(
      {required updateCallback, required String addTeamKey}) async {
    final preferences = await SharedPreferences.getInstance();

    const defaultStr = '{"teams": {}, "data_version": 0.2}';
    final str = preferences.getString(_key) ?? defaultStr;
    Map<String, dynamic> json = jsonDecode(str);
    if (json['data_version'] != _dataVersion) {
      developer.log('reset preference data', name: 'teambalancer data');
      json = jsonDecode(defaultStr);
    }
    developer.log('preference $json', name: 'teambalancer data');

    preferenceData = PreferenceData.fromJson(json);
    if (addTeamKey.length == 6 &&
        !preferenceData.teams.containsKey(addTeamKey)) {
      developer.log('add team $addTeamKey', name: 'teambalancer data');
      preferenceData.teams[addTeamKey] = PreferenceTeamData();
    }

    for (var teamKey in preferenceData.teams.keys) {
      developer.log('check $teamKey', name: 'teambalancer data');
      var teamData = await getTeamData(teamKey);
      if (teamData.isEmpty) {
        developer.log('remove obsolete team $teamKey',
            name: 'teambalancer data');
        preferenceData.teams.remove(teamKey);
      } else {
        developer.log('loaded team $teamKey', name: 'teambalancer data');
        data.teams.addAll(teamData);
      }
    }

    await _save();
    updateCallback();
  }

  Future<void> _save() async {
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
    preferenceData.teams[json['key']] =
        PreferenceTeamData(adminKey: json['admin_key']);
    _save();
  }

  bool isAdmin(String name) {
    final team = data.teams[name]!;
    return preferenceData.teams[team.key]!.adminKey.isNotEmpty;
  }

  Future<void> removeTeam(String name, {bool admin = false}) async {
    final team = data.teams[name]!;
    if (admin) {
      Map<String, dynamic> body = {
        'key': team.key,
        'admin_key': preferenceData.teams[team.key]!.adminKey
      };
      await Backend.removeTeam(jsonEncode(body));
    }
    data.teams.remove(name);
    preferenceData.teams.remove(team.key);
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
