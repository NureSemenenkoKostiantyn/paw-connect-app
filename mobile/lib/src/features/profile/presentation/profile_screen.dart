import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../models/current_user_response.dart';
import '../../../models/dog.dart';
import '../../../services/user_service.dart';
import '../../../services/http_client.dart';
import '../../dog/presentation/dog_card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  CurrentUserResponse? _user;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    setState(() => _loading = true);
    try {
      final res = await UserService.instance.getCurrentUser();
      _user = CurrentUserResponse.fromJson(res.data);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _logout() async {
    await HttpClient.instance.clearCookies();
    if (mounted) context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(onPressed: _logout, icon: const Icon(Icons.logout)),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadUser,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: _user == null
                    ? const Text('Failed to load profile')
                    : Card(
                        margin: EdgeInsets.zero,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Center(
                            child: CircleAvatar(
                              radius: 50,
                              child: Text(
                                _user!.username.isNotEmpty ? _user!.username[0].toUpperCase() : '?',
                                style: TextStyle(fontSize: 40),
                                ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _user!.username,
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 8),
                          Text('Email: ${_user!.email}'),
                          if (_user!.bio != null) ...[
                            const SizedBox(height: 8),
                            Text('Bio: ${_user!.bio}'),
                          ],
                          if (_user!.birthdate != null) ...[
                            const SizedBox(height: 8),
                            Text('Birthdate: ${_user!.birthdate}'),
                          ],
                          if (_user!.gender != null) ...[
                            const SizedBox(height: 8),
                            Text('Gender: ${_user!.gender}'),
                          ],
                          const SizedBox(height: 8),
                          Text('Location: ${_user!.latitude}, ${_user!.longitude}'),
                          if (_user!.languages.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text('Languages: ${_user!.languages.join(', ')}'),
                          ],
                          const SizedBox(height: 16),
                          Text(
                            'Dogs:',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          if (_user!.dogs.isEmpty)
                            const Text('No dogs added')
                          else
                            Column(
                              children: _user!.dogs.map<Widget>((data) {
                                final dog = Dog.fromJson(data);
                                return DogCard(
                                  dog: dog,
                                  onTap: () => context.pushNamed(
                                    'dog-profile',
                                    pathParameters: {'id': dog.id.toString()},
                                  ),
                                );
                              }).toList(),
                            ),
                          const SizedBox(height: 24),
                          Center(
                            child: ElevatedButton(
                              onPressed: () => context.push('/profile/complete'),
                              child: const Text('Edit Profile'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
        ),
      ),
    );
  }
}
