import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'chat_socket_service.dart';
import 'http_client.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

Future<void> handleExpiredJwt() async {
  await HttpClient.instance.clearCookies();
  ChatSocketService.instance.disconnect();
  final context = rootNavigatorKey.currentContext;
  if (context != null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Session expired. Please sign in again.')),
    );
    GoRouter.of(context).go('/');
  }
}
