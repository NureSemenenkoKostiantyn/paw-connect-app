import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../services/http_client.dart';

class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  const MainAppBar({super.key, required this.title});

  Future<void> _logout(BuildContext context) async {
    await HttpClient.instance.clearCookies();
    if (context.mounted) context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      titleSpacing: 0,
      title: Row(
        children: [
          SvgPicture.asset('assets/logo.svg', height: 32),
          const SizedBox(width: 8),
          Text(title),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () => _logout(context),
          icon: const Icon(Icons.logout),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
