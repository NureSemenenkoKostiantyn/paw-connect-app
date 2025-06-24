import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService extends ChangeNotifier {
  SettingsService._();

  static final SettingsService instance = SettingsService._();

  late SharedPreferences _prefs;
  double _candidateDistanceKm = 25;
  late Locale _locale;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _candidateDistanceKm = _prefs.getDouble('candidateDistanceKm') ?? 25;
    final code = _prefs.getString('languageCode');
    if (code != null) {
      _locale = Locale(code);
    } else {
      final systemCode = WidgetsBinding.instance.platformDispatcher.locale.languageCode;
      _locale = Locale(systemCode == 'uk' ? 'uk' : 'en');
    }
  }

  double get candidateDistanceKm => _candidateDistanceKm;
  Locale get locale => _locale;

  Future<void> setCandidateDistanceKm(double value) async {
    _candidateDistanceKm = value;
    await _prefs.setDouble('candidateDistanceKm', value);
  }

  Future<void> setLocale(String code) async {
    _locale = Locale(code);
    await _prefs.setString('languageCode', code);
    notifyListeners();
  }
}
