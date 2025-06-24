import 'package:flutter/material.dart';
import 'src/app.dart';
import 'src/services/http_client.dart';
import 'src/services/settings_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HttpClient.instance.init();
  await SettingsService.instance.init();
  final hasCookie = await HttpClient.instance.hasAuthCookie();
  runApp(
    AnimatedBuilder(
      animation: SettingsService.instance,
      builder: (context, _) {
        return App(
          initialLocation: hasCookie ? '/home' : '/',
          locale: SettingsService.instance.locale,
        );
      },
    ),
  );
}
