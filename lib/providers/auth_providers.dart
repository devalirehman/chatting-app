import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _db = FirebaseDatabase.instance.ref('users');

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  User? get user => _auth.currentUser;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // ===============================
  // SIGN UP
  Future<String?> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    if (name.trim().isEmpty || email.trim().isEmpty || password.trim().isEmpty) {
      return "Name, email, or password cannot be empty.";
    }

    try {
      _setLoading(true);

      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      if (result.user != null) {
        await _db.child(result.user!.uid).set({
          "uid": result.user!.uid,
          "name": name.trim(),
          "email": email.trim(),
          "createdAt": DateTime.now().toIso8601String(),
        });
        print("User saved in DB: ${result.user!.uid}");
      }

      _setLoading(false);
      notifyListeners();
      return null; // SUCCESS
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      return _firebaseError(e);
    } catch (e) {
      _setLoading(false);
      return "Something went wrong: $e";
    }
  }

  // ===============================
  // LOGIN
  Future<String?> login({
    required String email,
    required String password,
  }) async {
    if (email.trim().isEmpty || password.trim().isEmpty) {
      return "Email or password cannot be empty.";
    }

    try {
      _setLoading(true);

      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      _setLoading(false);
      notifyListeners();
      return null; // SUCCESS
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      return _firebaseError(e);
    } catch (_) {
      _setLoading(false);
      return "Login failed. Please try again.";
    }
  }

  // ===============================
  // LOGOUT
  Future<void> logout() async {
    await _auth.signOut();
    notifyListeners();
  }

  // ===============================
  // RESET PASSWORD
  Future<void> resetPassword(String email) async {
    try {
      _setLoading(true);
      await _auth.sendPasswordResetEmail(email: email.trim());
      _setLoading(false);
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      notifyListeners();
      throw _firebaseError(e);
    }
  }

  // ===============================
  // GOOGLE SIGN-IN
  Future<String?> loginWithGoogle() async {
    try {
      _setLoading(true);

      // Use the singleton instance
      final googleSignIn = GoogleSignIn.instance;

      // (Optional) initialize clientId if needed:
      // await googleSignIn.initialize(clientId: '<YOUR_WEB_CLIENT_ID>');

      // Authenticate
      final user = await googleSignIn.authenticate();

      if (user == null) {
        _setLoading(false);
        return "Google sign-in cancelled";
      }

      // Tokens
      final googleAuth = user.authentication;

      if (googleAuth.idToken == null && googleAuth.accessToken == "") {
        _setLoading(false);
        return "Failed to get token";
      }

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      final currentUser = userCredential.user;
      if (currentUser != null) {
        await _db.child(currentUser.uid).set({
          "uid": currentUser.uid,
          "name": currentUser.displayName ?? "",
          "email": currentUser.email ?? "",
          "photoURL": currentUser.photoURL ?? "",
          "loginMethod": "google",
          "createdAt": DateTime.now().toIso8601String(),
        });
      }

      _setLoading(false);
      notifyListeners();
      return null;
    } catch (e) {
      _setLoading(false);
      notifyListeners();
      return "Google Sign-In failed: $e";
    }
  }

  // ===============================
  // ERROR MAPPER
  String _firebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return "Invalid email address.";
      case 'user-not-found':
        return "User not found.";
      case 'wrong-password':
        return "Wrong password.";
      case 'email-already-in-use':
        return "Email already registered.";
      case 'weak-password':
        return "Password is too weak.";
      default:
        return "Authentication failed. Please try again.";
    }
  }
}

extension on GoogleSignInAuthentication {
  get accessToken => null;
}


