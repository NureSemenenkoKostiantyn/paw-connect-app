import 'package:flutter/material.dart';

class PublicProfileScreen extends StatelessWidget {
  final String username;

  const PublicProfileScreen({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Public Profile')),
      body: Center(
        child: Text('Username: $username'),
      ),
    );
  }
}
