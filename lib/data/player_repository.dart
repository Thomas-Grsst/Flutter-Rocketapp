import 'liquipedia_api.dart';
import 'models/player.dart';

class PlayerRepository {
  final LiquipediaApi _api;

  PlayerRepository(this._api);

  Future<List<String>> search(String query) {
    return _api.searchPlayers(query);
  }

  Future<Player> getPlayer(String pageName) async {
    final wikitext = await _api.getPlayerWikitext(pageName);

    return Player(
      id: _extractField(wikitext, 'id') ?? pageName,
      name: _extractField(wikitext, 'name') ?? pageName,
      country: _extractField(wikitext, 'country') ?? 'Inconnu',
      team: _extractField(wikitext, 'team') ?? 'Sans équipe',
      status: _extractField(wikitext, 'status') ?? 'Inconnu',
      birthDate: _extractField(wikitext, 'birth_date'),
    );
  }

  String? _extractField(String wikitext, String key) {
    final pattern = RegExp('\\|$key=(.*)');
    final match = pattern.firstMatch(wikitext);
    final value = match?.group(1)?.trim();

    if (value == null || value.isEmpty) {
      return null;
    }

    return value;
  }
}