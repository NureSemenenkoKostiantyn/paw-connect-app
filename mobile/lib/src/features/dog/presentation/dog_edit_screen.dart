import 'package:flutter/material.dart';

class DogEditScreen extends StatelessWidget {
  final int dogId;

  const DogEditScreen({super.key, required this.dogId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Dog')),
      body: Center(
        child: Text('Dog edit form for ID \$dogId'),
      ),
    );
  }
}
