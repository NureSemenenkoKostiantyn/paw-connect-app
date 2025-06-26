import 'package:dio/dio.dart';

import 'http_client.dart';

class ChatService {
  ChatService._();

  static final ChatService instance = ChatService._();
  final Dio _dio = HttpClient.instance.dio;

  Future<Response<dynamic>> getChats() {
    return _dio.get('/chats');
  }

  Future<Response<dynamic>> getMessages(int chatId,
      {int page = 0, int limit = 20}) {
    return _dio.get('/chats/$chatId/messages',
        queryParameters: {'page': page, 'limit': limit});
  }

  Future<Response<dynamic>> markAsRead(int chatId, int messageId) {
    return _dio.patch('/chats/$chatId/read/$messageId');
  }
}
