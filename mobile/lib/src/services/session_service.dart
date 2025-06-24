import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'chat_socket_service.dart';
import 'http_client.dart';
import '../localization/app_localizations.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

Future<void> handleExpiredJwt() async {
  await HttpClient.instance.clearCookies();
  ChatSocketService.instance.disconnect();
  final context = rootNavigatorKey.currentContext;
  if (context != null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context).translate('sessionExpired'))),
    );
    GoRouter.of(context).go('/');
  }
}
