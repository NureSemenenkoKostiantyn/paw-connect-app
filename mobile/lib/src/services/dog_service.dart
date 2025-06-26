import 'dart:io';
import 'package:dio/dio.dart';

import 'http_client.dart';

class DogService {
  DogService._();

  static final DogService instance = DogService._();
  final Dio _dio = HttpClient.instance.dio;

  Future<Response<dynamic>> createDog(Map<String, dynamic> data) {
    return _dio.post('/dogs', data: data);
  }

  Future<Response<dynamic>> getDog(int id) {
    return _dio.get('/dogs/$id');
  }

  Future<Response<dynamic>> updateDog(int id, Map<String, dynamic> data) {
    return _dio.put('/dogs/$id', data: data);
  }

  Future<Response<dynamic>> deleteDog(int id) {
    return _dio.delete('/dogs/$id');
  }

  Future<Response<dynamic>> uploadPhoto(int id, File file) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        file.path,
        filename: file.path.split('/').last,
      ),
    });
    return _dio.post('/dogs/$id/photos', data: formData);
  }

  Future<Response<dynamic>> deletePhoto(int id, String name) {
    return _dio.delete('/dogs/$id/photos', queryParameters: {'name': name});
  }
}
