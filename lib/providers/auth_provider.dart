import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import '../services/auth_service.dart';

/// Provider class to manage authentication state across the app
class AuthProvider with ChangeNotifier {
  AuthService? _authService;
  User? _user;
  bool _isLoading = true;
  bool _firebaseAvailable = false;

  AuthProvider() {
    _init();
  }

  /// Initialize auth state listener
  void _init() async {
    try {
      // Check if Firebase is initialized
      await Firebase.app();
      _firebaseAvailable = true;
      _authService = AuthService();
      _authService!.authStateChanges.listen((User? user) {
        _user = user;
        _isLoading = false;
        notifyListeners();
      });
    } catch (e) {
      // Firebase not available - skip authentication
      debugPrint('Firebase not available, skipping authentication');
      _firebaseAvailable = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Current authenticated user
  User? get user => _user;

  /// Check if user is authenticated
  bool get isAuthenticated => _user != null;

  /// Check if auth state is still loading
  bool get isLoading => _isLoading;

  /// User display name
  String get displayName => _user?.displayName ?? 'User';

  /// User email
  String get email => _user?.email ?? '';

  /// User ID for Firestore operations
  String get userId => _user?.uid ?? '';

  /// Sign up with email and password
  Future<void> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    if (!_firebaseAvailable || _authService == null) {
      throw 'Authentication not available on this platform';
    }
    try {
      await _authService!.signUpWithEmailPassword(
        email: email,
        password: password,
        displayName: displayName,
      );
      // User will be updated via auth state listener
    } catch (e) {
      rethrow;
    }
  }

  /// Sign in with email and password
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    if (!_firebaseAvailable || _authService == null) {
      throw 'Authentication not available on this platform';
    }
    try {
      await _authService!.signInWithEmailPassword(
        email: email,
        password: password,
      );
      // User will be updated via auth state listener
    } catch (e) {
      rethrow;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    if (!_firebaseAvailable || _authService == null) {
      return;
    }
    try {
      await _authService!.signOut();
      // User will be cleared via auth state listener
    } catch (e) {
      rethrow;
    }
  }

  /// Send password reset email
  Future<void> resetPassword({required String email}) async {
    if (!_firebaseAvailable || _authService == null) {
      throw 'Authentication not available on this platform';
    }
    try {
      await _authService!.sendPasswordResetEmail(email: email);
    } catch (e) {
      rethrow;
    }
  }

  /// Delete user account
  Future<void> deleteAccount() async {
    if (!_firebaseAvailable || _authService == null) {
      throw 'Authentication not available on this platform';
    }
    try {
      await _authService!.deleteAccount();
      // User will be cleared via auth state listener
    } catch (e) {
      rethrow;
    }
  }
}
