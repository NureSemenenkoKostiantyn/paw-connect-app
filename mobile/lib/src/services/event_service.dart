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

  Future<Response<dynamic>> createEvent(Map<String, dynamic> data) {
    return _dio.post('/events', data: data);
  }

  Future<Response<dynamic>> joinEvent(int id, {String status = 'GOING'}) {
    return _dio.post('/events/$id/join', queryParameters: {'status': status});
  }

  Future<Response<dynamic>> leaveEvent(int id) {
    return _dio.delete('/events/$id/leave');
  }

  Future<Response<dynamic>> deleteEvent(int id) {
    return _dio.delete('/events/$id');
  }
}
