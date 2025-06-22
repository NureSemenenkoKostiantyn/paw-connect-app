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
import '../../../models/dog.dart';
import '../../../services/user_service.dart';
import '../../dog/presentation/dog_card.dart';
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
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final cropped = await ImageCropper().cropImage(
      sourcePath: picked.path,
      aspectRatio: const CropAspectRatio(ratioX: 2, ratioY: 3),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Photo',
          toolbarColor: Theme.of(context).colorScheme.primary,
          toolbarWidgetColor: Colors.white,
          hideBottomControls: true,
          lockAspectRatio: true,
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
      final res = await UserService.instance.uploadProfilePhoto(compressed);
      _user = CurrentUserResponse.fromJson(res.data);
    } finally {
      if (mounted) setState(() => _photoProcessing = false);
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
                  onPressed: _photoProcessing ? null : _changePhoto,
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
                    onPressed: _photoProcessing ? null : _deletePhoto,
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
                          Text(
                            _user!.username,
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 8),
                          _buildPhoto(),
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
