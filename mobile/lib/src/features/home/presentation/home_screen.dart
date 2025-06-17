import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';

import '../../../models/candidate_user.dart';
import '../../../services/match_service.dart';
import '../../../services/settings_service.dart';
import '../../../shared/main_app_bar.dart';
import 'candidate_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CardSwiperController _cardController = CardSwiperController();
  final List<CandidateUser> _candidates = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCandidates();
  }

  Future<void> _loadCandidates() async {
    setState(() => _loading = true);
    try {
      final res = await MatchService.instance
          .getCandidates(radiusKm: SettingsService.instance.candidateDistanceKm);
      _candidates
        ..clear()
        ..addAll((res.data as List<dynamic>)
            .map((e) => CandidateUser.fromJson(e as Map<String, dynamic>)));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _createSwipe(int index, String decision) async {
    if (index < 0 || index >= _candidates.length) return;
    final candidate = _candidates[index];
    await MatchService.instance
        .createSwipe(targetUserId: candidate.id, decision: decision);
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (_loading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (_candidates.isEmpty) {
      body = Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('No candidates found'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                double newRadius =
                    (SettingsService.instance.candidateDistanceKm + 5)
                        .clamp(1, 101);
                await SettingsService.instance
                    .setCandidateDistanceKm(newRadius.toDouble());
                _loadCandidates();
              },
              child: const Text('Increase search radius'),
            ),
          ],
        ),
      );
    } else {
      body = LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = width * 11 / 7;
          return Column(
            children: [
              SizedBox(
                width: width,
                height: height,
                child: CardSwiper(
                  controller: _cardController,
                  cardsCount: _candidates.length,
                  numberOfCardsDisplayed: 1,
                  onSwipe: (int previousIndex, int? currentIndex,
                      CardSwiperDirection direction) async {
                    if (direction == CardSwiperDirection.left) {
                      await _createSwipe(previousIndex, 'PASS');
                    } else if (direction == CardSwiperDirection.right) {
                      await _createSwipe(previousIndex, 'LIKE');
                    }
                    if (previousIndex == _candidates.length - 1) {
                      _loadCandidates();
                    }
                    return true;
                  },
                  cardBuilder:
                      (context, index, horizontalOffset, verticalOffset) {
                    return CandidateCard(
                      candidate: _candidates[index],
                      cardController: _cardController,
                    );
                  },
                ),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FloatingActionButton.small(
                    heroTag: null,
                    onPressed: () => _cardController.undo(),
                    child: const Icon(Icons.replay),
                  ),
                  const SizedBox(width: 16),
                  FloatingActionButton(
                    heroTag: null,
                    onPressed: () =>
                        _cardController.swipe(CardSwiperDirection.left),
                    child: const Icon(Icons.close),
                  ),
                  const SizedBox(width: 16),
                  FloatingActionButton(
                    heroTag: null,
                    onPressed: () =>
                        _cardController.swipe(CardSwiperDirection.right),
                    child: const Icon(Icons.favorite),
                  ),
                  const SizedBox(width: 16),
                  FloatingActionButton.small(
                    heroTag: null,
                    onPressed: () =>
                        _cardController.swipe(CardSwiperDirection.top),
                    child: const Icon(Icons.star),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          );
        },
      );
    }

    return Scaffold(
      appBar: const MainAppBar(),
      body: RefreshIndicator(onRefresh: _loadCandidates, child: body),
    );
  }
}
