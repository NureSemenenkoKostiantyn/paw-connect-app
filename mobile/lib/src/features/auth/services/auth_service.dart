import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../services/http_client.dart';

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();
  final Dio _dio = HttpClient.instance.dio;

  Future<Response<dynamic>> signIn(String username, String password) {
    return _dio.post('/auth/signin', data: {
      'username': username,
      'password': password,
    });
  }

  Future<Response<dynamic>> signUp(
    String username,
    String email,
    String password,
  ) {
    return _dio.post('/auth/signup', data: {
      'username': username,
      'email': email,
      'password': password,
    });
  }

  static Future<void> logout(BuildContext context) async {
    await HttpClient.instance.clearCookies();
    if (context.mounted) context.go('/');
  }
}
