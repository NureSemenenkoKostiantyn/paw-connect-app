class EventResponse {
  final int id;
  final String title;
  final String? description;
  final DateTime eventDateTime;
  final double latitude;
  final double longitude;
  final int hostId;
  final List<int> participantIds;

  EventResponse.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        title = json['title'],
        description = json['description'],
        eventDateTime = DateTime.parse(json['eventDateTime']),
        latitude = (json['latitude'] as num).toDouble(),
        longitude = (json['longitude'] as num).toDouble(),
        hostId = json['hostId'],
        participantIds = List<int>.from(json['participantIds'] ?? []);
}
