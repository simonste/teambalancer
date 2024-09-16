import 'dart:convert';

import 'package:http/http.dart' as http;

class Backend {
  static const baseUrl = 'https://teambalancer.simonste.ch/api-test/';
  static const header = {'Api-Version': '1.0'};

  static Future<dynamic> get(url) async {
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

  static Future<dynamic> put(url, body) async {
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

  static Future<dynamic> post(url, body) async {
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

  static Future<dynamic> delete(url, body) async {
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

  static Future<dynamic> getTeam(key) async {
    return get('team.php/get/$key');
  }

  static Future<dynamic> addTeam(body) async {
    return post('team.php/add', body);
  }

  static Future<dynamic> removeTeam(body) async {
    return delete('team.php/remove', body);
  }

  static Future<dynamic> renameTeam(body) async {
    return put('team.php/rename', body);
  }

  static Future<dynamic> updateTeam(body) async {
    return put('team.php/update', body);
  }

  static Future<dynamic> addPlayer(body) async {
    return post('player.php/add', body);
  }

  static Future<dynamic> removePlayer(body) async {
    return delete('player.php/remove', body);
  }

  static Future<dynamic> renamePlayer(body) async {
    return put('player.php/rename', body);
  }

  static Future<dynamic> updatePlayer(body) async {
    return put('player.php/update', body);
  }

  static Future<dynamic> addGame(body) async {
    return post('history.php/add', body);
  }

  static Future<dynamic> getHistory(key) async {
    // use try-catch and await for async request if team removed
    try {
      return await get('history.php/list/$key');
    } catch (e) {
      return null;
    }
  }

  static Future<dynamic> removeGame(body) async {
    return delete('history.php/remove', body);
  }

  static Future<dynamic> updateGame(body) async {
    return put('history.php/update', body);
  }
}
