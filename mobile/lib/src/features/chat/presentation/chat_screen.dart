import 'package:flutter/material.dart';
import '../../../shared/main_app_bar.dart';

class ChatScreen extends StatelessWidget {
  final int chatId;

  const ChatScreen({super.key, required this.chatId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MainAppBar(),
      body: Center(child: Text('Chat $chatId placeholder')),
    );
  }
}
