class ChatMessageResponse {
  final int id;
  final int chatId;
  final int senderId;
  final String content;
  final String timestamp;

  ChatMessageResponse.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        chatId = json['chatId'],
        senderId = json['senderId'],
        content = json['content'],
        timestamp = json['timestamp'];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chatId': chatId,
      'senderId': senderId,
      'content': content,
      'timestamp': timestamp,
    };
  }
}
