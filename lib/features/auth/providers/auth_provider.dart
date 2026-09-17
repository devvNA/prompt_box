import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart' as google;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/utils/supabase_provider.dart';
import '../models/auth_state.dart';
import '../utils/auth_error_formatter.dart';

final authNotifierProvider = NotifierProvider<AuthNotifier, AuthViewState>(
  AuthNotifier.new,
);

class AuthNotifier extends Notifier<AuthViewState> {
  SupabaseClient get _supabase => ref.read(supabaseClientProvider);

  @override
  AuthViewState build() {
    final session = _supabase.auth.currentSession;
    if (session != null) {
      return AuthViewState(
        status: AuthStatus.authenticated,
        user: session.user,
      );
    }
    return const AuthViewState(status: AuthStatus.unauthenticated);
  }

  Future<void> signIn(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.user != null) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: response.user,
        );
      }
    } on AuthException catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: AuthErrorFormatter.format(e),
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: AuthErrorFormatter.format(e),
      );
    }
  }

  Future<void> signUp(String name, String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'username': name},
      );
      if (response.user != null) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: response.user,
        );
      }
    } on AuthException catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: AuthErrorFormatter.format(e),
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: AuthErrorFormatter.format(e),
      );
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      await _supabase.auth.signOut();
      state = const AuthViewState(status: AuthStatus.unauthenticated);
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: AuthErrorFormatter.format(
          e,
          fallback: "Couldn't sign out. Please try again.",
        ),
      );
    }
  }

  Future<void> signInWithGoogle() async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    try {
      if (kIsWeb) {
        // Web flow using Supabase OAuth
        await _supabase.auth.signInWithOAuth(
          OAuthProvider.google,
          redirectTo: null,
        );
      } else {
        // Native mobile flow using google_sign_in
        const webClientId =
            '85174026732-qggffl1tvlvi9r7ag29ijiqk46jeppfe.apps.googleusercontent.com';

        final googleSignIn = google.GoogleSignIn.instance;

        // Initialize MUST be called exactly once
        await googleSignIn.initialize(serverClientId: webClientId);

        final googleUser = await googleSignIn.authenticate();

        final googleAuth = googleUser.authentication;
        final idToken = googleAuth.idToken;

        if (idToken == null) {
          state = state.copyWith(
            status: AuthStatus.error,
            errorMessage: 'Google sign-in was interrupted. Please try again.',
          );
          return;
        }

        final response = await _supabase.auth.signInWithIdToken(
          provider: OAuthProvider.google,
          idToken: idToken,
        );

        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: response.user,
        );
      }
    } on google.GoogleSignInException {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Google sign-in was cancelled or could not complete. Please try again.',
      );
    } on AuthException catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: AuthErrorFormatter.format(e),
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: AuthErrorFormatter.format(e),
      );
    }
  }
}
