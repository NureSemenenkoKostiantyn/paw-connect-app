import '../models/current_user_response.dart';
import '../models/preference_response.dart';

bool isProfileComplete(CurrentUserResponse user) {
  return user.bio != null &&
      user.birthdate != null &&
      user.gender != null &&
      user.languages.isNotEmpty &&
      user.dogs.isNotEmpty;
}

bool isPreferencesComplete(PreferenceResponse pref) {
  return pref.preferredPersonality != null &&
      pref.preferredActivityLevel != null &&
      pref.preferredSize != null &&
      pref.preferredGender != null;
}
