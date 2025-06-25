import 'package:dio/dio.dart';

import 'http_client.dart';

class EventService {
  EventService._();

  static final EventService instance = EventService._();
  final Dio _dio = HttpClient.instance.dio;

  Future<Response<dynamic>> searchEvents({
    required double latitude,
    required double longitude,
    required double radiusKm,
  }) {
    return _dio.get(
      '/events',
      queryParameters: {
        'near': '$latitude,$longitude,$radiusKm',
      },
    );
  }

  Future<Response<dynamic>> getEvent(int id) {
    return _dio.get('/events/$id');
  }
}
