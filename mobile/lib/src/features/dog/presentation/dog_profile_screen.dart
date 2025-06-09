import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../models/dog.dart';
import '../../../services/dog_service.dart';

class DogProfileScreen extends StatefulWidget {
  final int dogId;

  const DogProfileScreen({super.key, required this.dogId});

  @override
  State<DogProfileScreen> createState() => _DogProfileScreenState();
}

class _DogProfileScreenState extends State<DogProfileScreen> {
  Dog? _dog;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadDog();
  }

  Future<void> _loadDog() async {
    setState(() => _loading = true);
    try {
      final res = await DogService.instance.getDog(widget.dogId);
      _dog = Dog.fromJson(res.data);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dog Profile')),
      body: RefreshIndicator(
        onRefresh: _loadDog,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _dog == null
                ? const Center(child: Text('Failed to load dog'))
                : SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: CircleAvatar(
                            radius: 50,
                            child: Text(
                              _dog!.name.isNotEmpty ? _dog!.name[0] : '?',
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text('Name: ${_dog!.name}'),
                        if (_dog!.breed != null) ...[
                          const SizedBox(height: 8),
                          Text('Breed: ${_dog!.breed}'),
                        ],
                        if (_dog!.birthdate != null) ...[
                          const SizedBox(height: 8),
                          Text('Birthdate: ${_dog!.birthdate}'),
                        ],
                        if (_dog!.gender != null) ...[
                          const SizedBox(height: 8),
                          Text('Gender: ${_dog!.gender}'),
                        ],
                        if (_dog!.size != null) ...[
                          const SizedBox(height: 8),
                          Text('Size: ${_dog!.size}'),
                        ],
                        if (_dog!.personality != null) ...[
                          const SizedBox(height: 8),
                          Text('Personality: ${_dog!.personality}'),
                        ],
                        if (_dog!.activityLevel != null) ...[
                          const SizedBox(height: 8),
                          Text('Activity Level: ${_dog!.activityLevel}'),
                        ],
                      ],
                    ),
                  ),
      ),
    );
  }
}
