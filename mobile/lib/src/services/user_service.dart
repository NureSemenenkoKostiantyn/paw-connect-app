import 'dart:io';

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

  Future<Response<dynamic>> uploadProfilePhoto(File file) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path, filename: file.path.split('/').last),
    });
    return _dio.post('/users/current/profile-photo', data: formData);
  }

  Future<Response<dynamic>> deleteProfilePhoto() {
    return _dio.delete('/users/current/profile-photo');
  }
}
