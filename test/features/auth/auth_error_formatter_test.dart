import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:prompt_box/features/auth/utils/auth_error_formatter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  group('AuthErrorFormatter', () {
    test('formats invalid login credentials', () {
      const exception = AuthException(
        'Invalid login credentials',
        statusCode: '400',
      );
      final result = AuthErrorFormatter.format(exception);
      expect(
        result,
        'Incorrect email or password. Check your details and try again.',
      );
    });

    test('formats user already registered', () {
      const exception = AuthException(
        'User already registered',
        statusCode: '422',
      );
      final result = AuthErrorFormatter.format(exception);
      expect(
        result,
        'This email is already registered. Sign in instead, or use another email.',
      );
    });

    test('formats weak/short password', () {
      const exception = AuthException(
        'Password should be at least 6 characters',
      );
      final result = AuthErrorFormatter.format(exception);
      expect(result, 'Password is too short. Use at least 6 characters.');
    });

    test('formats unconfirmed email', () {
      const exception = AuthException('Email not confirmed');
      final result = AuthErrorFormatter.format(exception);
      expect(
        result,
        'Email not verified yet. Check your inbox for the confirmation link.',
      );
    });

    test('formats rate limit', () {
      const exception = AuthException('Too many requests', statusCode: '429');
      final result = AuthErrorFormatter.format(exception);
      expect(
        result,
        'Too many attempts. Please wait a minute before trying again.',
      );
    });

    test('formats network / socket exception', () {
      const exception = SocketException('Failed host lookup');
      final result = AuthErrorFormatter.format(exception);
      expect(
        result,
        'Unable to connect. Check your internet connection and try again.',
      );
    });

    test('formats unexpected exception with fallback', () {
      final exception = Exception('Unknown internal error');
      final result = AuthErrorFormatter.format(
        exception,
        fallback: "Couldn't sign out. Please try again.",
      );
      expect(result, "Couldn't sign out. Please try again.");
    });
  });
}
