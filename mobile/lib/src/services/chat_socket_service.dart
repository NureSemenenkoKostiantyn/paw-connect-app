import 'dart:async';
import 'dart:convert';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import '../env.dart';
import 'http_client.dart';
import '../models/chat_message_response.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class ChatSocketService {
  ChatSocketService._();

  static final ChatSocketService instance = ChatSocketService._();

  StompClient? _client;
  final Map<int, StreamController<ChatMessageResponse>> _chatControllers = {};
  final Map<int, ChatMessageResponse> _latestMessages = {};
  int? _activeChatId;
  final _messageStream = StreamController<ChatMessageResponse>.broadcast();
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  Stream<ChatMessageResponse> get messages => _messageStream.stream;
  Map<int, ChatMessageResponse> get latestMessages => _latestMessages;

  Future<void> initNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    await _notifications.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );
  }

  void setActiveChat(int? chatId) {
    _activeChatId = chatId;
  }

  Future<void> connect() async {
    if (_client != null) return;
    final jwt = await HttpClient.instance.getJwt();
    if (jwt == null) return;
    final url = '${apiBaseUrl.replaceFirst('http', 'ws')}/ws-chat';
    final headers = {'Cookie': '$jwtCookieName=$jwt'};
    _client = StompClient(
      config: StompConfig.sockJS(
        url: url,
        webSocketConnectHeaders: headers,
        stompConnectHeaders: headers,
        onConnect: _onConnect,
      ),
    );
    _client!.activate();
  }

  void _onConnect(StompFrame frame) {
    for (final chatId in _chatControllers.keys) {
      _subscribeChat(chatId);
    }
  }

  void subscribe(int chatId) {
    _chatControllers.putIfAbsent(chatId, () => StreamController.broadcast());
    if (_client != null && _client!.connected) {
      _subscribeChat(chatId);
    }
  }

  Stream<ChatMessageResponse> messagesForChat(int chatId) {
    return _chatControllers.putIfAbsent(
        chatId, () => StreamController.broadcast()).stream;
  }

  void _subscribeChat(int chatId) {
    _client?.subscribe(
      destination: '/topic/chats/$chatId',
      callback: (frame) {
        final body = frame.body;
        if (body == null) return;
        final msg =
            ChatMessageResponse.fromJson(_decode(body) as Map<String, dynamic>);
        _latestMessages[msg.chatId] = msg;
        _messageStream.add(msg);
        _chatControllers[chatId]?.add(msg);
        if (_activeChatId != msg.chatId) {
          _showNotification(msg);
        }
      },
    );
  }

  dynamic _decode(String body) {
    return body.isNotEmpty ? jsonDecode(body) : {};
  }

  void sendMessage(int chatId, String content) {
    _client?.send(
      destination: '/app/chat.send',
      body: jsonEncode({'chatId': chatId, 'content': content}),
    );
  }

  void disconnect() {
    _client?.deactivate();
    _client = null;
    for (final c in _chatControllers.values) {
      c.close();
    }
    _chatControllers.clear();
    _latestMessages.clear();
  }

  Future<void> _showNotification(ChatMessageResponse msg) async {
    const androidDetails = AndroidNotificationDetails(
      'chat_messages',
      'Chat Messages',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    const details = NotificationDetails(android: androidDetails);
    await _notifications.show(
      msg.chatId.hashCode,
      'New message',
      msg.content,
      details,
    );
  }
}
