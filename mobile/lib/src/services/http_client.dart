import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';

import '../env.dart';

class HttpClient {
  HttpClient._() {
    _dio = Dio(BaseOptions(baseUrl: '$apiBaseUrl/api'));
    _cookieJar = CookieJar();
    _dio.interceptors.add(CookieManager(_cookieJar));
  }

  static final HttpClient instance = HttpClient._();

  late final Dio _dio;
  late final CookieJar _cookieJar;

  Dio get dio => _dio;

  bool hasAuthCookie() {
    final cookies =
        _cookieJar.loadForRequest(Uri.parse('$apiBaseUrl/api'));
    return cookies.any((cookie) => cookie.name == jwtCookieName);
  }

  Future<void> clearCookies() async {
    await _cookieJar.deleteAll();
  }
}

