import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../models/public_user_response.dart';
import '../../../models/dog_response.dart';
import '../../../services/user_service.dart';

class PublicProfileScreen extends StatefulWidget {
  final int userId;
  const PublicProfileScreen({super.key, required this.userId});

  @override
  State<PublicProfileScreen> createState() => _PublicProfileScreenState();
}

class _PublicProfileScreenState extends State<PublicProfileScreen> {
  PublicUserResponse? _user;
  bool _loading = true;
  bool _showFullBio = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    setState(() => _loading = true);
    try {
      final res = await UserService.instance.getPublicUser(widget.userId);
      _user = PublicUserResponse.fromJson(res.data);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  int? _calculateAge(String? birthdate) {
    if (birthdate == null) return null;
    try {
      final date = DateTime.parse(birthdate);
      final now = DateTime.now();
      int age = now.year - date.year;
      if (now.month < date.month ||
          (now.month == date.month && now.day < date.day)) {
        age--;
      }
      return age;
    } catch (_) {
      return null;
    }
  }

  Widget _buildUserInfo() {
    final ageText = _user!.age != null ? ', ${_user!.age}' : '';
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Text(
              '${_user!.username}$ageText',
              style: Theme.of(context)
                  .textTheme
                  .headlineLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          if (_user!.gender != null)
            Row(
              children: [
                const Icon(Icons.person_outline, size: 20),
                const SizedBox(width: 4),
                Text(_user!.gender!),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildBio() {
    if (_user!.bio == null || _user!.bio!.isEmpty) return const SizedBox();
    final bio = _user!.bio!;
    final maxLines = _showFullBio ? null : 3;
    final overflow = _showFullBio ? TextOverflow.visible : TextOverflow.ellipsis;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'About me',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            bio,
            maxLines: maxLines,
            overflow: overflow,
          ),
          if (bio.length > 120 && !_showFullBio)
            TextButton(
              onPressed: () => setState(() => _showFullBio = true),
              child: const Text('Read more'),
            ),
        ],
      ),
    );
  }

  Widget _buildLanguages() {
    if (_user!.languages.isEmpty) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Languages',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: _user!.languages
                .map((lang) => Chip(label: Text(lang)))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDogs() {
    if (_user!.dogs.isEmpty) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 8, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(right: 16),
            child: Text(
              'Dogs',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 180,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _user!.dogs.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final DogResponse dog = _user!.dogs[index];
                final age = _calculateAge(dog.birthdate);
                return GestureDetector(
                  onTap: () => context.pushNamed(
                    'dog-profile',
                    pathParameters: {'id': dog.id.toString()},
                  ),
                  child: SizedBox(
                    width: 140,
                    child: Card(
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: dog.photoUrls.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: dog.photoUrls.first,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => const Center(
                                        child: CircularProgressIndicator()),
                                    errorWidget: (context, url, error) =>
                                        Container(
                                      color: Colors.black12,
                                      alignment: Alignment.center,
                                      child: Icon(
                                        Icons.pets,
                                        size: 48,
                                        color:
                                            Theme.of(context)
                                                .colorScheme
                                                .primary,
                                      ),
                                    ),
                                  )
                                : Container(
                                    color: Colors.black12,
                                    alignment: Alignment.center,
                                    child: Icon(
                                      Icons.pets,
                                      size: 48,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  age != null
                                      ? '${dog.name}, $age'
                                      : dog.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                if (dog.breed != null)
                                  Text(
                                    dog.breed!,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragUpdate: (details) {
        if (details.primaryDelta != null && details.primaryDelta! > 20) {
          Navigator.of(context).maybePop();
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _user == null
                ? const Center(child: Text('Failed to load profile'))
                : CustomScrollView(
                    slivers: [
                      SliverAppBar(
                        leading: IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => Navigator.pop(context),
                        ),
                        expandedHeight: 400,
                        flexibleSpace: FlexibleSpaceBar(
                          background: Hero(
                            tag: 'user-${_user!.id}',
                            child: _user!.profilePhotoUrl != null
                                ? CachedNetworkImage(
                                    imageUrl: _user!.profilePhotoUrl!,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) =>
                                        const Center(child: CircularProgressIndicator()),
                                    errorWidget: (context, url, error) => Container(
                                      color: Colors.black12,
                                      alignment: Alignment.center,
                                      child: Icon(
                                        Icons.person,
                                        size: 80,
                                        color:
                                            Theme.of(context).colorScheme.primary,
                                      ),
                                    ),
                                  )
                                : Container(
                                    color: Colors.black12,
                                    alignment: Alignment.center,
                                    child: Icon(
                                      Icons.person,
                                      size: 80,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(child: _buildUserInfo()),
                      SliverToBoxAdapter(child: _buildBio()),
                      SliverToBoxAdapter(child: _buildLanguages()),
                      SliverToBoxAdapter(child: _buildDogs()),
                      const SliverToBoxAdapter(child: SizedBox(height: 16)),
                    ],
                  ),
      ),
    );
  }
}
