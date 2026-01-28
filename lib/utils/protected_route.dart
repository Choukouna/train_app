import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../ui/shared/base_scaffold.dart';
import '../ui/sign_in.dart';

class ProtectedRoute extends StatelessWidget {
  final String title;
  final Widget body;

  const ProtectedRoute({
    super.key,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    if (FirebaseAuth.instance.currentUser == null) {
      return const SignIn();
    }

    return BaseScaffold(
      title: title,
      body: body,
    );
  }
}
