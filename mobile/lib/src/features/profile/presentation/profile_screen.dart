import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../models/current_user_response.dart';
import '../../../services/user_service.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: RefreshIndicator(
        onRefresh: _loadUser,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: _user == null
                    ? const Text('Failed to load profile')
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: CircleAvatar(
                              radius: 50,
                              backgroundImage: NetworkImage(
                                _user!.profilePhotoUrl ??
                                    'https://avatar.iran.liara.run/public/${Random().nextBool() ? 'boy' : 'girl'}',
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text('Username: ${_user!.username}'),
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
                              children: _user!.dogs
                                  .map<Widget>((dog) {
                                final name = dog['name'] ?? 'Unnamed';
                                final breed = dog['breed'];
                                return ListTile(
                                  title: Text(name),
                                  subtitle: breed != null ? Text(breed) : null,
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
    );
  }
}
