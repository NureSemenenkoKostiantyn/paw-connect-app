import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../localization/app_localizations.dart';

import '../../../models/dog_response.dart';
import '../../../services/dog_service.dart';

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
      final res = await DogService.instance.getDog(widget.dogId);
      _dog = DogResponse.fromJson(res.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        _notFound = true;
      }
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

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildCarousel() {
    if (_dog!.photoUrls.isEmpty) {
      return Container(
        color: Colors.black12,
        alignment: Alignment.center,
        child: Icon(
          Icons.pets,
          size: 80,
          color: Theme.of(context).colorScheme.primary,
        ),
      );
    }

    return Stack(
      children: [
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
      ],
    );
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
                Text('$age ${context.l10n.translate("yearsOld")}'),
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
            context.l10n.translate('about'),
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(about, maxLines: maxLines, overflow: overflow),
          if (showButton)
            TextButton(
              onPressed: () => setState(() => _showFullAbout = true),
              child: Text(context.l10n.translate('showMore')),
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
            context.l10n.translate('traits'),
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
                ? Center(child: Text(context.l10n.translate('dogNotFound')))
                : _dog == null
                    ? Center(child: Text(context.l10n.translate('failedToLoadDog')))
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
