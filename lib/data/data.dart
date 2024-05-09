import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:teambalancer/data/preference_data.dart';
import 'package:teambalancer/data/team_data.dart';
import 'package:http/http.dart' as http;

Future<Map<String, TeamData>> getTeamData(String key) async {
  final url = 'https://teambalancer.simonste.ch/api/team.php/get/$key';
  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    final json = jsonDecode(response.body);
    return {json['name']: TeamData.fromJson(json)};
  } else {
    throw Exception('Failed to get $url');
  }
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
        var teamData = await getTeamData(preferenceData.teams.first.key);
        data.teams.addAll(teamData);
        notify();
      } else {
        preferenceData.teams.add(PreferenceTeamData('A4GH4902'));
        _save();
        notify();
      }
    }
  }

  void save() async {
    var json = preferenceData.toJson();
    json['data_version'] = _dataVersion;
    final str = jsonEncode(json);
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_key, str);
  }

  TeamsData get() {
    return data;
  }
}
