class Dog {
  final int id;
  final String name;
  final String? breed;
  final String? birthdate;
  final String? size;
  final String? gender;
  final String? personality;
  final String? activityLevel;

  Dog({
    required this.id,
    required this.name,
    this.breed,
    this.birthdate,
    this.size,
    this.gender,
    this.personality,
    this.activityLevel,
  });

  factory Dog.fromJson(Map<String, dynamic> json) {
    return Dog(
      id: json['id'],
      name: json['name'] ?? 'Unnamed',
      breed: json['breed'],
      birthdate: json['birthdate'],
      size: json['size'],
      gender: json['gender'],
      personality: json['personality'],
      activityLevel: json['activityLevel'],
    );
  }
}
