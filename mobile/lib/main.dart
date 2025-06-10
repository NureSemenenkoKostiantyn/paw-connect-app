import 'package:flutter/material.dart';
import 'src/app.dart';
import 'src/services/http_client.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HttpClient.instance.init();
  final hasCookie = await HttpClient.instance.hasAuthCookie();
  runApp(App(initialLocation: hasCookie ? '/home' : '/'));
}
