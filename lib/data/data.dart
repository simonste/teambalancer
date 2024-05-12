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
  PreferenceData preferenceData = PreferenceData({});
  TeamsData data = TeamsData({});

  void restoreData(notify) async {
    final preferences = await SharedPreferences.getInstance();

    var defaultStr = '{}';
    final str = preferences.getString(_key) ?? defaultStr;
    if (str.length > 2) {
      Map<String, dynamic> json = jsonDecode(str);
      if (json['data_version'] == _dataVersion) {
        preferenceData = PreferenceData.fromJson(json);

        for (var teamKey in preferenceData.teams.keys) {
          var teamData = await getTeamData(teamKey);
          if (teamData.isEmpty) {
            preferenceData.teams.remove(teamKey);
            _save();
          } else {
            data.teams.addAll(teamData);
          }
        }

        String? teamKey;
        // teamKey = "A4GH49";
        if (teamKey != null && teamKey.length == 6) {
          preferenceData.teams[teamKey] = PreferenceTeamData();
          _save();
        }

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
