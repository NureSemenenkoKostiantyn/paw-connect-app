import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../models/chat_message.dart';
import '../../../services/chat_socket_service.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;
  const MessageBubble({super.key, required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final time = DateTime.parse(message.timestamp).toLocal();
    final bg = isMe
        ? Theme.of(context).colorScheme.primaryContainer
        : Theme.of(context).colorScheme.surfaceContainerHighest;
    final textColor = isMe
        ? Theme.of(context).colorScheme.onPrimaryContainer
        : Theme.of(context).colorScheme.onSurfaceVariant;
    return Row(
      mainAxisAlignment:
          isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          constraints:
              BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(12).copyWith(
              topLeft: Radius.circular(isMe ? 12 : 0),
              topRight: Radius.circular(isMe ? 0 : 12),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(message.content, style: TextStyle(color: textColor)),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(DateFormat.Hm().format(time),
                      style: Theme.of(context)
                          .textTheme
                          .labelSmall
                          ?.copyWith(color: textColor)),
                  if (isMe) ...[
                    const SizedBox(width: 4),
                    if (message.status == ChatMessageStatus.sending)
                      SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(textColor),
                        ),
                      )
                    else if (message.status == ChatMessageStatus.sent)
                      Icon(Icons.check, size: 12, color: textColor)
                    else
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.error,
                            size: 12,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          GestureDetector(
                            onTap: () => ChatSocketService.instance
                                .sendMessage(message.chatId, message.content),
                            child: Icon(
                              Icons.refresh,
                              size: 12,
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ],
                      ),
                  ]
                ],
              )
            ],
          ),
        ),
      ],
    );
  }
}

class SentMessageBubble extends MessageBubble {
  const SentMessageBubble({super.key, required super.message})
      : super(isMe: true);
}

class ReceivedMessageBubble extends MessageBubble {
  const ReceivedMessageBubble({super.key, required super.message})
      : super(isMe: false);
}

