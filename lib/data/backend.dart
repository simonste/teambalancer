import 'dart:convert';

import 'package:http/http.dart' as http;

class Backend {
  static const baseUrl = 'https://teambalancer.simonste.ch/api-test/';
  static const header = {'Api-Version': '2.0'};

  static Future<dynamic> get(String url) async {
    final response = await http.get(
      Uri.parse("$baseUrl$url"),
      headers: header,
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to get $url');
    }
    if (response.body.isNotEmpty) {
      return jsonDecode(response.body);
    } else {
      return null;
    }
  }

  static Future<dynamic> put(String url, String body) async {
    final response = await http.put(
      Uri.parse("$baseUrl$url"),
      headers: header,
      body: body,
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to put $url');
    }
    return jsonDecode(response.body);
  }

  static Future<dynamic> post(String url, String body) async {
    final response = await http.post(
      Uri.parse("$baseUrl$url"),
      headers: header,
      body: body,
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to post $url');
    }
    return jsonDecode(response.body);
  }

  static Future<dynamic> delete(String url, String body) async {
    final response = await http.delete(
      Uri.parse("$baseUrl$url"),
      headers: header,
      body: body,
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete $url');
    }
    return response;
  }

  static Future<dynamic> getTeam(String key) async {
    return get('team.php/get/$key');
  }

  static Future<dynamic> addTeam(String body) async {
    return post('team.php/add', body);
  }

  static Future<dynamic> removeTeam(String body) async {
    return delete('team.php/remove', body);
  }

  static Future<dynamic> renameTeam(String body) async {
    return put('team.php/rename', body);
  }

  static Future<dynamic> updateTeam(String body) async {
    return put('team.php/update', body);
  }

  static Future<dynamic> addPlayer(String body) async {
    return post('player.php/add', body);
  }

  static Future<dynamic> removePlayer(String body) async {
    return delete('player.php/remove', body);
  }

  static Future<dynamic> renamePlayer(String body) async {
    return put('player.php/rename', body);
  }

  static Future<dynamic> updatePlayer(String body) async {
    return put('player.php/update', body);
  }

  static Future<dynamic> addGame(String body) async {
    return post('history.php/add', body);
  }

  static Future<dynamic> getHistory(String key) async {
    // use try-catch and await for async request if team removed
    try {
      return await get('history.php/list/$key');
    } catch (e) {
      return null;
    }
  }

  static Future<dynamic> removeGame(String body) async {
    return delete('history.php/remove', body);
  }

  static Future<dynamic> updateGame(String body) async {
    return put('history.php/update', body);
  }
}
