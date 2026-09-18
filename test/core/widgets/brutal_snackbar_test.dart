import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prompt_box/core/theme/app_theme.dart';
import 'package:prompt_box/core/widgets/brutal_snackbar.dart';

void main() {
  group('BrutalSnackbarCard widget tests', () {
    testWidgets('renders success type correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: BrutalSnackbarCard(
              message: 'Prompt berhasil disimpan!',
              type: BrutalSnackbarType.success,
            ),
          ),
        ),
      );

      expect(find.text('BERHASIL'), findsOneWidget);
      expect(find.text('Prompt berhasil disimpan!'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_outline_rounded), findsOneWidget);
    });

    testWidgets('renders error type correctly with custom title', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: BrutalSnackbarCard(
              title: 'AUTH FAILED',
              message: 'Email atau password salah',
              type: BrutalSnackbarType.error,
            ),
          ),
        ),
      );

      expect(find.text('AUTH FAILED'), findsOneWidget);
      expect(find.text('Email atau password salah'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
    });

    testWidgets('renders warning type correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: BrutalSnackbarCard(
              message: 'Perubahan belum disimpan',
              type: BrutalSnackbarType.warning,
            ),
          ),
        ),
      );

      expect(find.text('PERHATIAN'), findsOneWidget);
      expect(find.text('Perubahan belum disimpan'), findsOneWidget);
      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
    });

    testWidgets('renders info type correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: BrutalSnackbarCard(
              message: 'Apple sign-in segera hadir',
              type: BrutalSnackbarType.info,
            ),
          ),
        ),
      );

      expect(find.text('INFO'), findsOneWidget);
      expect(find.text('Apple sign-in segera hadir'), findsOneWidget);
      expect(find.byIcon(Icons.info_outline_rounded), findsOneWidget);
    });
  });

  group('BrutalSnackbar overlay tests', () {
    testWidgets('shows from top and closes on button tap', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  BrutalSnackbar.showSuccess(
                    context,
                    'Koneksi berhasil',
                  );
                },
                child: const Text('Show'),
              ),
            ),
          ),
        ),
      );

      // Trigger show
      await tester.tap(find.text('Show'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300)); // finish slide animation

      expect(find.text('Koneksi berhasil'), findsOneWidget);
      expect(find.text('BERHASIL'), findsOneWidget);

      // Tap close button
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250)); // finish dismiss

      expect(find.text('Koneksi berhasil'), findsNothing);
    });

    testWidgets('auto-dismisses after duration completes', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  BrutalSnackbar.show(
                    context,
                    message: 'Auto dismiss test',
                    duration: const Duration(milliseconds: 1000),
                  );
                },
                child: const Text('Show Auto'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Auto'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300)); // enter animation

      expect(find.text('Auto dismiss test'), findsOneWidget);

      // Advance by half duration (500ms): should still be visible
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Auto dismiss test'), findsOneWidget);

      // Advance past remaining duration and wait for settle
      await tester.pump(const Duration(milliseconds: 1000));
      await tester.pumpAndSettle();
      expect(find.text('Auto dismiss test'), findsNothing);
    });
  });
}
