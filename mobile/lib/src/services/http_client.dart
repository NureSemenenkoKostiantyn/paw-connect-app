

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../env.dart';

class HttpClient {
  HttpClient._() {
    _dio = Dio(BaseOptions(baseUrl: '$apiBaseUrl/api'));
  }

  static final HttpClient instance = HttpClient._();

  late final Dio _dio;
  late PersistCookieJar _cookieJar;

  Dio get dio => _dio;

  Future<void> init() async {
    final dir = await getApplicationSupportDirectory();
    _cookieJar =
        PersistCookieJar(storage: FileStorage(p.join(dir.path, 'cookies')));
    _dio.interceptors.add(CookieManager(_cookieJar));
  }

Future<bool> hasAuthCookie() async {
  final cookies =
      await _cookieJar.loadForRequest(Uri.parse('$apiBaseUrl/api'));
  return cookies.any((cookie) => cookie.name == jwtCookieName);
}

  Future<void> clearCookies() async {
    await _cookieJar.deleteAll();
  }

  Future<String?> getJwt() async {
    final cookies =
        await _cookieJar.loadForRequest(Uri.parse('$apiBaseUrl/api'));
    for (final cookie in cookies) {
      if (cookie.name == jwtCookieName) return cookie.value;
    }
    return null;
  }
}

