class CurrentUserResponse {
  final int id;
  final String username;
  final String email;
  final String? bio;
  final String? birthdate;
  final String? gender;
  final double latitude;
  final double longitude;
  final bool? locationVisible;
  final String? profilePhotoUrl;
  final List<String> languages;
  final List<dynamic> dogs;

  CurrentUserResponse.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        username = json['username'],
        email = json['email'],
        bio = json['bio'],
        birthdate = json['birthdate'],
        gender = json['gender'],
        latitude = (json['latitude'] as num).toDouble(),
        longitude = (json['longitude'] as num).toDouble(),
        locationVisible = json['locationVisible'],
        profilePhotoUrl = json['profilePhotoUrl'],
        languages = List<String>.from(json['languages'] ?? []),
        dogs = List<dynamic>.from(json['dogs'] ?? []);
}
