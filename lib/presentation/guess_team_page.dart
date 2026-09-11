import 'dart:math';

import 'package:flutter/material.dart';

import '../data/game_data.dart';
import '../data/player_repository.dart';

class GuessTeamPage extends StatefulWidget {
  final PlayerRepository repository;

  const GuessTeamPage({super.key, required this.repository});

  @override
  State<GuessTeamPage> createState() => _GuessTeamPageState();
}

class _GuessTeamPageState extends State<GuessTeamPage> {
  final _random = Random();

  bool _isLoading = true;
  String? _errorMessage;

  String _playerName = '';
  String _correctTeam = '';
  List<String> _options = [];
  String? _selectedOption;

  int _score = 0;
  int _questionsAnswered = 0;

  @override
  void initState() {
    super.initState();
    _loadQuestion();
  }

  Future<void> _loadQuestion({int attemptsLeft = 5}) async {
    if (attemptsLeft == 0) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Impossible de charger une question, réessaie.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _selectedOption = null;
    });

    final candidate = knownPlayers[_random.nextInt(knownPlayers.length)];

    try {
      final player = await widget.repository.getPlayer(candidate);

      if (player.team == noTeamFallback) {
        throw Exception('Pas d\'équipe connue pour ce joueur');
      }

      final wrongTeams = knownTeams
          .where((team) => team.toLowerCase() != player.team.toLowerCase())
          .toList()
        ..shuffle(_random);

      final options = [player.team, ...wrongTeams.take(3)]..shuffle(_random);

      setState(() {
        _playerName = player.name;
        _correctTeam = player.team;
        _options = options;
        _isLoading = false;
      });
    } catch (_) {
      await Future.delayed(const Duration(milliseconds: 800));
      await _loadQuestion(attemptsLeft: attemptsLeft - 1);
    }
  }

  void _answer(String team) {
    if (_selectedOption != null) return;

    setState(() {
      _selectedOption = team;
      _questionsAnswered++;
      if (team == _correctTeam) {
        _score++;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Devine l'équipe"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '$_score / $_questionsAnswered',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: _buildBody(theme),
      ),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _errorMessage!,
              style: TextStyle(color: theme.colorScheme.error),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => _loadQuestion(),
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        const SizedBox(height: 24),
        Text(
          'Dans quelle équipe joue',
          style: theme.textTheme.bodyLarge
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 8),
        Text(
          _playerName,
          style: theme.textTheme.headlineMedium
              ?.copyWith(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        Expanded(
          child: GridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 2.4,
            children: _options.map((team) => _buildOption(theme, team)).toList(),
          ),
        ),
        const SizedBox(height: 12),
        if (_selectedOption != null)
          FilledButton.icon(
            onPressed: () => _loadQuestion(),
            icon: const Icon(Icons.arrow_forward),
            label: const Text('Question suivante'),
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(46)),
          ),
      ],
    );
  }

  Widget _buildOption(ThemeData theme, String team) {
    Color? backgroundColor;
    Color borderColor = theme.colorScheme.outline;

    if (_selectedOption != null) {
      if (team == _correctTeam) {
        backgroundColor = Colors.green.withValues(alpha: 0.2);
        borderColor = Colors.green;
      } else if (team == _selectedOption) {
        backgroundColor = theme.colorScheme.error.withValues(alpha: 0.2);
        borderColor = theme.colorScheme.error;
      }
    }

    return OutlinedButton(
      onPressed: () => _answer(team),
      style: OutlinedButton.styleFrom(
        backgroundColor: backgroundColor,
        side: BorderSide(color: borderColor),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(
        team,
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }
}
