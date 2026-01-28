import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:jeusetmatch/utils/auth_wrapper.dart';
import 'package:provider/provider.dart';
import 'db/user_provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  /// 🔥 Initialise Firebase AVANT d’utiliser Firestore/Auth/etc.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => UserProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  /// This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jeu, Set & Match',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.deepOrangeAccent, // ✅ Global background
      ),
      home: const AuthWrapper(),
    );
  }
}
