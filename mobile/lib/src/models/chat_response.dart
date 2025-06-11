import 'dart:core';

class ChatResponse {
  final int id;
  final String type;
  final int? eventId;
  final List<int> participantIds;

  ChatResponse.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        type = json['type'],
        eventId = json['eventId'],
        participantIds = List<int>.from(json['participantIds'] ?? []);
}
