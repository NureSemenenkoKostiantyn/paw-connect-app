import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../models/chat_response.dart';

class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final ChatResponse chat;
  const ChatAppBar({super.key, required this.chat});

  void _openPlaceholder(BuildContext context) {
    if (chat.type.toUpperCase() == 'GROUP') {
      if (chat.eventId != null) {
        context.push('/events/${chat.eventId}');
      }
    } else {
      context.push('/public/${chat.title}');
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget titleWidget;
    if (chat.type.toUpperCase() == 'GROUP') {
      titleWidget = Text(chat.title);
    } else {
      titleWidget = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircleAvatar(radius: 16),
          const SizedBox(width: 8),
          Text(chat.title),
        ],
      );
    }
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      title: InkWell(onTap: () => _openPlaceholder(context), child: titleWidget),
      centerTitle: true,
      actions: [
        PopupMenuButton<int>(
          itemBuilder: (context) => const [
            PopupMenuItem(value: 0, child: Text('Action 1')),
            PopupMenuItem(value: 1, child: Text('Action 2')),
          ],
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
