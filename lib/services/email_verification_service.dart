import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class EmailVerificationService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Check if email is verified
  bool isEmailVerified() {
    return _auth.currentUser?.emailVerified ?? false;
  }

  // Send verification email
  Future<void> sendVerificationEmail() async {
    try {
      final user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }
    } catch (e) {
      debugPrint('Email verification error: $e');
      rethrow;
    }
  }

  // Reload user to check verification status
  Future<void> reloadUser() async {
    try {
      await _auth.currentUser?.reload();
    } catch (e) {
      debugPrint('User reload error: $e');
      rethrow;
    }
  }
}