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
}
