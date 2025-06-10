import 'package:flutter/material.dart';
import '../../../shared/main_app_bar.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: MainAppBar(),
      body: Center(child: Text('Chat page placeholder')),
    );
  }
}
