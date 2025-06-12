import 'package:flutter/material.dart';
import 'src/app.dart';
import 'src/services/http_client.dart';
import 'src/services/chat_service.dart';
import 'src/services/chat_socket_service.dart';
import 'src/models/chat_response.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HttpClient.instance.init();
  final hasCookie = await HttpClient.instance.hasAuthCookie();
  if (hasCookie) {
    await ChatSocketService.instance.connect();
    try {
      final res = await ChatService.instance.getChats();
      final chats = (res.data as List<dynamic>)
          .map((e) => ChatResponse.fromJson(e as Map<String, dynamic>));
      ChatSocketService.instance.updateChatTitles(chats);
      for (final chat in chats) {
        ChatSocketService.instance.subscribe(chat.id);
      }
    } catch (_) {
      // ignore errors during startup
    }
  }
  runApp(App(initialLocation: hasCookie ? '/home' : '/'));
}
