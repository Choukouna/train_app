import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProvider with ChangeNotifier {
  Map<String, dynamic>? _userData;
  bool _loading = false;

  Map<String, dynamic>? get userData => _userData;
  bool get loading => _loading;

  Future<void> fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('players')
        .doc(user.uid)
        .get();

    _userData = {
      'uid': doc.id,          // the document ID (user UID)
      ...?doc.data(),          // spread operator merges the fields
    };
  }

  Future<void> refreshUserInfos() async {
    _loading = true;
    await fetchUserData();
    _loading = false;
    notifyListeners();
  }

  void clear() {
    _userData = null;
    notifyListeners();
  }
}
