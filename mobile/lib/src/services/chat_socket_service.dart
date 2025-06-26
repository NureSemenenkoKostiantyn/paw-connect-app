import 'dart:async';
import 'dart:convert';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import '../env.dart';
import 'http_client.dart';
import '../models/chat_message_response.dart';
import '../models/chat_message.dart';
import '../models/chat_response.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ChatSocketService {
  ChatSocketService._();

  static final ChatSocketService instance = ChatSocketService._();

  StompClient? _client;
  final Map<int, StreamController<ChatMessage>> _chatControllers = {};
  final Map<int, ChatMessage> _latestMessages = {};
  final Map<int, String> _chatTitles = {};
  final Map<int, int> _unreadCounts = {};
  final _unreadCountStream = StreamController<Map<int, int>>.broadcast();
  final Set<int> _subscribedChats = {};
  int? _activeChatId;
  int? _currentUserId;
  final _messageStream = StreamController<ChatMessage>.broadcast();
  Stream<Map<int, int>> get unreadCountStream => _unreadCountStream.stream;
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  Stream<ChatMessage> get messages => _messageStream.stream;
  Map<int, ChatMessage> get latestMessages => _latestMessages;
  final Map<int, List<ChatMessage>> _pendingMessages = {};

  void updateChatTitles(Iterable<ChatResponse> chats) {
    for (final chat in chats) {
      _chatTitles[chat.id] = chat.title;
    }
  }

  void updateChatTitle(int chatId, String title) {
    _chatTitles[chatId] = title;
  }

  Future<void> initNotifications(BuildContext context) async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    await _notifications.initialize(
      const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: (response) {
        final id = int.tryParse(response.payload ?? '');
        if (id != null) {
          GoRouter.of(context).push('/chats/$id');
        }
      },
    );
  }

  void setActiveChat(int? chatId) {
    _activeChatId = chatId;
    if (chatId != null) {
      _unreadCounts[chatId] = 0;
      _unreadCountStream.add(Map.from(_unreadCounts));
    }
  }

  void setCurrentUserId(int id) {
    _currentUserId = id;
  }

  Future<void> connect() async {
    if (_client != null) return;
    final jwt = await HttpClient.instance.getJwt();
    if (jwt == null) return;
    final url = '$apiBaseUrl/ws-chat';
    final headers = {'Cookie': '$jwtCookieName=$jwt'};
    _client = StompClient(
      config: StompConfig.sockJS(
        url: url,
        webSocketConnectHeaders: headers,
        stompConnectHeaders: headers,
        onConnect: _onConnect,
        onDisconnect: (frame) {
  print('[STOMP] Disconnected: ${frame.headers}');
},
onWebSocketError: (error) {
  print('[STOMP] WebSocket error: $error');
},
onStompError: (frame) {
  print('[STOMP] STOMP error: ${frame.body}');
},
      ),
    );
    _client!.activate();
  }

  void _onConnect(StompFrame frame) {
    print('[STOMP] Connected: ${frame.headers}');
    for (final chatId in _chatControllers.keys) {
      _subscribeChat(chatId);
    }
  }

  

  void subscribe(int chatId) {
    if (_subscribedChats.contains(chatId)) return;
    _chatControllers.putIfAbsent(chatId, () => StreamController.broadcast());
    if (_client != null && _client!.connected) {
      _subscribeChat(chatId);
    }
  }

  Stream<ChatMessage> messagesForChat(int chatId) {
    return _chatControllers
        .putIfAbsent(chatId, () => StreamController.broadcast())
        .stream;
  }

  void _subscribeChat(int chatId) {
    if (_subscribedChats.contains(chatId)) return;
    final sub = _client?.subscribe(
      destination: '/topic/chats/$chatId',
      callback: (frame) {
        final body = frame.body;
        if (body == null) return;
        final res =
            ChatMessageResponse.fromJson(_decode(body) as Map<String, dynamic>);
        final msg = ChatMessage.fromJson(res.toJson())
          ..status = ChatMessageStatus.sent;
        _latestMessages[msg.chatId] = msg;
        if (res.senderId == _currentUserId &&
            _pendingMessages[chatId]?.isNotEmpty == true) {
          final pending = _pendingMessages[chatId]!.removeAt(0);
          pending.status = ChatMessageStatus.sent;
          _messageStream.add(pending);
          _chatControllers[chatId]?.add(pending);
        } else {
          _messageStream.add(msg);
          _chatControllers[chatId]?.add(msg);
          if (_activeChatId != msg.chatId) {
            _unreadCounts[msg.chatId] = (_unreadCounts[msg.chatId] ?? 0) + 1;
            _unreadCountStream.add(Map.from(_unreadCounts));
            _showNotification(res);
          }
        }
      },
    );
    if (sub != null) {
      _subscribedChats.add(chatId);
    }
  }

  dynamic _decode(String body) {
    return body.isNotEmpty ? jsonDecode(body) : {};
  }

  void sendMessage(int chatId, String content) {
    if (_currentUserId == null) return;
    final msg = ChatMessage(
      chatId: chatId,
      senderId: _currentUserId!,
      content: content,
      timestamp: DateTime.now().toUtc().toIso8601String(),
      status: _client != null && _client!.connected
          ? ChatMessageStatus.sending
          : ChatMessageStatus.error,
    );
    _latestMessages[chatId] = msg;
    _messageStream.add(msg);
    _chatControllers[chatId]?.add(msg);
    if (msg.status == ChatMessageStatus.sending) {
      _pendingMessages.putIfAbsent(chatId, () => []).add(msg);
      _client?.send(
        destination: '/app/chat.send',
        body: jsonEncode({'chatId': chatId, 'content': content}),
      );
    }
  }

  void disconnect() {
    _client?.deactivate();
    _client = null;
    for (final c in _chatControllers.values) {
      c.close();
    }
    _chatControllers.clear();
    _latestMessages.clear();
    _pendingMessages.clear();
    _unreadCounts.clear();
    _subscribedChats.clear();
  }

  Future<void> _showNotification(ChatMessageResponse msg) async {
    const androidDetails = AndroidNotificationDetails(
      'chat_messages',
      'Chat Messages',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    const details = NotificationDetails(android: androidDetails);
    final title = _chatTitles[msg.chatId] ?? 'New message';
    await _notifications.show(
      msg.chatId.hashCode,
      title,
      msg.content,
      details,
      payload: msg.chatId.toString(),
    );
  }
}
