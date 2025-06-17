import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../models/candidate_user.dart';
import '../../../models/dog_response.dart';

class CandidateCard extends StatefulWidget {
  final CandidateUser candidate;
  final CardSwiperController cardController;

  const CandidateCard({
    super.key,
    required this.candidate,
    required this.cardController,
  });

  @override
  State<CandidateCard> createState() => _CandidateCardState();
}

class _CandidateCardState extends State<CandidateCard> {
  late final PageController _pageController;
  late final List<_Slide> _slides;
  int _pageIndex = 0;

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
  void initState() {
    super.initState();
    _pageController = PageController();
    _slides = _buildSlides();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<_Slide> _buildSlides() {
    final List<_Slide> slides = [];
    if (widget.candidate.profilePhotoUrl != null) {
      slides.add(
        _Slide(
          imageUrl: widget.candidate.profilePhotoUrl!,
          title: widget.candidate.username,
          subtitle: '${widget.candidate.distanceKm.toStringAsFixed(1)} km away',
          isOwner: true,
        ),
      );
    }

    for (final DogResponse dog in widget.candidate.dogs) {
      final url = dog.photoUrls.isNotEmpty ? dog.photoUrls.first : null;
      final age = _calculateAge(dog.birthdate);
      slides.add(
        _Slide(
          imageUrl: url,
          title: age != null ? '${dog.name}, $age y.o.' : dog.name,
          subtitle: dog.breed ?? '',
          isOwner: false,
          dogId: dog.id,
        ),
      );
    }
    if (slides.isEmpty) {
      slides.add(
        _Slide(
          imageUrl: null,
          title: widget.candidate.username,
          subtitle: '${widget.candidate.distanceKm.toStringAsFixed(1)} km away',
          isOwner: true,
        ),
      );
    }
    return slides;
  }

  void _handleTap(TapUpDetails details, BoxConstraints constraints) {
    final dx = details.localPosition.dx;
    if (dx < constraints.maxWidth / 2) {
      if (_pageIndex > 0) {
        _pageController.previousPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    } else {
      if (_pageIndex < _slides.length - 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  void _openProfile() {
    final slide = _slides[_pageIndex];
    if (slide.isOwner) {
      context.pushNamed(
        'public-profile',
        pathParameters: {'username': widget.candidate.username},
      );
    } else if (slide.dogId != null) {
      context.pushNamed(
        'dog-profile',
        pathParameters: {'id': slide.dogId.toString()},
      );
    }
  }

  Widget _buildActionButton(IconData icon, VoidCallback onPressed) {
    return FloatingActionButton.small(
      heroTag: null,
      onPressed: onPressed,
      child: Icon(icon),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 7 / 10,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTapUp: (details) => _handleTap(details, constraints),
              child: Stack(
              children: [
                PageView(
                  controller: _pageController,
                  onPageChanged: (i) => setState(() => _pageIndex = i),
                  physics: const NeverScrollableScrollPhysics(),
                  children: _slides.map((slide) {
                    if (slide.imageUrl != null) {
                      return CachedNetworkImage(
                        imageUrl: slide.imageUrl!,
                        fit: BoxFit.contain,
                        width: double.infinity,
                        height: double.infinity,
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
                    }
                    return Container(
                      color: Colors.black12,
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.pets,
                        size: 80,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    );
                  }).toList(),
                ),
                Positioned(
                  top: 8,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_slides.length, (index) {
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
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [Colors.black54, Colors.transparent],
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _slides[_pageIndex].title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (_slides[_pageIndex].subtitle.isNotEmpty)
                                Text(
                                  _slides[_pageIndex].subtitle,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              const SizedBox(height: 16),
                              Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildActionButton(
                              Icons.replay,
                              () => widget.cardController.undo(),
                            ),
                            const SizedBox(width: 16),
                            _buildActionButton(
                              Icons.close,
                              () => widget.cardController.swipe(
                                CardSwiperDirection.left,
                              ),
                            ),
                            const SizedBox(width: 16),
                            _buildActionButton(
                              Icons.favorite,
                              () => widget.cardController.swipe(
                                CardSwiperDirection.right,
                              ),
                            ),
                            const SizedBox(width: 16),
                            _buildActionButton(
                              Icons.star,
                              () => widget.cardController.swipe(
                                CardSwiperDirection.top,
                              ),
                            ),
                          ],
                        ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        FloatingActionButton(
                          mini: true,
                          onPressed: _openProfile,
                          child: const Icon(Icons.info_outline),
                        ),
                        
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Slide {
  final String? imageUrl;
  final String title;
  final String subtitle;
  final bool isOwner;
  final int? dogId;

  _Slide({
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.isOwner,
    this.dogId,
  });
}
