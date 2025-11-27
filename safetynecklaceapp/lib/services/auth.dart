import 'package:firebase_auth/firebase_auth.dart';

class Auth {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? get currentUser => _auth.currentUser;

  Future<User?> login(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      print('Login error: $e');
      return null;
    }
  }

  Future<User?> signup(String email, String password) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      return userCredential.user;
    } catch (e) {
      print('Signup error: $e');
      return null;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print('Password reset error: $e');
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
    try {
      AuthCredential credential = EmailAuthProvider.credential(
        email: currentUser!.email!,
        password: password,
      );
      await currentUser?.reauthenticateWithCredential(credential);
      return true;
    } catch (e) {
      print('Reauthentication error: $e');
      return false;
    }
  }

  Future<String?> changePassword(String newPassword) async {
    try {
      await currentUser?.updatePassword(newPassword);
      return null;
    } catch (e) {
      print('Change password error: $e');
      return e.toString();
    }
  }
}
