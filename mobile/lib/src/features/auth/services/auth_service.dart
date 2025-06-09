import 'package:dio/dio.dart';

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();
  final Dio _dio = Dio(BaseOptions(baseUrl: '/api/auth'));

  Future<Response<dynamic>> signIn(String username, String password) {
    return _dio.post('/signin', data: {
      'username': username,
      'password': password,
    });
  }

  Future<Response<dynamic>> signUp(
    String username,
    String email,
    String password,
  ) {
    return _dio.post('/signup', data: {
      'username': username,
      'email': email,
      'password': password,
    });
  }
}
