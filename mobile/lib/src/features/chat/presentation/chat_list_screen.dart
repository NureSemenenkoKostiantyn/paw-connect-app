import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../models/chat_response.dart';
import '../../../services/chat_service.dart';
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
    _loadChats();
  }

  Future<void> _loadChats() async {
    setState(() => _loading = true);
    try {
      final res = await ChatService.instance.getChats();
      _chats
        ..clear()
        ..addAll((res.data as List<dynamic>)
            .map((e) => ChatResponse.fromJson(e as Map<String, dynamic>)));
    } finally {
      if (mounted) setState(() => _loading = false);
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
        itemBuilder: (context, index) {
          final chat = _chats[index];
          return ListTile(
            title: Text('Chat ${chat.id}'),
            onTap: () => context.push('/chats/${chat.id}'),
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
