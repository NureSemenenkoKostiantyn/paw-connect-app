import 'dart:core';

import 'chat_message_response.dart';

class ChatResponse {
  final int id;
  final String type;
  final int? eventId;
  final List<int> participantIds;
  final ChatMessageResponse? lastMessage;
  final int unreadCount;

  ChatResponse.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        type = json['type'],
        eventId = json['eventId'],
        participantIds = List<int>.from(json['participantIds'] ?? []),
        lastMessage = json['lastMessage'] != null
            ? ChatMessageResponse.fromJson(
                json['lastMessage'] as Map<String, dynamic>)
            : null,
        unreadCount = json['unreadCount'] ?? 0;
}
