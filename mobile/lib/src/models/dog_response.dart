class DogResponse {
  final int id;
  final String name;
  final String? breed;
  final String? birthdate;
  final String? size;
  final String? gender;
  final String? personality;
  final String? activityLevel;
  final String? about;
  final List<String> photoUrls;
  final int ownerId;

  DogResponse.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        breed = json['breed'],
        birthdate = json['birthdate'],
        size = json['size'],
        gender = json['gender'],
        personality = json['personality'],
        activityLevel = json['activityLevel'],
        about = json['about'],
        photoUrls = List<String>.from(json['photoUrls'] ?? []),
        ownerId = json['ownerId'];
}
