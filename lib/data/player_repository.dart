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
      achievements: _extractAchievements(wikitext),
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

  List<String> _extractAchievements(String wikitext) {
    final pattern = RegExp(r'\|achievements=(.*?)\n(?=\||\})', dotAll: true);
    final match = pattern.firstMatch(wikitext);

    if (match == null) {
      return [];
    }

    final raw = match.group(1) ?? '';

    return raw
        .split('\n')
        .map(_cleanWikiText)
        .where((line) => line.isNotEmpty)
        .toList();
  }

  String _cleanWikiText(String text) {
    var cleaned = text.replaceAll(RegExp(r'\{\{[^{}]*\}\}'), '');

    cleaned = cleaned.replaceAllMapped(
      RegExp(r'\[\[([^\]|]*)\|?([^\]]*)\]\]'),
      (m) => (m.group(2)?.isNotEmpty ?? false) ? m.group(2)! : m.group(1)!,
    );

    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ').trim();

    return cleaned;
  }
}
