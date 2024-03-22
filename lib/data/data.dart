import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:teambalancer/data/team_data.dart';

class Data {
  final _dataVersion = 0.1;
  final _key = "data";
  TeamsData data = TeamsData({});

  void restoreData(notify) async {
    final preferences = await SharedPreferences.getInstance();

    var defaultStr = "{}";
    final str = preferences.getString(_key) ?? defaultStr;
    if (str.length > 2) {
      Map<String, dynamic> json = jsonDecode(str);
      if (json['data_version'] == _dataVersion) {
        data = TeamsData.fromJson(json);
        notify();
      }
    }
  }

  void save() async {
    var json = data.toJson();
    json['data_version'] = _dataVersion;
    final str = jsonEncode(json);
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_key, str);
  }

  TeamsData get() {
    return data;
  }
}
