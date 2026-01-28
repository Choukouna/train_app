import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jeusetmatch/ui/features_page.dart';
import 'package:jeusetmatch/ui/home_page.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          return const AuthenticatedApp();
        }

        return const UnauthenticatedApp();
      },
    );
  }
}

class AuthenticatedApp extends StatelessWidget {
  const AuthenticatedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          builder: (_) => const FeaturesPage(),
        );
      },
    );
  }
}

class UnauthenticatedApp extends StatelessWidget {
  const UnauthenticatedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          builder: (_) => const HomePage(),
        );
      },
    );
  }
}

