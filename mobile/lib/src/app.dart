import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/auth/presentation/signup_screen.dart';
import 'features/map/presentation/map_screen.dart';
import 'features/profile/profile_completion_screen.dart';
import 'features/profile/presentation/profile_screen.dart';
import 'features/dog/presentation/dog_profile_screen.dart';
import 'styles/app_theme.dart';

class App extends StatelessWidget {
  App({super.key});

  final GoRouter _router = GoRouter(
    initialLocation: '/',
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
        builder: (context, state) => const MyHomePage(title: 'Home'),
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
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'PawConnect',
      theme: AppTheme.light,
      routerConfig: _router,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = <Widget>[
    const Center(child: Text('Home')),
    const MapScreen(),
    const Center(child: Text('Chat')),
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
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
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
