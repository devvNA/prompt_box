import 'package:supabase_flutter/supabase_flutter.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthViewState {
  final AuthStatus status;
  final User? user;
  final String? errorMessage;

  const AuthViewState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
  });

  AuthViewState copyWith({
    AuthStatus? status,
    User? user,
    String? errorMessage,
  }) {
    return AuthViewState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
