import 'package:flutter/material.dart';

class EventScreen extends StatelessWidget {
  final int eventId;

  const EventScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Event')),
      body: Center(
        child: Text('Event ID: $eventId'),
      ),
    );
  }
}
