import 'package:dio/dio.dart';

import 'http_client.dart';

class LanguageService {
  LanguageService._();

  static final LanguageService instance = LanguageService._();
  final Dio _dio = HttpClient.instance.dio;

  Future<Response<dynamic>> getAll() {
    return _dio.get('/user/languages');
  }
}
