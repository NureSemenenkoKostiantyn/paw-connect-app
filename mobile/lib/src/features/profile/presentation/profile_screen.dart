import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:cached_network_image/cached_network_image.dart';

import '../../../models/current_user_response.dart';
import '../../../models/dog_response.dart';
import '../../../services/user_service.dart';
import '../../../services/dog_service.dart';
import '../../../shared/main_app_bar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  CurrentUserResponse? _user;
  bool _loading = true;
  bool _photoProcessing = false;
  bool _pickingImage = false;
  bool _showFullBio = false;
  bool _dogActionLoading = false;

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

  Future<void> _changePhoto() async {
    if (_pickingImage) return;
    final theme = Theme.of(context);
    setState(() => _pickingImage = true);
    try {
      final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (picked == null) return;


    final cropped = await ImageCropper().cropImage(
      sourcePath: picked.path,
      aspectRatio: const CropAspectRatio(ratioX: 2, ratioY: 3),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Photo',
          toolbarColor: theme.colorScheme.primary,
          toolbarWidgetColor: Colors.white,
          hideBottomControls: true,
          lockAspectRatio: true,
          statusBarColor: theme.colorScheme.primary,
        ),
        IOSUiSettings(title: 'Crop Photo', aspectRatioLockEnabled: true),
      ],
    );
    if (cropped == null) return;

    final dir = await getTemporaryDirectory();
    final target = p.join(dir.path, '${DateTime.now().millisecondsSinceEpoch}.webp');

    final compressed = await FlutterImageCompress.compressAndGetFile(
      cropped.path,
      target,
      minWidth: 720,
      minHeight: 1080,
      format: CompressFormat.webp,
    );
    if (compressed == null) return;

    setState(() => _photoProcessing = true);
    try {
      final res = await UserService.instance.uploadProfilePhoto(File(compressed.path));
      _user = CurrentUserResponse.fromJson(res.data);
    } finally {
      if (mounted) setState(() => _photoProcessing = false);
    }
    } finally {
      if (mounted) setState(() => _pickingImage = false);
    }
  }

  Future<void> _deletePhoto() async {
    setState(() => _photoProcessing = true);
    try {
      await UserService.instance.deleteProfilePhoto();
      await _loadUser();
    } finally {
      if (mounted) setState(() => _photoProcessing = false);
    }
  }

  Future<void> _confirmDeletePhoto() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Photo'),
        content: const Text('Are you sure you want to delete your profile photo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _deletePhoto();
    }
  }

  Future<void> _deleteDog(int id) async {
    setState(() => _dogActionLoading = true);
    try {
      await DogService.instance.deleteDog(id);
      await _loadUser();
    } finally {
      if (mounted) setState(() => _dogActionLoading = false);
    }
  }

  Future<void> _confirmDeleteDog(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Dog'),
        content: const Text('Are you sure you want to delete this dog?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _deleteDog(id);
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
    final age = _calculateAge(_user!.birthdate);
    final ageText = age != null ? ', $age' : '';
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
            children:
                _user!.languages.map((lang) => Chip(label: Text(lang))).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDogs() {
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
              itemCount: _user!.dogs.length + 1,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                if (index == _user!.dogs.length) {
                  return GestureDetector(
                    onTap: () => context.pushNamed('dog-create'),
                    child: SizedBox(
                      width: 140,
                      child: Card(
                        child: Center(
                          child: Icon(
                            Icons.add,
                            size: 48,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                  );
                }

                final DogResponse dog =
                    DogResponse.fromJson(_user!.dogs[index] as Map<String, dynamic>);
                final age = _calculateAge(dog.birthdate);
                return GestureDetector(
                  onTap: () => context.pushNamed(
                    'dog-profile',
                    pathParameters: {'id': dog.id.toString()},
                  ),
                  child: SizedBox(
                    width: 140,
                    child: Stack(
                      children: [
                        Card(
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: dog.photoUrls.isNotEmpty
                                    ? CachedNetworkImage(
                                        imageUrl: dog.photoUrls.first,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) =>
                                            const Center(child: CircularProgressIndicator()),
                                        errorWidget: (context, url, error) => Container(
                                          color: Colors.black12,
                                          alignment: Alignment.center,
                                          child: Icon(
                                            Icons.pets,
                                            size: 48,
                                            color: Theme.of(context).colorScheme.primary,
                                          ),
                                        ),
                                      )
                                    : Container(
                                        color: Colors.black12,
                                        alignment: Alignment.center,
                                        child: Icon(
                                          Icons.pets,
                                          size: 48,
                                          color: Theme.of(context).colorScheme.primary,
                                        ),
                                      ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      age != null ? '${dog.name}, $age' : dog.name,
                                      style: const TextStyle(fontWeight: FontWeight.bold),
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
                        Positioned(
                          top: 0,
                          left: 0,
                          child: IconButton(
                            icon: const Icon(Icons.edit, color: Colors.white),
                            onPressed: _dogActionLoading
                                ? null
                                : () => context.pushNamed(
                                      'dog-edit',
                                      pathParameters: {'id': dog.id.toString()},
                                    ),
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed:
                                _dogActionLoading ? null : () => _confirmDeleteDog(dog.id),
                          ),
                        ),
                      ],
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
  Widget _buildPhoto() {
    final url = _user!.profilePhotoUrl;
    Widget image = AspectRatio(
      aspectRatio: 2 / 3,
      child: url != null
          ? CachedNetworkImage(
              imageUrl: url,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            )
          : Container(
              color: Colors.black12,
              alignment: Alignment.center,
              child: Icon(
                Icons.person,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
    );
    return Stack(
      children: [
        image,
        if (_photoProcessing)
          Positioned.fill(
            child: Container(
              color: Colors.black45,
              alignment: Alignment.center,
              child: const CircularProgressIndicator(),
            ),
          ),
        Positioned(
          bottom: 8,
          left: 8,
          child: Opacity(
            opacity: 0.8,
            child: ClipOval(
              child: Container(
                color: Colors.black45,
                child: IconButton(
                  icon: const Icon(Icons.photo_camera, color: Colors.white),
                  onPressed: _photoProcessing || _pickingImage ? null : _changePhoto,
                ),
              ),
            ),
          ),
        ),
        if (url != null)
          Positioned(
            bottom: 8,
            right: 8,
            child: Opacity(
              opacity: 0.8,
              child: ClipOval(
                child: Container(
                  color: Colors.black45,
                  child: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.white),
                    onPressed: _photoProcessing ? null : _confirmDeletePhoto,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MainAppBar(),
      body: RefreshIndicator(
        onRefresh: _loadUser,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _user == null
                ? const Center(child: Text('Failed to load profile'))
                : SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildPhoto(),
                        _buildUserInfo(),
                        _buildBio(),
                        _buildLanguages(),
                        _buildDogs(),
                        const SizedBox(height: 16),
                        Center(
                          child: ElevatedButton(
                            onPressed: () => context.push('/profile/complete'),
                            child: const Text('Edit Profile'),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
      ),
    );
  }
}
