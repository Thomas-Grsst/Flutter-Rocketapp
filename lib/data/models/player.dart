class Player {
  final String id;
  final String name;
  final String country;
  final String team;
  final String status;
  final String? birthDate;

  Player({
    required this.id,
    required this.name,
    required this.country,
    required this.team,
    required this.status,
    this.birthDate,
  });
}
