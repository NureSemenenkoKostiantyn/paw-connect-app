import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import '../../services/user_service.dart';
import '../../services/preference_service.dart';
import '../../services/dog_service.dart';
import '../../services/language_service.dart';

import '../../models/current_user_response.dart';
import '../../models/preference_response.dart';
import '../../models/language.dart';

class ProfileCompletionScreen extends StatefulWidget {
  const ProfileCompletionScreen({super.key});

  @override
  State<ProfileCompletionScreen> createState() => _ProfileCompletionScreenState();
}

class _ProfileCompletionScreenState extends State<ProfileCompletionScreen> {
  int _step = 0;
  bool _loading = false;
  bool _initialLoading = true;
  bool _hasDog = false;

  String? _bioError;
  String? _birthdateError;
  String? _latitudeError;
  String? _longitudeError;
  String? _genderError;
  String? _languagesError;

  String? _prefActivityError;
  String? _prefSizeError;
  String? _prefGenderError;
  String? _prefPersonalityError;

  String? _dogNameError;
  String? _dogBreedError;
  String? _dogBirthdateError;
  String? _dogSizeError;
  String? _dogGenderError;
  String? _dogPersonalityError;
  String? _dogActivityError;

  final TextEditingController bioController = TextEditingController();
  final TextEditingController birthdateController = TextEditingController();
  final TextEditingController latitudeController = TextEditingController();
  final TextEditingController longitudeController = TextEditingController();
  String? gender;
  List<Language> _languages = [];
  Set<int> _selectedLanguageIds = {};

  String? prefActivity;
  String? prefSize;
  String? prefGender;
  String? prefPersonality;

  final TextEditingController dogNameController = TextEditingController();
  final TextEditingController dogBreedController = TextEditingController();
  final TextEditingController dogBirthdateController = TextEditingController();
  String? dogGender;
  String? dogSize;
  String? dogPersonality;
  String? dogActivity;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      final langsRes = await LanguageService.instance.getAll();
      _languages = (langsRes.data as List)
          .map((e) => Language.fromJson(e))
          .toList();

      final userRes = await UserService.instance.getCurrentUser();
      final prefRes = await PreferenceService.instance.getCurrent();
      final user = CurrentUserResponse.fromJson(userRes.data);
      final pref = PreferenceResponse.fromJson(prefRes.data);

      bioController.text = user.bio ?? '';
      birthdateController.text = user.birthdate ?? '';
      latitudeController.text = user.latitude.toString();
      longitudeController.text = user.longitude.toString();
      if (user.latitude == 0 && user.longitude == 0) {
        await _setDeviceLocation();
      }
      gender = user.gender;
      _selectedLanguageIds = user.languages
          .map((name) {
            try {
              return _languages.firstWhere((l) => l.name == name).id;
            } catch (_) {
              return null;
            }
          })
          .whereType<int>()
          .toSet();

      _hasDog = user.dogs.isNotEmpty;

      prefActivity = pref.preferredActivityLevel;
      prefSize = pref.preferredSize;
      prefGender = pref.preferredGender;
      prefPersonality = pref.preferredPersonality;
    } finally {
      if (mounted) setState(() => _initialLoading = false);
    }
  }

  Future<void> _setDeviceLocation() async {
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse) {
        final pos = await Geolocator.getCurrentPosition();
        latitudeController.text = pos.latitude.toString();
        longitudeController.text = pos.longitude.toString();
      }
    } catch (_) {}
  }

  Future<void> _pickLanguages() async {
    final selected = Set<int>.from(_selectedLanguageIds);
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select languages'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return SizedBox(
                width: double.maxFinite,
                child: ListView(
                  shrinkWrap: true,
                  children: _languages
                      .map(
                        (lang) => CheckboxListTile(
                          value: selected.contains(lang.id),
                          title: Text(lang.name),
                          onChanged: (v) {
                            setState(() {
                              if (v == true) {
                                selected.add(lang.id);
                              } else {
                                selected.remove(lang.id);
                              }
                            });
                          },
                        ),
                      )
                      .toList(),
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, selected),
              child: const Text('OK'),
            ),
          ],
        );
      },
    ).then((value) {
      if (value is Set<int>) {
        setState(() {
          _selectedLanguageIds = value;
        });
      }
    });
  }

  bool _validateProfileStep() {
    setState(() {
      _bioError = bioController.text.isEmpty ? 'Required' : null;
      _birthdateError = birthdateController.text.isEmpty ? 'Required' : null;
      _latitudeError = latitudeController.text.isEmpty ? 'Required' : null;
      _longitudeError = longitudeController.text.isEmpty ? 'Required' : null;
      _genderError = gender == null ? 'Required' : null;
      _languagesError = _selectedLanguageIds.isEmpty ? 'Required' : null;
    });
    return [
      _bioError,
      _birthdateError,
      _latitudeError,
      _longitudeError,
      _genderError,
      _languagesError,
    ].every((e) => e == null);
  }

  bool _validatePreferencesStep() {
    setState(() {
      _prefActivityError = prefActivity == null ? 'Required' : null;
      _prefSizeError = prefSize == null ? 'Required' : null;
      _prefGenderError = prefGender == null ? 'Required' : null;
      _prefPersonalityError = prefPersonality == null ? 'Required' : null;
    });
    return [
      _prefActivityError,
      _prefSizeError,
      _prefGenderError,
      _prefPersonalityError,
    ].every((e) => e == null);
  }

  bool get _shouldAddDog =>
      dogNameController.text.isNotEmpty ||
      dogBreedController.text.isNotEmpty ||
      dogBirthdateController.text.isNotEmpty ||
      dogGender != null ||
      dogSize != null ||
      dogPersonality != null ||
      dogActivity != null;

  bool _validateDogStep() {
    if (_hasDog && !_shouldAddDog) return true;
    setState(() {
      _dogNameError = dogNameController.text.isEmpty ? 'Required' : null;
      _dogBreedError = dogBreedController.text.isEmpty ? 'Required' : null;
      _dogBirthdateError = dogBirthdateController.text.isEmpty ? 'Required' : null;
      _dogSizeError = dogSize == null ? 'Required' : null;
      _dogGenderError = dogGender == null ? 'Required' : null;
      _dogPersonalityError = dogPersonality == null ? 'Required' : null;
      _dogActivityError = dogActivity == null ? 'Required' : null;
    });
    return [
      _dogNameError,
      _dogBreedError,
      _dogBirthdateError,
      _dogSizeError,
      _dogGenderError,
      _dogPersonalityError,
      _dogActivityError,
    ].every((e) => e == null);
  }

  Future<void> _submit() async {
    setState(() => _loading = true);
    try {
      await UserService.instance.updateCurrentUser({
        'bio': bioController.text,
        'birthdate': birthdateController.text,
        'gender': gender,
        'latitude': double.tryParse(latitudeController.text),
        'longitude': double.tryParse(longitudeController.text),
        'languageIds': _selectedLanguageIds.toList(),
      });
      await PreferenceService.instance.updateCurrent({
        'preferredPersonality': prefPersonality,
        'preferredActivityLevel': prefActivity,
        'preferredSize': prefSize,
        'preferredGender': prefGender,
      });
      if (!_hasDog || _shouldAddDog) {
        await DogService.instance.createDog({
          'name': dogNameController.text,
          'breed': dogBreedController.text,
          'birthdate': dogBirthdateController.text,
          'size': dogSize,
          'gender': dogGender,
          'personality': dogPersonality,
          'activityLevel': dogActivity,
        });
      }
      if (mounted) context.go('/home');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Complete Profile')),
      body: _initialLoading
          ? const Center(child: CircularProgressIndicator())
          : Stepper(
        currentStep: _step,
        onStepContinue: () {
          final hasDogStep = !_hasDog;
          if (_step == 0) {
            if (_validateProfileStep()) {
              setState(() => _step += 1);
            }
          } else if (_step == 1 && hasDogStep) {
            if (_validatePreferencesStep()) {
              setState(() => _step += 1);
            }
          } else {
            if (hasDogStep) {
              if (_validateDogStep()) _submit();
            } else {
              if (_validatePreferencesStep()) _submit();
            }
          }
        },
        onStepCancel: _step > 0 ? () => setState(() => _step -= 1) : null,
        controlsBuilder: (context, details) {
          final hasDogStep = !_hasDog;
          final lastStep = hasDogStep ? 2 : 1;
          return Row(
            children: [
              ElevatedButton(
                onPressed: _loading ? null : details.onStepContinue,
                child: _step == lastStep ? const Text('Finish') : const Text('Next'),
              ),
              if (_step > 0)
                TextButton(
                  onPressed: details.onStepCancel,
                  child: const Text('Back'),
                ),
            ],
          );
        },
        steps: [
          Step(
            title: const Text('Profile'),
            content: Column(
              children: [
                TextField(
                  controller: bioController,
                  minLines: 3,
                  maxLines: 5,
                  decoration:
                      InputDecoration(labelText: 'Bio', errorText: _bioError),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: birthdateController,
                  readOnly: true,
                  decoration: InputDecoration(
                      labelText: 'Birthdate', errorText: _birthdateError),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      birthdateController.text = date.toIso8601String().split('T').first;
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: latitudeController,
                  decoration: InputDecoration(
                      labelText: 'Latitude', errorText: _latitudeError),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: longitudeController,
                  decoration: InputDecoration(
                      labelText: 'Longitude', errorText: _longitudeError),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: _setDeviceLocation,
                    icon: const Icon(Icons.my_location),
                    label: const Text('Use current location'),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: gender,
                  items: const [
                    DropdownMenuItem(value: 'MALE', child: Text('Male')),
                    DropdownMenuItem(value: 'FEMALE', child: Text('Female')),
                  ],
                  onChanged: (v) => setState(() => gender = v),
                  decoration:
                      InputDecoration(labelText: 'Gender', errorText: _genderError),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: _pickLanguages,
                  child: InputDecorator(
                    decoration: InputDecoration(
                        labelText: 'Languages', errorText: _languagesError),
                    child: Text(
                      _selectedLanguageIds.isEmpty
                          ? 'Select languages'
                          : _selectedLanguageIds
                              .map((id) => _languages.firstWhere((l) => l.id == id).name)
                              .join(', '),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Step(
            title: const Text('Preferences'),
            content: Column(
              children: [
                DropdownButtonFormField<String>(
                  value: prefActivity,
                  items: const [
                    DropdownMenuItem(value: 'LOW', child: Text('Low')),
                    DropdownMenuItem(value: 'MEDIUM', child: Text('Medium')),
                    DropdownMenuItem(value: 'HIGH', child: Text('High')),
                  ],
                  onChanged: (v) => setState(() => prefActivity = v),
                  decoration: InputDecoration(
                      labelText: 'Activity Level', errorText: _prefActivityError),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: prefSize,
                  items: const [
                    DropdownMenuItem(value: 'SMALL', child: Text('Small')),
                    DropdownMenuItem(value: 'MEDIUM', child: Text('Medium')),
                    DropdownMenuItem(value: 'LARGE', child: Text('Large')),
                  ],
                  onChanged: (v) => setState(() => prefSize = v),
                  decoration: InputDecoration(
                      labelText: 'Dog Size', errorText: _prefSizeError),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: prefGender,
                  items: const [
                    DropdownMenuItem(value: 'MALE', child: Text('Male')),
                    DropdownMenuItem(value: 'FEMALE', child: Text('Female')),
                  ],
                  onChanged: (v) => setState(() => prefGender = v),
                  decoration: InputDecoration(
                      labelText: 'Dog Gender', errorText: _prefGenderError),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: prefPersonality,
                  items: const [
                    DropdownMenuItem(value: 'CALM', child: Text('Calm')),
                    DropdownMenuItem(value: 'PLAYFUL', child: Text('Playful')),
                  ],
                  onChanged: (v) => setState(() => prefPersonality = v),
                  decoration: InputDecoration(
                      labelText: 'Personality', errorText: _prefPersonalityError),
                ),
              ],
            ),
          ),
          if (!_hasDog)
            Step(
              title: const Text('Your Dog'),
              content: Column(
                children: [
                  TextField(
                    controller: dogNameController,
                    decoration:
                        InputDecoration(labelText: 'Name', errorText: _dogNameError),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: dogBreedController,
                    decoration: InputDecoration(
                        labelText: 'Breed', errorText: _dogBreedError),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: dogBirthdateController,
                    readOnly: true,
                    decoration: InputDecoration(
                        labelText: 'Birthdate', errorText: _dogBirthdateError),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now().subtract(const Duration(days: 365 * 2)),
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        dogBirthdateController.text = date.toIso8601String().split('T').first;
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: dogSize,
                    items: const [
                      DropdownMenuItem(value: 'SMALL', child: Text('Small')),
                      DropdownMenuItem(value: 'MEDIUM', child: Text('Medium')),
                      DropdownMenuItem(value: 'LARGE', child: Text('Large')),
                    ],
                    onChanged: (v) => setState(() => dogSize = v),
                    decoration:
                        InputDecoration(labelText: 'Size', errorText: _dogSizeError),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: dogGender,
                    items: const [
                      DropdownMenuItem(value: 'MALE', child: Text('Male')),
                      DropdownMenuItem(value: 'FEMALE', child: Text('Female')),
                    ],
                    onChanged: (v) => setState(() => dogGender = v),
                    decoration:
                        InputDecoration(labelText: 'Gender', errorText: _dogGenderError),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: dogPersonality,
                    items: const [
                      DropdownMenuItem(value: 'CALM', child: Text('Calm')),
                      DropdownMenuItem(value: 'PLAYFUL', child: Text('Playful')),
                    ],
                    onChanged: (v) => setState(() => dogPersonality = v),
                    decoration: InputDecoration(
                        labelText: 'Personality', errorText: _dogPersonalityError),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: dogActivity,
                    items: const [
                      DropdownMenuItem(value: 'LOW', child: Text('Low')),
                      DropdownMenuItem(value: 'MEDIUM', child: Text('Medium')),
                      DropdownMenuItem(value: 'HIGH', child: Text('High')),
                    ],
                    onChanged: (v) => setState(() => dogActivity = v),
                    decoration: InputDecoration(
                        labelText: 'Activity Level', errorText: _dogActivityError),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
