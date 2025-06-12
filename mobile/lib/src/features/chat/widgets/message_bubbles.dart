import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../models/chat_message_response.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessageResponse message;
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
    final align = isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
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
            crossAxisAlignment: align,
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
                    Icon(Icons.check, size: 12, color: textColor),
                    Icon(Icons.check, size: 12, color: textColor),
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

