import 'package:flutter/material.dart';
import 'src/app.dart';
import 'src/services/http_client.dart';

void main() async {
  final hasCookie = await HttpClient.instance.hasAuthCookie();
  runApp(App(initialLocation: hasCookie ? '/home' : '/'));
}
