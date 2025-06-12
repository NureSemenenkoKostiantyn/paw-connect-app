import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/auth/presentation/signup_screen.dart';
import 'features/map/presentation/map_screen.dart';
import 'features/home/presentation/home_screen.dart';
import 'features/chat/presentation/chat_list_screen.dart';
import 'features/chat/presentation/chat_screen.dart';
import 'features/profile/profile_completion_screen.dart';
import 'features/profile/presentation/profile_screen.dart';
import 'features/profile/presentation/public_profile_screen.dart';
import 'features/event/presentation/event_screen.dart';
import 'features/dog/presentation/dog_profile_screen.dart';
import 'styles/app_theme.dart';

class App extends StatelessWidget {
  App({super.key, required this.initialLocation});

  final String initialLocation;

  late final GoRouter _router = GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const MyHomePage(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/profile/complete',
        builder: (context, state) => const ProfileCompletionScreen(),
      ),
      GoRoute(
        path: '/dogs/:id',
        name: 'dog-profile',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return DogProfileScreen(dogId: id);
        },
      ),
      GoRoute(
        path: '/public/:username',
        name: 'public-profile',
        builder: (context, state) {
          final username = state.pathParameters['username']!;
          return PublicProfileScreen(username: username);
        },
      ),
      GoRoute(
        path: '/events/:id',
        name: 'event',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return EventScreen(eventId: id);
        },
      ),
      GoRoute(
        path: '/chats/:id',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return ChatScreen(chatId: id);
        },
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: AppTheme.light,
      routerConfig: _router,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = <Widget>[
    const HomeScreen(),
    const MapScreen(),
    const ChatListScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
