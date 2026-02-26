import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class Auth {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? get currentUser => _auth.currentUser;
  Stream<User?> authStateChanges() => _auth.authStateChanges();

  Future<User?> login(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      debugPrint('Login error (${e.code}): ${e.message}');
      return null;
    } catch (e) {
      debugPrint('Login error: $e');
      return null;
    }
  }

  Future<User?> signup(String email, String password) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      debugPrint('Signup error (${e.code}): ${e.message}');
      return null;
    } catch (e) {
      debugPrint('Signup error: $e');
      return null;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<String?> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null;
    } on FirebaseAuthException catch (e) {
      debugPrint('Password reset error (${e.code}): ${e.message}');
      return e.message ?? 'Failed to send reset email.';
    } catch (e) {
      debugPrint('Password reset error: $e');
      return 'Failed to send reset email.';
    }
  }

  Future<void> changeEmail(String newEmail) async {
    // try { // TODO: API outdated, update again later
    //   await currentUser?.updateEmail(newEmail);
    // } catch (e) {
    //   print('Change email error: $e');
    // }
  }

  Future<bool> reauthenticate(String password) async {
    final user = currentUser;
    final email = user?.email;
    if (user == null || email == null || password.isEmpty) {
      return false;
    }

    try {
      AuthCredential credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);
      return true;
    } on FirebaseAuthException catch (e) {
      debugPrint('Reauthentication error (${e.code}): ${e.message}');
      return false;
    } catch (e) {
      debugPrint('Reauthentication error: $e');
      return false;
    }
  }

  Future<String?> changePassword(String newPassword) async {
    try {
      final user = currentUser;
      if (user == null) return 'No signed-in user.';
      await user.updatePassword(newPassword);
      return null;
    } on FirebaseAuthException catch (e) {
      debugPrint('Change password error (${e.code}): ${e.message}');
      return e.message ?? 'Failed to update password.';
    } catch (e) {
      debugPrint('Change password error: $e');
      return 'Failed to update password.';
    }
  }
}
