enum ChatMessageStatus { sending, sent, error }

class ChatMessage {
  final int? id;
  final int chatId;
  final int senderId;
  final String content;
  final String timestamp;
  ChatMessageStatus status;

  ChatMessage({
    this.id,
    required this.chatId,
    required this.senderId,
    required this.content,
    required this.timestamp,
    this.status = ChatMessageStatus.sent,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      chatId: json['chatId'],
      senderId: json['senderId'],
      content: json['content'],
      timestamp: json['timestamp'],
      status: ChatMessageStatus.sent,
    );
  }

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
