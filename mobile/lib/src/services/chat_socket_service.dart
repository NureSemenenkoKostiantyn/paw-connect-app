import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

import '../env.dart';
import '../models/chat_message.dart';
import '../models/chat_message_response.dart';
import '../models/chat_response.dart';
import 'http_client.dart';

class ChatSocketService {
  ChatSocketService._();

  static final ChatSocketService instance = ChatSocketService._();

  StompClient? _client;
  StreamSubscription<ConnectivityResult>? _connectivitySub;

  final ValueNotifier<String?> statusNotifier = ValueNotifier(null);

  final Map<int, StreamController<ChatMessage>> _chatStreams = {};
  final Map<int, ChatMessage> _latestMessages = {};
  final Map<int, String> _chatTitles = {};
  final Map<int, List<ChatMessage>> _pendingMessages = {};

  final _globalMessages = StreamController<ChatMessage>.broadcast();
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  int? _activeChatId;
  int? _currentUserId;

  Stream<ChatMessage> get messages => _globalMessages.stream;
  Map<int, ChatMessage> get latestMessages => _latestMessages;

  Future<void> init() async {
    _connectivitySub = Connectivity().onConnectivityChanged.listen((result) {
      if (result != ConnectivityResult.none) {
        if (_client == null) {
          connect();
        }
      } else {
        statusNotifier.value = 'Offline';
      }
    });
  }

  Future<void> initNotifications(BuildContext context) async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    await _notifications.initialize(
      const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: (response) {
        final id = int.tryParse(response.payload ?? '');
        if (id != null) {
          GoRouter.of(context).push('/chats/\$id');
        }
      },
    );
  }

  void setActiveChat(int? id) {
    _activeChatId = id;
  }

  void setCurrentUserId(int id) {
    _currentUserId = id;
  }

  void updateChatTitles(Iterable<ChatResponse> chats) {
    for (final chat in chats) {
      _chatTitles[chat.id] = chat.title;
    }
  }

  void updateChatTitle(int chatId, String title) {
    _chatTitles[chatId] = title;
  }

  Future<void> connect() async {
    if (_client != null) return;

    statusNotifier.value = 'Connecting...';
    final jwt = await HttpClient.instance.getJwt();
    if (jwt == null) return;

    final url = '${apiBaseUrl.replaceFirst('http', 'ws')}/ws-chat';
    final headers = {'Cookie': '\$jwtCookieName=\$jwt'};

    _client = StompClient(
      config: StompConfig.sockJS(
        url: url,
        webSocketConnectHeaders: headers,
        stompConnectHeaders: headers,
        onConnect: _onConnect,
        onDisconnect: (_) {
          statusNotifier.value = 'Reconnecting...';
        },
        onWebSocketError: (_) {
          statusNotifier.value = 'Reconnecting...';
        },
        onStompError: (_) {
          statusNotifier.value = 'Reconnecting...';
        },
        heartbeatIncoming: const Duration(seconds: 10),
        heartbeatOutgoing: const Duration(seconds: 10),
        reconnectDelay: const Duration(seconds: 5),
      ),
    );

    _client!.activate();
  }

  void _onConnect(StompFrame frame) {
    statusNotifier.value = null;
    for (final id in _chatStreams.keys) {
      _subscribe(id);
    }
  }

  void subscribe(int chatId) {
    _chatStreams.putIfAbsent(chatId, () => StreamController.broadcast());
    if (_client?.connected == true) {
      _subscribe(chatId);
    }
  }

  Stream<ChatMessage> messagesForChat(int chatId) {
    return _chatStreams
        .putIfAbsent(chatId, () => StreamController.broadcast())
        .stream;
  }

  void _subscribe(int chatId) {
    _client?.subscribe(
      destination: '/topic/chats/\$chatId',
      callback: (frame) {
        final body = frame.body;
        if (body == null) return;
        final res = ChatMessageResponse.fromJson(
          jsonDecode(body) as Map<String, dynamic>,
        );
        final msg = ChatMessage.fromJson(res.toJson())
          ..status = ChatMessageStatus.sent;
        _latestMessages[msg.chatId] = msg;

        if (res.senderId == _currentUserId &&
            _pendingMessages[chatId]?.isNotEmpty == true) {
          final pending = _pendingMessages[chatId]!.removeAt(0);
          pending.status = ChatMessageStatus.sent;
          _dispatchMessage(pending);
        } else {
          _dispatchMessage(msg);
          if (_activeChatId != msg.chatId) {
            _showNotification(res);
          }
        }
      },
    );
  }

  void sendMessage(int chatId, String content) {
    if (_currentUserId == null) return;
    final msg = ChatMessage(
      chatId: chatId,
      senderId: _currentUserId!,
      content: content,
      timestamp: DateTime.now().toUtc().toIso8601String(),
      status: _client?.connected == true
          ? ChatMessageStatus.sending
          : ChatMessageStatus.error,
    );

    _latestMessages[chatId] = msg;
    _dispatchMessage(msg);

    if (msg.status == ChatMessageStatus.sending) {
      _pendingMessages.putIfAbsent(chatId, () => []).add(msg);
      _client?.send(
        destination: '/app/chat.send',
        body: jsonEncode({'chatId': chatId, 'content': content}),
      );
    }
  }

  void disconnect() {
    statusNotifier.value = null;
    _client?.deactivate();
    _client = null;
    for (final c in _chatStreams.values) {
      c.close();
    }
    _chatStreams.clear();
    _latestMessages.clear();
    _pendingMessages.clear();
  }

  void dispose() {
    _connectivitySub?.cancel();
    _connectivitySub = null;
    _globalMessages.close();
    disconnect();
  }

  void _dispatchMessage(ChatMessage msg) {
    _globalMessages.add(msg);
    _chatStreams[msg.chatId]?.add(msg);
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

