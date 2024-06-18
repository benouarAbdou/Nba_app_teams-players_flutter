class Player {
  final int id;
  final String firstName;
  final String lastName;
  final String position;

  Player({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.position,
  });

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      position: json['position'],
    );
  }
}
