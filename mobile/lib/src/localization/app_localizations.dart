import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static const supportedLocales = [Locale('en'), Locale('uk')];

  static const delegate = _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'appTitle': 'PawConnect',
      'confirmLogout': 'Confirm Logout',
      'logoutPrompt': 'Are you sure you want to logout?',
      'cancel': 'Cancel',
      'logout': 'Logout',
      'event': 'Event',
      'eventId': 'Event ID',
      'selectLanguages': 'Select languages',
      'ok': 'OK',
      'completeProfile': 'Complete Profile',
      'finish': 'Finish',
      'next': 'Next',
      'back': 'Back',
      'profile': 'Profile',
      'useCurrentLocation': 'Use current location',
      'male': 'Male',
      'female': 'Female',
      'preferences': 'Preferences',
      'low': 'Low',
      'medium': 'Medium',
      'high': 'High',
      'small': 'Small',
      'large': 'Large',
      'calm': 'Calm',
      'playful': 'Playful',
      'yourDog': 'Your Dog',
      'deletePhoto': 'Delete Photo',
      'deletePhotoPrompt': 'Are you sure you want to delete your profile photo?',
      'delete': 'Delete',
      'readMore': 'Read more',
      'failedToLoadProfile': 'Failed to load profile',
      'editProfile': 'Edit Profile',
      'action1': 'Action 1',
      'action2': 'Action 2',
      'noChats': 'No chats found',
      'signupFailed': 'Signup failed',
      'register': 'Register',
      'createAccount': 'Create account',
      'username': 'Username',
      'email': 'Email',
      'password': 'Password',
      'signIn': 'Sign in',
      'welcomeBack': 'Welcome back',
      'loginFailed': 'Login failed',
      'viewDetails': 'View Details',
      'locationUnavailable': 'Location unavailable',
      'nearbyEvents': 'Nearby Events',
      'failedToSendSwipe': 'Failed to send swipe',
      'noCandidates': 'No candidates found',
      'increaseRadius': 'Increase search radius',
      'candidateRadius': 'Candidate search radius',
      'selected': 'Selected',
      'any': 'Any',
      'save': 'Save',
      'yearsOld': 'years old',
      'showMore': 'Show more',
      'dogNotFound': 'Dog not found',
      'failedToLoadDog': 'Failed to load dog',
      'sessionExpired': 'Session expired. Please sign in again.',
      'about': 'About',
      'traits': 'Traits',
      'name': 'Name',
      'breed': 'Breed',
      'size': 'Size',
      'gender': 'Gender',
      'languages': 'Languages',
      'activityLevel': 'Activity Level',
      'dogSize': 'Dog Size',
      'dogGender': 'Dog Gender',
      'personality': 'Personality',
      'bio': 'Bio',
      'birthdate': 'Birthdate',
      'latitude': 'Latitude',
      'longitude': 'Longitude',
    },
    'uk': {
      'appTitle': 'PawConnect',
      'confirmLogout': 'Підтвердити вихід',
      'logoutPrompt': 'Ви впевнені, що хочете вийти?',
      'cancel': 'Скасувати',
      'logout': 'Вийти',
      'event': 'Подія',
      'eventId': 'ID події',
      'selectLanguages': 'Виберіть мови',
      'ok': 'ОК',
      'completeProfile': 'Завершити профіль',
      'finish': 'Готово',
      'next': 'Далі',
      'back': 'Назад',
      'profile': 'Профіль',
      'useCurrentLocation': 'Використати поточну локацію',
      'male': 'Чоловіча',
      'female': 'Жіноча',
      'preferences': 'Налаштування',
      'low': 'Низький',
      'medium': 'Середній',
      'high': 'Високий',
      'small': 'Малий',
      'large': 'Великий',
      'calm': 'Спокійний',
      'playful': 'Грайливий',
      'yourDog': 'Ваш пес',
      'deletePhoto': 'Видалити фото',
      'deletePhotoPrompt': 'Ви впевнені, що хочете видалити фото профілю?',
      'delete': 'Видалити',
      'readMore': 'Читати більше',
      'failedToLoadProfile': 'Не вдалося завантажити профіль',
      'editProfile': 'Редагувати профіль',
      'action1': 'Дія 1',
      'action2': 'Дія 2',
      'noChats': 'Чати не знайдено',
      'signupFailed': 'Помилка реєстрації',
      'register': 'Реєстрація',
      'createAccount': 'Створити аккаунт',
      'username': "Ім'я користувача",
      'email': 'Електронна пошта',
      'password': 'Пароль',
      'signIn': 'Увійти',
      'welcomeBack': 'Ласкаво просимо',
      'loginFailed': 'Помилка входу',
      'viewDetails': 'Детальніше',
      'locationUnavailable': 'Розташування недоступне',
      'nearbyEvents': 'Поруч події',
      'failedToSendSwipe': 'Не вдалося відправити свайп',
      'noCandidates': 'Кандидатів не знайдено',
      'increaseRadius': 'Збільшити радіус пошуку',
      'candidateRadius': 'Радіус пошуку кандидатів',
      'selected': 'Вибрано',
      'any': 'Будь-який',
      'save': 'Зберегти',
      'yearsOld': 'років',
      'showMore': 'Показати більше',
      'dogNotFound': 'Собаку не знайдено',
      'failedToLoadDog': 'Не вдалося завантажити собаку',
      'sessionExpired': 'Сесію завершено. Будь ласка, увійдіть знову.',
      'about': 'Про',
      'traits': 'Риси',
      'name': "Ім'я",
      'breed': 'Порода',
      'size': 'Розмір',
      'gender': 'Стать',
      'languages': 'Мови',
      'activityLevel': 'Рівень активності',
      'dogSize': 'Розмір собаки',
      'dogGender': 'Стать собаки',
      'personality': 'Характер',
      'bio': 'Біо',
      'birthdate': 'Дата народження',
      'latitude': 'Широта',
      'longitude': 'Довгота',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ??
        _localizedValues['en']![key] ?? key;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['en', 'uk'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) =>
      SynchronousFuture<AppLocalizations>(AppLocalizations(locale));

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) =>
      false;
}

extension LocalizationExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
