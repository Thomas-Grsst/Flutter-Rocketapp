class Player {
  final String id;
  final String name;
  final String country;
  final String team;
  final String status;
  final String? birthDate;
  final List<String> achievements;

  Player({
    required this.id,
    required this.name,
    required this.country,
    required this.team,
    required this.status,
    required this.achievements,
    this.birthDate,
  });
}
