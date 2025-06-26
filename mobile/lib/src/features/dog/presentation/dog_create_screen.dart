import 'package:flutter/material.dart';

class DogCreateScreen extends StatelessWidget {
  const DogCreateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Dog')),
      body: const Center(
        child: Text('Dog create form goes here'),
      ),
    );
  }
}
