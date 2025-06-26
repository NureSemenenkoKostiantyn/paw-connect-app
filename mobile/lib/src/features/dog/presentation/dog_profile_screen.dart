import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../../../models/dog_response.dart';
import '../../../models/current_user_response.dart';
import '../../../services/dog_service.dart';
import '../../../services/user_service.dart';

class DogProfileScreen extends StatefulWidget {
  final int dogId;

  const DogProfileScreen({super.key, required this.dogId});

  @override
  State<DogProfileScreen> createState() => _DogProfileScreenState();
}

class _DogProfileScreenState extends State<DogProfileScreen> {
  DogResponse? _dog;
  bool _loading = true;
  bool _notFound = false;

  int? _currentUserId;
  bool _photoProcessing = false;
  bool _pickingImage = false;

  late final PageController _pageController;
  int _pageIndex = 0;
  bool _showFullAbout = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadDog();
  }

  Future<void> _loadDog() async {
    setState(() {
      _loading = true;
      _notFound = false;
    });
    try {
      final dogRes = await DogService.instance.getDog(widget.dogId);
      final userRes = await UserService.instance.getCurrentUser();
      _dog = DogResponse.fromJson(dogRes.data);
      _currentUserId = CurrentUserResponse.fromJson(userRes.data).id;
      _pageIndex = 0;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        _notFound = true;
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  bool get _isOwner => _dog != null && _currentUserId == _dog!.ownerId;

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

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String _blobNameFromUrl(String url) {
    final uri = Uri.parse(url);
    if (uri.pathSegments.length <= 1) return uri.pathSegments.last;
    return uri.pathSegments.skip(1).join('/');
  }

  Future<void> _addPhoto() async {
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
        await DogService.instance.uploadPhoto(_dog!.id, File(compressed.path));
        await _loadDog();
      } finally {
        if (mounted) setState(() => _photoProcessing = false);
      }
    } finally {
      if (mounted) setState(() => _pickingImage = false);
    }
  }

  Future<void> _deletePhoto(String url) async {
    setState(() => _photoProcessing = true);
    try {
      await DogService.instance
          .deletePhoto(_dog!.id, _blobNameFromUrl(url));
      await _loadDog();
    } finally {
      if (mounted) setState(() => _photoProcessing = false);
    }
  }

  Future<void> _confirmDeletePhoto() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Photo'),
        content: const Text('Are you sure you want to delete this photo?'),
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
      await _deletePhoto(_dog!.photoUrls[_pageIndex]);
    }
  }

  Widget _buildCarousel() {
    final List<Widget> children = [];
    if (_dog!.photoUrls.isEmpty) {
      children.add(
        Container(
          color: Colors.black12,
          alignment: Alignment.center,
          child: Icon(
            Icons.pets,
            size: 80,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      );
    } else {
      children.add(
        PageView(
          controller: _pageController,
          onPageChanged: (i) => setState(() => _pageIndex = i),
          children: _dog!.photoUrls.asMap().entries.map((entry) {
            final i = entry.key;
            final url = entry.value;
            final image = CachedNetworkImage(
              imageUrl: url,
              fit: BoxFit.cover,
              placeholder: (context, url) =>
                  const Center(child: CircularProgressIndicator()),
              errorWidget: (context, url, error) => Container(
                color: Colors.black12,
                alignment: Alignment.center,
                child: Icon(
                  Icons.pets,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            );
            if (i == 0) {
              return Hero(tag: 'dog-${_dog!.id}', child: image);
            }
            return image;
          }).toList(),
        ),
      );
      children.add(
        Positioned(
          bottom: 16,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_dog!.photoUrls.length, (index) {
              final active = index == _pageIndex;
              return Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: active ? Colors.white : Colors.white54,
                ),
              );
            }),
          ),
        ),
      );
    }

    if (_photoProcessing) {
      children.add(
        Positioned.fill(
          child: Container(
            color: Colors.black45,
            alignment: Alignment.center,
            child: const CircularProgressIndicator(),
          ),
        ),
      );
    }

    if (_isOwner) {
      children.add(
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
                  onPressed: _photoProcessing || _pickingImage ? null : _addPhoto,
                ),
              ),
            ),
          ),
        ),
      );
      if (_dog!.photoUrls.isNotEmpty) {
        children.add(
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
                    onPressed:
                        _photoProcessing ? null : _confirmDeletePhoto,
                  ),
                ),
              ),
            ),
          ),
        );
      }
    }

    return Stack(children: children);
  }

  Widget _buildIdentity() {
    final age = _calculateAge(_dog!.birthdate);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _dog!.name,
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          if (_dog!.breed != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                _dog!.breed!,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Colors.grey),
              ),
            ),
          const SizedBox(height: 8),
          Row(
            children: [
              if (_dog!.gender != null)
                Row(
                  children: [
                    Icon(
                      _dog!.gender!.toLowerCase() == 'female'
                          ? Icons.female
                          : Icons.male,
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(_dog!.gender!),
                  ],
                ),
              if (_dog!.gender != null && _dog!.size != null)
                const SizedBox(width: 12),
              if (_dog!.size != null)
                Chip(label: Text(_dog!.size!)),
            ],
          ),
          if (age != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 20),
                const SizedBox(width: 4),
                Text('$age years old'),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAbout() {
    if (_dog!.about == null || _dog!.about!.isEmpty) return const SizedBox();
    final about = _dog!.about!;
    final maxLines = _showFullAbout ? null : 3;
    final overflow = _showFullAbout ? TextOverflow.visible : TextOverflow.ellipsis;
    final showButton = about.length > 120 && !_showFullAbout;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'About',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(about, maxLines: maxLines, overflow: overflow),
          if (showButton)
            TextButton(
              onPressed: () => setState(() => _showFullAbout = true),
              child: const Text('Show more'),
            ),
        ],
      ),
    );
  }

  Widget _buildTraits() {
    final traits = <String>[];
    if (_dog!.personality != null) traits.add(_dog!.personality!);
    if (_dog!.activityLevel != null) traits.add(_dog!.activityLevel!);
    if (traits.isEmpty) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Traits',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: traits.map((t) => Chip(label: Text(t))).toList(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: RefreshIndicator(
        onRefresh: _loadDog,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _notFound
                ? const Center(child: Text('Dog not found'))
                : _dog == null
                    ? const Center(child: Text('Failed to load dog'))
                    : CustomScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        slivers: [
                          SliverAppBar(
                            leading: IconButton(
                              icon: const Icon(Icons.arrow_back),
                              onPressed: () => Navigator.pop(context),
                            ),
                            backgroundColor: Colors.black54,
                            expandedHeight: 300,
                            flexibleSpace: FlexibleSpaceBar(
                              background: _buildCarousel(),
                            ),
                          ),
                          SliverToBoxAdapter(child: _buildIdentity()),
                          SliverToBoxAdapter(child: _buildAbout()),
                          SliverToBoxAdapter(child: _buildTraits()),
                          const SliverToBoxAdapter(child: SizedBox(height: 16)),
                        ],
                      ),
      ),
    );
  }
}
