import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prompt_box/core/widgets/brutal_checkbox.dart';
import 'package:prompt_box/features/auth/models/auth_state.dart';
import 'package:prompt_box/features/auth/providers/auth_provider.dart';
import 'package:prompt_box/features/auth/screens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  group('LoginScreen Remember Me', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('shows Remember me checkbox on Sign In tab', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Remember me'), findsOneWidget);
      expect(find.byType(BrutalCheckbox), findsOneWidget);
    });

    testWidgets('hides Remember me checkbox on Sign Up tab', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(initialMode: AuthMode.signUp));
      await tester.pumpAndSettle();

      expect(find.text('Remember me'), findsNothing);
      expect(find.byType(BrutalCheckbox), findsNothing);
    });

    testWidgets('toggles Remember me checkbox on tap', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final checkboxFinder = find.byType(BrutalCheckbox);
      final checkboxBefore = tester.widget<BrutalCheckbox>(checkboxFinder);
      expect(checkboxBefore.value, isFalse);

      await tester.tap(checkboxFinder);
      await tester.pumpAndSettle();

      final checkboxAfter = tester.widget<BrutalCheckbox>(checkboxFinder);
      expect(checkboxAfter.value, isTrue);
    });

    testWidgets('persists email when Remember me is checked on submit', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Check remember me
      await tester.tap(find.byType(BrutalCheckbox));
      await tester.pumpAndSettle();

      // Fill in valid email & password
      final emailField = find.byType(TextFormField).first;
      final passwordField = find.byType(TextFormField).last;
      await tester.enterText(emailField, 'user@example.com');
      await tester.enterText(passwordField, 'password123');

      // Submit
      final submitButton = find.text('Sign In').last;
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('remember_me'), isTrue);
      expect(prefs.getString('saved_email'), equals('user@example.com'));
    });

    testWidgets('pre-fills email when Remember me was previously saved', (tester) async {
      SharedPreferences.setMockInitialValues({
        'remember_me': true,
        'saved_email': 'saved@example.com',
      });

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('saved@example.com'), findsOneWidget);
      final checkbox = tester.widget<BrutalCheckbox>(find.byType(BrutalCheckbox));
      expect(checkbox.value, isTrue);
    });
  });
}

