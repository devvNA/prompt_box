import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prompt_box/features/auth/models/auth_state.dart';
import 'package:prompt_box/features/auth/providers/auth_provider.dart';
import 'package:prompt_box/features/auth/screens/login_screen.dart';

class FakeAuthNotifier extends AuthNotifier {
  @override
  AuthViewState build() {
    return const AuthViewState(status: AuthStatus.unauthenticated);
  }
}

void main() {
  Widget createWidgetUnderTest({AuthMode initialMode = AuthMode.signIn}) {
    return ProviderScope(
      overrides: [
        authNotifierProvider.overrideWith(FakeAuthNotifier.new),
      ],
      child: MaterialApp(
        home: LoginScreen(
          initialMode: initialMode,
          onSignIn: (_, _) {},
          onSignUp: (_, _, _) {},
        ),
      ),
    );
  }

  group('LoginScreen Form Validation UX Copy', () {
    testWidgets('shows concise, blame-free error for empty email and password on submit',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Submit form with empty fields
      final submitButton = find.text('Sign In').last;
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      // Check inline validation messages
      expect(find.text('Enter your email address'), findsOneWidget);
      expect(find.text('Enter your password'), findsOneWidget);
      expect(find.text('Please enter your email'), findsNothing);
      expect(find.text('Please enter your password'), findsNothing);
    });

    testWidgets('shows helpful guidance for invalid email format', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final emailField = find.byType(TextFormField).first;
      await tester.enterText(emailField, 'invalid-email');

      final submitButton = find.text('Sign In').last;
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      expect(
        find.text('Enter a valid email address (e.g. name@domain.com)'),
        findsOneWidget,
      );
    });

    testWidgets('shows concise error for name field on Sign Up', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(initialMode: AuthMode.signUp));
      await tester.pumpAndSettle();

      final submitButton = find.text('Sign Up').last;
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      expect(find.text('Enter your name'), findsOneWidget);
      expect(find.text('Please enter your name'), findsNothing);
    });
  });
}
