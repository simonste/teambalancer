import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:teambalancer/common/constants.dart';
import 'package:teambalancer/data/backend.dart';
import 'package:teambalancer/data/preference_data.dart';
import 'package:teambalancer/data/team_data.dart';
import 'package:teambalancer/data/team_key.dart';

import 'dart:developer' as developer;

Future<TeamData?> getTeamData(TeamKey teamKey) async {
  final json = await Backend.getTeam(teamKey.key);
  if (json == null || json.isEmpty) {
    // e.g. team removed from server
    return null;
  }
  return TeamData.fromJson(json);
}

class Data {
  final _dataVersion = 0.1;
  final _key = "data";
  PreferenceData preferenceData = PreferenceData({});
  TeamsData data = TeamsData({});

  void restoreData(
      {required updateCallback, required TeamKey? addTeamKey}) async {
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

    if (addTeamKey != null) {
      final teamKey = addTeamKey.key.substring(0, 6);
      final adminKey =
          (addTeamKey.key.length == 12) ? addTeamKey.key.substring(6) : '';
      developer.log('add team $teamKey ($adminKey)', name: 'teambalancer data');
      if (!preferenceData.teams.containsKey(teamKey) || (adminKey != '')) {
        preferenceData.teams[teamKey] = PreferenceTeamData(adminKey: adminKey);
      }
    }

    var obsoleteTeams = [];
    for (var key in preferenceData.teams.keys) {
      final teamKey = TeamKey(key);
      var teamData = await getTeamData(teamKey);
      if (teamData == null) {
        developer.log('remove obsolete team $key', name: 'teambalancer data');
        obsoleteTeams.add(key);
      } else {
        developer.log('loaded team $key', name: 'teambalancer data');
        data.addTeam(teamData);
      }
    }
    for (var key in obsoleteTeams) {
      preferenceData.teams.remove(key);
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

    data.addTeam(TeamData.fromJson(json));
    preferenceData.teams[json['teamKey']] =
        PreferenceTeamData(adminKey: json['adminKey']);
    _save();
  }

  bool isAdmin(TeamKey teamKey) {
    return preferenceData.teams[teamKey.key]!.adminKey.isNotEmpty;
  }

  Future<void> removeTeam(TeamKey teamKey, {bool admin = false}) async {
    if (admin) {
      Map<String, dynamic> body = {
        'teamKey': teamKey.key,
        'adminKey': preferenceData.teams[teamKey.key]!.adminKey,
      };
      await Backend.removeTeam(jsonEncode(body));
    }
    data.removeTeam(teamKey);
    preferenceData.teams.remove(teamKey.key);
    await _save();
  }

  Future<void> renameTeam(TeamKey teamKey, String name, Sport sport) async {
    final team = data.team(teamKey);
    team.name = name;
    team.sport = sport.index;
    Map<String, dynamic> body = {
      'teamKey': teamKey.key,
      'name': name,
      'sport': sport.index,
      'adminKey': preferenceData.teams[teamKey.key]!.adminKey,
    };
    await Backend.renameTeam(jsonEncode(body));
  }
}
