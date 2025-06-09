import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/user_service.dart';
import '../../services/preference_service.dart';
import '../../services/dog_service.dart';

class ProfileCompletionScreen extends StatefulWidget {
  const ProfileCompletionScreen({super.key});

  @override
  State<ProfileCompletionScreen> createState() => _ProfileCompletionScreenState();
}

class _ProfileCompletionScreenState extends State<ProfileCompletionScreen> {
  int _step = 0;
  bool _loading = false;

  final TextEditingController bioController = TextEditingController();
  final TextEditingController birthdateController = TextEditingController();
  String? gender;
  final TextEditingController languagesController = TextEditingController();

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

  Future<void> _submit() async {
    setState(() => _loading = true);
    try {
      await UserService.instance.updateCurrentUser({
        'bio': bioController.text,
        'birthdate': birthdateController.text,
        'gender': gender,
        'languageIds': languagesController.text
            .split(',')
            .where((e) => e.trim().isNotEmpty)
            .map(int.parse)
            .toList(),
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
      body: Stepper(
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
                  decoration: const InputDecoration(labelText: 'Bio'),
                ),
                TextField(
                  controller: birthdateController,
                  decoration: const InputDecoration(labelText: 'Birthdate'),
                ),
                DropdownButtonFormField<String>(
                  value: gender,
                  items: const [
                    DropdownMenuItem(value: 'MALE', child: Text('Male')),
                    DropdownMenuItem(value: 'FEMALE', child: Text('Female')),
                  ],
                  onChanged: (v) => setState(() => gender = v),
                  decoration: const InputDecoration(labelText: 'Gender'),
                ),
                TextField(
                  controller: languagesController,
                  decoration: const InputDecoration(
                      labelText: 'Language IDs (comma separated)'),
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
                DropdownButtonFormField<String>(
                  value: prefGender,
                  items: const [
                    DropdownMenuItem(value: 'MALE', child: Text('Male')),
                    DropdownMenuItem(value: 'FEMALE', child: Text('Female')),
                  ],
                  onChanged: (v) => setState(() => prefGender = v),
                  decoration: const InputDecoration(labelText: 'Dog Gender'),
                ),
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
                TextField(
                  controller: dogBreedController,
                  decoration: const InputDecoration(labelText: 'Breed'),
                ),
                TextField(
                  controller: dogBirthdateController,
                  decoration: const InputDecoration(labelText: 'Birthdate'),
                ),
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
                DropdownButtonFormField<String>(
                  value: dogGender,
                  items: const [
                    DropdownMenuItem(value: 'MALE', child: Text('Male')),
                    DropdownMenuItem(value: 'FEMALE', child: Text('Female')),
                  ],
                  onChanged: (v) => setState(() => dogGender = v),
                  decoration: const InputDecoration(labelText: 'Gender'),
                ),
                DropdownButtonFormField<String>(
                  value: dogPersonality,
                  items: const [
                    DropdownMenuItem(value: 'CALM', child: Text('Calm')),
                    DropdownMenuItem(value: 'PLAYFUL', child: Text('Playful')),
                  ],
                  onChanged: (v) => setState(() => dogPersonality = v),
                  decoration: const InputDecoration(labelText: 'Personality'),
                ),
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
