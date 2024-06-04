import 'dart:convert';

import 'package:teambalancer/data/backend.dart';

class Game {
  Game(this.date, this.groups, this.result, this.historyId);

  DateTime date;
  List<List<String>> groups;
  String result;
  int historyId;

  void remove(teamKey) async {
    Map<String, dynamic> body = {
      'teamKey': teamKey,
      'historyId': historyId,
    };
    await Backend.removeGame(jsonEncode(body));
  }

  void setResult(result) async {
    Map<String, dynamic> body = {
      'historyId': historyId,
      'result': result,
    };
    await Backend.updateGame(jsonEncode(body));
  }
}
