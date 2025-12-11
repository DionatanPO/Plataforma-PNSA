import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

abstract class AuthService {
  Future<bool> login(String email, String password);
  Future<void> logout();
  bool get isAuthenticated;
  User? get currentUser;
}

class AuthServiceImpl extends AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  bool get isAuthenticated {
    final user = _firebaseAuth.currentUser;
    return user != null;
  }

  @override
  User? get currentUser => _firebaseAuth.currentUser;

  @override
  Future<bool> login(String email, String password) async {
    try {
      final result = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Check if the user is not null after login
      return result.user != null;
    } on FirebaseAuthException catch (e) {
      // Handle specific Firebase Auth errors
      switch (e.code) {
        case 'user-not-found':
          print('No user found for that email.');
          break;
        case 'wrong-password':
          print('Wrong password provided for that user.');
          break;
        case 'invalid-email':
          print('Invalid email format.');
          break;
        default:
          print('Error: ${e.message}');
      }
      return Future.value(false);
    } catch (e) {
      print('Unexpected error: $e');
      return Future.value(false);
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      print('Error logging out: $e');
    }
  }
}