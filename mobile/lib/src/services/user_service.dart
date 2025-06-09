import 'package:dio/dio.dart';

import 'http_client.dart';

class UserService {
  UserService._();

  static final UserService instance = UserService._();
  final Dio _dio = HttpClient.instance.dio;

  Future<Response<dynamic>> getCurrentUser() {
    return _dio.get('/users/current');
  }

  Future<Response<dynamic>> updateCurrentUser(Map<String, dynamic> data) {
    return _dio.put('/users/current', data: data);
  }
}
