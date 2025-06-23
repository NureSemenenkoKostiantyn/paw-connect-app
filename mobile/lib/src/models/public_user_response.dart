import 'dog_response.dart';

class PublicUserResponse {
  final int id;
  final String username;
  final String? bio;
  final int? age;
  final String? gender;
  final String? profilePhotoUrl;
  final Set<String> languages;
  final List<DogResponse> dogs;

  PublicUserResponse.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        username = json['username'],
        bio = json['bio'],
        age = json['age'],
        gender = json['gender'],
        profilePhotoUrl = json['profilePhotoUrl'],
        languages = Set<String>.from(json['languages'] ?? []),
        dogs = (json['dogs'] as List<dynamic>? ?? [])
            .map((e) => DogResponse.fromJson(e as Map<String, dynamic>))
            .toList();
}
