import 'package:dio/dio.dart';
import '../env.dart';

class UserService {
  UserService._();

  static final UserService instance = UserService._();
  final Dio _dio = Dio(BaseOptions(baseUrl: '$apiBaseUrl/api/users'));

  Future<Response<dynamic>> getCurrentUser() {
    return _dio.get('/current');
  }

  Future<Response<dynamic>> updateCurrentUser(Map<String, dynamic> data) {
    return _dio.put('/current', data: data);
  }
}
