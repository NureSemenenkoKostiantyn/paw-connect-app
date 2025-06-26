import 'dart:core';

import 'chat_message_response.dart';

class ChatResponse {
  final int id;
  final String type;
  final String title;
  final int? eventId;
  final List<int> participantIds;
  final ChatMessageResponse? lastMessage;
  final int unreadCount;

  const ChatResponse({
    required this.id,
    required this.type,
    required this.title,
    this.eventId,
    this.participantIds = const [],
    this.lastMessage,
    this.unreadCount = 0,
  });

  ChatResponse.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        type = json['type'],
        title = json['title'] ?? 'Chat ${json['id']}',
        eventId = json['eventId'],
        participantIds = List<int>.from(json['participantIds'] ?? []),
        lastMessage = json['lastMessage'] != null
            ? ChatMessageResponse.fromJson(
                json['lastMessage'] as Map<String, dynamic>)
            : null,
        unreadCount = json['unreadCount'] ?? 0;

  ChatResponse copyWith({int? unreadCount}) {
    return ChatResponse(
      id: id,
      type: type,
      title: title,
      eventId: eventId,
      participantIds: List<int>.from(participantIds),
      lastMessage: lastMessage != null
          ? ChatMessageResponse.fromJson(lastMessage!.toJson())
          : null,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}
