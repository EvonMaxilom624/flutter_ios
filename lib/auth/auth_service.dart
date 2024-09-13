import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  User? get currentUser => _auth.currentUser;

  // Send email verification link
  Future<void> sendEmailVerificationLink() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
    } catch (e) {
      log("[Auth] Error sending email verification link: ${e.toString()}");
    }
  }

  // Send password reset link
  Future<void> sendPasswordresetLink(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      log("[Auth] Error sending password reset link: ${e.toString()}");
    }
  }

  // Create user with email and password
  Future<User?> createUserWithEmailAndPassword(String email, String password) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      return cred.user;
    } on FirebaseAuthException catch (e) {
      _handleError(e);
    } catch (e) {
      log("[Auth] Something went wrong on createUserWithEmailAndPassword: ${e.toString()}");
    }
    return null;
  }

  // Login user with email and password
  Future<String?> loginUserWithEmailAndPassword(String email, String password) async {
    try {
      final UserCredential cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      log("[Auth] User signed in: ${cred.user?.uid}"); // Use the 'cred' variable to log the user ID
      return null; // No error, login successful
    } on FirebaseAuthException catch (e) {
      return _handleError(e); // Return user-friendly error message
    } catch (e) {
      log("[Auth] Something went wrong on loginUserWithEmailAndPassword: ${e.toString()}");
      return "An unexpected error occurred. Please try again.";
    }
  }

  // Sign out user
  Future<void> signout(BuildContext context) async {
    try {
      await _auth.signOut();
    } catch (e) {
      log("[Auth] Something went wrong on signout: ${e.toString()}");
    }
  }

  // Handle Firebase exceptions
  String? _handleError(FirebaseAuthException e) {
    final errorMessage = _getFriendlyErrorMessage(e.code);
    log("[Auth] FirebaseAuthException: ${e.code} - $errorMessage"); // Log to console
    return errorMessage; // Return to show in the app
  }

  // Return user-friendly error messages
  String _getFriendlyErrorMessage(String code) {
    switch (code) {
      case "invalid-email":
        return "The email address is not valid.";
      case "user-disabled":
        return "This user has been disabled.";
      case "user-not-found":
        return "No user found with this email.";
      case "wrong-password":
        return "Incorrect password. Please try again.";
       case "invalid-credential":
         return "Password or Email is incorrect!";
      case "weak-password":
        return "Your password must be at least 8 characters!"; //TODO add stop function since it allows creation even password is insufficientWhen the process proceeds, it overwrites the old credentials.
      case "email-already-in-use":
        return "User already exists!"; //TODO add stop function since it allows creation even the email is in use. When the process proceeds, it overwrites the old credentials.
      default:
        return "An unknown error occurred. Please try again.";
    }
  }
}
