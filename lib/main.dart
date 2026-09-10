import 'package:flutter/material.dart';

import 'data/liquipedia_api.dart';
import 'data/player_repository.dart';
import 'presentation/search_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rocket Stats',
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
      ),
      home: SearchPage(
        repository: PlayerRepository(LiquipediaApi()),
      ),
    );
  }
}