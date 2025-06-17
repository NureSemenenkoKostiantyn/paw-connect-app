import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  SettingsService._();

  static final SettingsService instance = SettingsService._();

  late SharedPreferences _prefs;
  double _candidateDistanceKm = 25;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _candidateDistanceKm = _prefs.getDouble('candidateDistanceKm') ?? 25;
  }

  double get candidateDistanceKm => _candidateDistanceKm;

  Future<void> setCandidateDistanceKm(double value) async {
    _candidateDistanceKm = value;
    await _prefs.setDouble('candidateDistanceKm', value);
  }
}
