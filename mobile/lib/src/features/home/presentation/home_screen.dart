import 'package:flutter/material.dart';
import '../../../shared/main_app_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: MainAppBar(),
      body: Center(child: Text('Home page placeholder')),
    );
  }
}
