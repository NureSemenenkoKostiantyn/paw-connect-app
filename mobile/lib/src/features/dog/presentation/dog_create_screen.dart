import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../models/dog_response.dart';
import '../../../services/dog_service.dart';

class DogCreateScreen extends StatefulWidget {
  const DogCreateScreen({super.key});

  @override
  State<DogCreateScreen> createState() => _DogCreateScreenState();
}

class _DogCreateScreenState extends State<DogCreateScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController breedController = TextEditingController();
  final TextEditingController birthdateController = TextEditingController();

  String? gender;
  String? size;
  String? personality;
  String? activityLevel;

  bool _loading = false;

  String? _nameError;
  String? _breedError;
  String? _birthdateError;
  String? _sizeError;
  String? _genderError;
  String? _personalityError;
  String? _activityError;

  Future<void> _pickBirthdate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365)),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      birthdateController.text = date.toIso8601String().split('T').first;
    }
  }

  bool _validate() {
    setState(() {
      _nameError = nameController.text.isEmpty ? 'Required' : null;
      _breedError = breedController.text.isEmpty ? 'Required' : null;
      _birthdateError = birthdateController.text.isEmpty ? 'Required' : null;
      _sizeError = size == null ? 'Required' : null;
      _genderError = gender == null ? 'Required' : null;
      _personalityError = personality == null ? 'Required' : null;
      _activityError = activityLevel == null ? 'Required' : null;
    });
    return [
      _nameError,
      _breedError,
      _birthdateError,
      _sizeError,
      _genderError,
      _personalityError,
      _activityError,
    ].every((e) => e == null);
  }

  Future<void> _submit() async {
    if (!_validate()) return;
    setState(() => _loading = true);
    try {
      final res = await DogService.instance.createDog({
        'name': nameController.text,
        'breed': breedController.text,
        'birthdate': birthdateController.text,
        'size': size,
        'gender': gender,
        'personality': personality,
        'activityLevel': activityLevel,
      });
      if (!mounted) return;
      final dog = DogResponse.fromJson(res.data);
      context.pushReplacementNamed(
        'dog-profile',
        pathParameters: {'id': dog.id.toString()},
      );
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? e.message;
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Creation failed: $message')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Creation failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Dog')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Name', errorText: _nameError),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: breedController,
              decoration: InputDecoration(labelText: 'Breed', errorText: _breedError),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: birthdateController,
              readOnly: true,
              decoration:
                  InputDecoration(labelText: 'Birthdate', errorText: _birthdateError),
              onTap: _pickBirthdate,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: size,
              items: const [
                DropdownMenuItem(value: 'SMALL', child: Text('Small')),
                DropdownMenuItem(value: 'MEDIUM', child: Text('Medium')),
                DropdownMenuItem(value: 'LARGE', child: Text('Large')),
              ],
              onChanged: (v) => setState(() => size = v),
              decoration: InputDecoration(labelText: 'Size', errorText: _sizeError),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: gender,
              items: const [
                DropdownMenuItem(value: 'MALE', child: Text('Male')),
                DropdownMenuItem(value: 'FEMALE', child: Text('Female')),
              ],
              onChanged: (v) => setState(() => gender = v),
              decoration: InputDecoration(labelText: 'Gender', errorText: _genderError),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: personality,
              items: const [
                DropdownMenuItem(value: 'CALM', child: Text('Calm')),
                DropdownMenuItem(value: 'PLAYFUL', child: Text('Playful')),
              ],
              onChanged: (v) => setState(() => personality = v),
              decoration:
                  InputDecoration(labelText: 'Personality', errorText: _personalityError),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: activityLevel,
              items: const [
                DropdownMenuItem(value: 'LOW', child: Text('Low')),
                DropdownMenuItem(value: 'MEDIUM', child: Text('Medium')),
                DropdownMenuItem(value: 'HIGH', child: Text('High')),
              ],
              onChanged: (v) => setState(() => activityLevel = v),
              decoration:
                  InputDecoration(labelText: 'Activity Level', errorText: _activityError),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loading ? null : _submit,
              child: _loading
                  ? const CircularProgressIndicator()
                  : const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }
}
