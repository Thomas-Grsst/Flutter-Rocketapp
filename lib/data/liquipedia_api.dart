import 'dart:convert';

import 'package:http/http.dart' as http;

class PlayerNotFoundException implements Exception {
  final String pageName;

  PlayerNotFoundException(this.pageName);

  @override
  String toString() => 'Joueur "$pageName" introuvable sur Liquipedia';
}

class LiquipediaApi {
  static const _host = 'liquipedia.net';
  static const _path = '/rocketleague/api.php';
  static const _userAgent =
      'RocketStatsApp/1.0 (projet etudiant personnel; t.grossat@skera.com)';

  Future<List<String>> searchPlayers(String query) async {
    final uri = Uri.https(_host, _path, {
      'action': 'opensearch',
      'search': query,
      'format': 'json',
    });

    final response = await http.get(uri, headers: {'User-Agent': _userAgent});

    if (response.statusCode != 200) {
      throw Exception('Erreur réseau (code ${response.statusCode})');
    }

    final data = jsonDecode(response.body) as List<dynamic>;
    final titles = data[1] as List<dynamic>;

    return titles.map((title) => title as String).toList();
  }

  Future<String> getPlayerWikitext(String pageName) async {
    final uri = Uri.https(_host, _path, {
      'action': 'parse',
      'page': pageName,
      'format': 'json',
      'prop': 'wikitext',
    });

    final response = await http.get(uri, headers: {'User-Agent': _userAgent});

    if (response.statusCode != 200) {
      throw Exception('Erreur réseau (code ${response.statusCode})');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (data.containsKey('error')) {
      throw PlayerNotFoundException(pageName);
    }

    final parse = data['parse'] as Map<String, dynamic>;
    final wikitext = parse['wikitext'] as Map<String, dynamic>;

    return wikitext['*'] as String;
  }
}