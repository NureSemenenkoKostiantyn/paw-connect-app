import 'dog_response.dart';

class CandidateUser {
  final int id;
  final String username;
  final String? bio;
  final String? gender;
  final String? profilePhotoUrl;
  final double distanceKm;
  final List<String> languages;
  final List<DogResponse> dogs;
  final int? score;

  CandidateUser.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        username = json['username'],
        bio = json['bio'],
        gender = json['gender'],
        profilePhotoUrl = json['profilePhotoUrl'],
        distanceKm = (json['distanceKm'] as num).toDouble(),
        languages = List<String>.from(json['languages'] ?? []),
        dogs = (json['dogs'] as List<dynamic>? ?? [])
            .map((e) => DogResponse.fromJson(e as Map<String, dynamic>))
            .toList(),
        score = json['score'];
}
