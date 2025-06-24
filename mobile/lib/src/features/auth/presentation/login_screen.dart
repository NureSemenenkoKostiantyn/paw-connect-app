import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import '../services/auth_service.dart';
import '../../../services/user_service.dart';
import '../../../services/preference_service.dart';
import '../../../services/completion_utils.dart';
import '../../../models/current_user_response.dart';
import '../../../models/preference_response.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _loading = false;

  Future<void> _signIn() async {
    setState(() => _loading = true);
    try {
      await AuthService.instance.signIn(
        _usernameController.text,
        _passwordController.text,
      );

      if (!mounted) return;

      final userRes = await UserService.instance.getCurrentUser();
      if (!mounted) return;

      final prefRes = await PreferenceService.instance.getCurrent();
      if (!mounted) return;

      final user = CurrentUserResponse.fromJson(userRes.data);
      final pref = PreferenceResponse.fromJson(prefRes.data);

      if (!mounted) return;

      if (isProfileComplete(user) && isPreferencesComplete(pref)) {
        context.go('/home');
      } else {
        context.go('/profile/complete');
      }
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? e.message;
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${context.l10n.translate('loginFailed')}: $message')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${context.l10n.translate('loginFailed')}: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.translate('appTitle'))),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              context.l10n.translate('welcomeBack'),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: context.l10n.translate('username')),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: context.l10n.translate('password'),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
              obscureText: _obscurePassword,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loading ? null : _signIn,
              child: _loading
                  ? const CircularProgressIndicator()
                  : Text(context.l10n.translate('signIn')),
            ),
            TextButton(
              onPressed: () => context.push('/signup'),
              child: Text("${context.l10n.translate('createAccount')}? ${context.l10n.translate('register')}"),
            ),
          ],
        ),
      ),
    );
  }
}
