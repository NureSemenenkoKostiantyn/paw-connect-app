import 'package:dio/dio.dart';

import 'http_client.dart';

class MatchService {
  MatchService._();

  static final MatchService instance = MatchService._();
  final Dio _dio = HttpClient.instance.dio;

  Future<Response<dynamic>> getCandidates({int limit = 20, double radiusKm = 25}) {
    return _dio.get(
      '/matches/candidates',
      queryParameters: {
        'limit': limit,
        'radiusKm': radiusKm,
      },
    );
  }

  Future<Response<dynamic>> createSwipe({
    required int targetUserId,
    required String decision,
  }) {
    return _dio.post(
      '/matches/swipes',
      data: {
        'targetUserId': targetUserId,
        'decision': decision,
      },
    );
  }
}
