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
      await DogService.instance.createDog({
        'name': dogNameController.text,
        'breed': dogBreedController.text,
        'birthdate': dogBirthdateController.text,
        'size': dogSize,
        'gender': dogGender,
        'personality': dogPersonality,
        'activityLevel': dogActivity,
      });
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
          if (_step < 2) {
            setState(() => _step += 1);
          } else {
            _submit();
          }
        },
        onStepCancel: _step > 0 ? () => setState(() => _step -= 1) : null,
        controlsBuilder: (context, details) {
          return Row(
            children: [
              ElevatedButton(
                onPressed: _loading ? null : details.onStepContinue,
                child: _step == 2 ? const Text('Finish') : const Text('Next'),
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
                  decoration: const InputDecoration(labelText: 'Bio'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: birthdateController,
                  readOnly: true,
                  decoration: const InputDecoration(labelText: 'Birthdate'),
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
                  decoration: const InputDecoration(labelText: 'Latitude'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: longitudeController,
                  decoration: const InputDecoration(labelText: 'Longitude'),
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
                  decoration: const InputDecoration(labelText: 'Gender'),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: _pickLanguages,
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'Languages'),
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
                  decoration: const InputDecoration(labelText: 'Activity Level'),
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
                  decoration: const InputDecoration(labelText: 'Dog Size'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: prefGender,
                  items: const [
                    DropdownMenuItem(value: 'MALE', child: Text('Male')),
                    DropdownMenuItem(value: 'FEMALE', child: Text('Female')),
                  ],
                  onChanged: (v) => setState(() => prefGender = v),
                  decoration: const InputDecoration(labelText: 'Dog Gender'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: prefPersonality,
                  items: const [
                    DropdownMenuItem(value: 'CALM', child: Text('Calm')),
                    DropdownMenuItem(value: 'PLAYFUL', child: Text('Playful')),
                  ],
                  onChanged: (v) => setState(() => prefPersonality = v),
                  decoration: const InputDecoration(labelText: 'Personality'),
                ),
              ],
            ),
          ),
          Step(
            title: const Text('Your Dog'),
            content: Column(
              children: [
                TextField(
                  controller: dogNameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: dogBreedController,
                  decoration: const InputDecoration(labelText: 'Breed'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: dogBirthdateController,
                  readOnly: true,
                  decoration: const InputDecoration(labelText: 'Birthdate'),
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
                  decoration: const InputDecoration(labelText: 'Size'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: dogGender,
                  items: const [
                    DropdownMenuItem(value: 'MALE', child: Text('Male')),
                    DropdownMenuItem(value: 'FEMALE', child: Text('Female')),
                  ],
                  onChanged: (v) => setState(() => dogGender = v),
                  decoration: const InputDecoration(labelText: 'Gender'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: dogPersonality,
                  items: const [
                    DropdownMenuItem(value: 'CALM', child: Text('Calm')),
                    DropdownMenuItem(value: 'PLAYFUL', child: Text('Playful')),
                  ],
                  onChanged: (v) => setState(() => dogPersonality = v),
                  decoration: const InputDecoration(labelText: 'Personality'),
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
                  decoration: const InputDecoration(labelText: 'Activity Level'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
