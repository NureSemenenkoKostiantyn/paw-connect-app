import 'package:flutter/material.dart';
import 'package:flutter_tindercard/flutter_tindercard.dart';

import '../../../models/candidate_user.dart';
import '../../../services/match_service.dart';
import '../../../shared/main_app_bar.dart';
import 'candidate_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CardController _cardController = CardController();
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
      final res = await MatchService.instance.getCandidates();
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
      body = const Center(child: Text('No candidates found'));
    } else {
      body = Center(
        child: TinderSwapCard(
          cardController: _cardController,
          totalNum: _candidates.length,
          maxWidth: MediaQuery.of(context).size.width * 0.9,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
          minWidth: MediaQuery.of(context).size.width * 0.8,
          minHeight: MediaQuery.of(context).size.height * 0.7,
          swipeCompleteCallback:
              (CardSwipeOrientation orientation, int index) async {
            if (orientation == CardSwipeOrientation.LEFT) {
              await _createSwipe(index, 'PASS');
            } else if (orientation == CardSwipeOrientation.RIGHT) {
              await _createSwipe(index, 'LIKE');
            }
            if (index == _candidates.length - 1) {
              _loadCandidates();
            }
          },
          cardBuilder: (context, index) {
            return CandidateCard(candidate: _candidates[index]);
          },
        ),
      );
    }

    return Scaffold(
      appBar: const MainAppBar(),
      body: RefreshIndicator(onRefresh: _loadCandidates, child: body),
    );
  }
}
