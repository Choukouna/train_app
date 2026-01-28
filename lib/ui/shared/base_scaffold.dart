import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../user_profile.dart';

class BaseScaffold extends StatelessWidget {
  final Widget body;
  final String title;

  const BaseScaffold({
    super.key,
    required this.body,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      // backgroundColor: Colors.deepOrangeAccent,
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      body: body,
      floatingActionButton: FloatingActionButton(
        heroTag: 'profile_fab',
        backgroundColor: const Color(0xFFB7E21C), // tennis ball green
        shape: const CircleBorder(),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const UserProfilePage()),
          );
        },
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: const Color(0xFFB7E21C),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Left curve
              Positioned(
                left: 12,
                top: 8,
                bottom: 8,
                child: Container(
                  width: 6,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              // Right curve
              Positioned(
                right: 12,
                top: 8,
                bottom: 8,
                child: Container(
                  width: 6,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              // Profile icon
              const Center(
                child: Icon(Icons.person, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
