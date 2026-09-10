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
          final theme = Theme.of(context);

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                player.name,
                style: theme.textTheme.headlineMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Pseudo : ${player.id}',
                style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 20),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      _InfoRow(icon: Icons.flag, label: 'Pays', value: player.country),
                      const Divider(height: 1),
                      _InfoRow(icon: Icons.shield, label: 'Équipe', value: player.team),
                      const Divider(height: 1),
                      _InfoRow(
                        icon: Icons.circle,
                        label: 'Statut',
                        value: player.status,
                        valueColor: player.status.toLowerCase() == 'active'
                            ? Colors.green
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                      if (player.birthDate != null) ...[
                        const Divider(height: 1),
                        _InfoRow(
                          icon: Icons.cake,
                          label: 'Naissance',
                          value: player.birthDate!,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Titres',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              if (player.achievements.isEmpty)
                Text(
                  'Aucun titre répertorié sur Liquipedia',
                  style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                )
              else
                ...player.achievements.map(
                  (achievement) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: Icon(Icons.emoji_events, color: theme.colorScheme.primary),
                      title: Text(achievement),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
          const Spacer(),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.w600, color: valueColor),
          ),
        ],
      ),
    );
  }
}
