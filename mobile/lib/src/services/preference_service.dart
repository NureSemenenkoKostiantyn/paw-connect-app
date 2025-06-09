import 'package:dio/dio.dart';

import 'http_client.dart';

class PreferenceService {
  PreferenceService._();

  static final PreferenceService instance = PreferenceService._();
  final Dio _dio = HttpClient.instance.dio;

  Future<Response<dynamic>> getCurrent() {
    return _dio.get('/preferences/current');
  }

  Future<Response<dynamic>> updateCurrent(Map<String, dynamic> data) {
    return _dio.put('/preferences/current', data: data);
  }
}
