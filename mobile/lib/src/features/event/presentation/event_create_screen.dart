import 'package:flutter/material.dart';

class EventCreateScreen extends StatelessWidget {
  const EventCreateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Event')),
      body: const Center(child: Text('Event creation form goes here')),
    );
  }
}
