import 'package:flutter/material.dart';

import '../data/models/player.dart';
import '../data/player_repository.dart';

class PlayerPage extends StatefulWidget {
  final PlayerRepository repository;
  final String pageName;

  const PlayerPage({
    super.key,
    required this.repository,
    required this.pageName,
  });

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  late final Future<Player> _playerFuture;

  @override
  void initState() {
    super.initState();
    _playerFuture = widget.repository.getPlayer(widget.pageName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.pageName)),
      body: FutureBuilder<Player>(
        future: _playerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          }

          final player = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player.name,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text('Pseudo : ${player.id}'),
                Text('Pays : ${player.country}'),
                Text('Équipe : ${player.team}'),
                Text('Statut : ${player.status}'),
                if (player.birthDate != null)
                  Text('Date de naissance : ${player.birthDate}'),
              ],
            ),
          );
        },
      ),
    );
  }
}