import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

/// Utility to format authentication errors into user-friendly, blame-free UX copy.
/// Follows the 3-part UX writing pattern: [What happened]. [Why/context]. [What to do].
class AuthErrorFormatter {
  const AuthErrorFormatter._();

  /// Converts any exception into a clean, actionable message for users.
  static String format(Object error, {String? fallback}) {
    if (error is AuthException) {
      return _formatAuthException(error);
    }

    if (error is SocketException) {
      return "Unable to connect. Check your internet connection and try again.";
    }

    final message = error.toString().toLowerCase();
    if (message.contains('socket') ||
        message.contains('network') ||
        message.contains('connection') ||
        message.contains('failed host lookup')) {
      return "Unable to connect. Check your internet connection and try again.";
    }

    if (message.contains('timeout')) {
      return "Request timed out. Please try again in a moment.";
    }

    return fallback ??
        "Something went wrong on our end. Please try again in a moment.";
  }

  static String _formatAuthException(AuthException exception) {
    final message = exception.message.toLowerCase();
    final statusCode = exception.statusCode?.toLowerCase() ?? '';

    // Wrong email / password combination
    if (message.contains('invalid login credentials') ||
        message.contains('invalid credentials') ||
        statusCode == '400' && message.contains('credentials')) {
      return "Incorrect email or password. Check your details and try again.";
    }

    // Email already registered
    if (message.contains('user already registered') ||
        message.contains('email already exists') ||
        message.contains('already been registered')) {
      return "This email is already registered. Sign in instead, or use another email.";
    }

    // Weak / short password
    if (message.contains('password should be at least') ||
        message.contains('weak password')) {
      return "Password is too short. Use at least 6 characters.";
    }

    // Unconfirmed email
    if (message.contains('email not confirmed')) {
      return "Email not verified yet. Check your inbox for the confirmation link.";
    }

    // Rate limited
    if (message.contains('rate limit') ||
        message.contains('too many requests') ||
        statusCode == '429') {
      return "Too many attempts. Please wait a minute before trying again.";
    }

    // Invalid email syntax rejected by server
    if (message.contains('invalid email') || message.contains('valid email')) {
      return "Enter a valid email address (e.g., name@example.com).";
    }

    // User not found
    if (message.contains('user not found')) {
      return "No account found with this email. Check your email or sign up.";
    }

    // Fallback for other auth exceptions
    return "Couldn't complete authentication. Please try again.";
  }
}
