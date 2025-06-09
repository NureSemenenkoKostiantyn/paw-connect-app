class PreferenceResponse {
  final String? preferredPersonality;
  final String? preferredActivityLevel;
  final String? preferredSize;
  final String? preferredGender;

  PreferenceResponse.fromJson(Map<String, dynamic> json)
      : preferredPersonality = json['preferredPersonality'],
        preferredActivityLevel = json['preferredActivityLevel'],
        preferredSize = json['preferredSize'],
        preferredGender = json['preferredGender'];
}
