import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../models/chat_response.dart';
import '../../../services/chat_service.dart';
import '../../../services/chat_socket_service.dart';
import '../../../shared/main_app_bar.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final List<ChatResponse> _chats = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    ChatSocketService.instance.initNotifications(context);
    ChatSocketService.instance.connect();
    _loadChats();
    ChatSocketService.instance.messages.listen((msg) {
      if (mounted) setState(() {});
    });
  }

  Future<void> _loadChats() async {
    setState(() => _loading = true);
    try {
      final res = await ChatService.instance.getChats();
      _chats
        ..clear()
        ..addAll((res.data as List<dynamic>)
            .map((e) => ChatResponse.fromJson(e as Map<String, dynamic>)));
      ChatSocketService.instance.updateChatTitles(_chats);
      for (final chat in _chats) {
        ChatSocketService.instance.subscribe(chat.id);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _formatTimestamp(dynamic message) {
    if (message == null) return '';
    try {
      final date = DateTime.parse(message.timestamp).toLocal();
      final now = DateTime.now();
      if (date.year == now.year &&
          date.month == now.month &&
          date.day == now.day) {
        return DateFormat.Hm().format(date);
      }
      if (date.year == now.year) {
        return DateFormat('d MMM').format(date);
      }
      return DateFormat('d MMM yyyy').format(date);
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (_loading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (_chats.isEmpty) {
      body = const Center(child: Text('No chats found'));
    } else {
      body = ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _chats.length,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemBuilder: (context, index) {
          final chat = _chats[index];
          final dynamic latest = ChatSocketService.instance
                  .latestMessages[chat.id] ??
              chat.lastMessage;
          return InkWell(
            onTap: () => context.push('/chats/${chat.id}'),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(radius: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          chat.title,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          latest?.content ?? 'No messages yet',
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _formatTimestamp(latest),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 4),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    return Scaffold(
      appBar: const MainAppBar(),
      body: RefreshIndicator(onRefresh: _loadChats, child: body),
    );
  }
}
