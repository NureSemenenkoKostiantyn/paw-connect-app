import 'package:flutter/material.dart';
import '../services/chat_socket_service.dart';

class ConnectionStatusBubble extends StatelessWidget {
  const ConnectionStatusBubble({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: ChatSocketService.instance.statusNotifier,
      builder: (context, value, _) {
        if (value == null) return const SizedBox.shrink();
        return Positioned(
          left: 16,
          bottom: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              value,
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
        );
      },
    );
  }
}
