class Player {
  final int id;
  final String firstName;
  final String lastName;
  final String position;
  final String country;
  final int jerseyNumber;

  Player({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.position,
    required this.country,
    required this.jerseyNumber,
  });

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      position: json['position'],
      country: json['country'],
      jerseyNumber: json['jersey_number'] is int
          ? json['jersey_number']
          : int.parse(json['jersey_number']),
    );
  }
}
