import 'package:firebase_auth/firebase_auth.dart';

/// A secondary service class dedicated to handling Firebase Authentication.
/// Note: Most of these functionalities are also centralized in [FirebaseService].
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Provides a stream that emits changes in the user's sign-in status.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Attempts to log in a user with an email and password.
  Future<UserCredential> signInWithEmail(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  /// Signs the current user out of the application.
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Retrieves the currently authenticated user, or null if none exists.
  User? getCurrentUser() {
    return _auth.currentUser;
  }
}
