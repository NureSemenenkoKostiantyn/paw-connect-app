import 'package:dio/dio.dart';
import '../env.dart';

class PreferenceService {
  PreferenceService._();

  static final PreferenceService instance = PreferenceService._();
  final Dio _dio = Dio(BaseOptions(baseUrl: '$apiBaseUrl/api/preferences'));

  Future<Response<dynamic>> getCurrent() {
    return _dio.get('/current');
  }

  Future<Response<dynamic>> updateCurrent(Map<String, dynamic> data) {
    return _dio.put('/current', data: data);
  }
}
