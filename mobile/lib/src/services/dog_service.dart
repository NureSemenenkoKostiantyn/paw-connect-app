import 'package:dio/dio.dart';
import '../env.dart';

class DogService {
  DogService._();

  static final DogService instance = DogService._();
  final Dio _dio = Dio(BaseOptions(baseUrl: '$apiBaseUrl/api/dogs'));

  Future<Response<dynamic>> createDog(Map<String, dynamic> data) {
    return _dio.post('', data: data);
  }

  Future<Response<dynamic>> getDog(int id) {
    return _dio.get('/$id');
  }
}
