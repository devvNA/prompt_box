import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prompt_box/core/theme/app_theme.dart';
import 'package:prompt_box/features/prompt/models/prompt_model.dart';
import 'package:prompt_box/features/prompt/screens/prompt_detail_screen.dart';

void main() {
  final testPromptWithImage = PromptModel(
    id: 'test-1',
    title: 'Cinematic Coffee Photography',
    content:
        'A cinematic product photography prompt for a premium coffee cup, with dramatic lighting, shallow depth of field, and a warm tone. The scene includes coffee beans, wooden table, and soft sunlight from the side...',
    category: 'Image Generation',
    tags: ['coffee', 'product', 'cinematic', 'photography'],
    resultImageUrl:
        'https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?auto=format&fit=crop&q=80&w=600&h=450',
    isPublic: true,
    authorName: 'Devit Nur Azaqi',
  );

  final testPromptWithoutImage = PromptModel(
    id: 'test-2',
    title: 'Flutter Clean Architecture',
    content:
        'Write a clean architecture layered pattern for a Flutter application using Riverpod StateNotifier, repository pattern, and immutable models.',
    category: 'Code Assistant',
    tags: ['flutter', 'code'],
    resultImageUrl: null, // No image
    isPublic: false,
    authorName: 'Devit Nur Azaqi',
  );

  Widget buildDetailWidget(PromptModel prompt) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: PromptDetailScreen(prompt: prompt),
    );
  }

  testWidgets('PromptDetailScreen with image renders hero image, badge, meta, content and actions',
      (tester) async {
    await tester.pumpWidget(buildDetailWidget(testPromptWithImage));
    await tester.pump();

    // Verify Title and Category Badge
    expect(find.text('Cinematic Coffee Photography'), findsOneWidget);
    expect(find.text('IMAGE GENERATION'), findsOneWidget);

    // Verify Meta Info
    expect(find.text('Public'), findsOneWidget);
    expect(find.text('by Devit Nur Azaqi'), findsOneWidget);

    // Verify Tags
    expect(find.text('#coffee'), findsOneWidget);
    expect(find.text('#product'), findsOneWidget);

    // Verify Action Buttons
    expect(find.text('Copy'), findsOneWidget);
    expect(find.text('Edit'), findsOneWidget);
    expect(find.text('Delete'), findsOneWidget);
  });

  testWidgets(
      'PromptDetailScreen without image DOES NOT render image container and shifts content up',
      (tester) async {
    await tester.pumpWidget(buildDetailWidget(testPromptWithoutImage));
    await tester.pump();

    // Should show the top nav header title
    expect(find.text('Prompt Detail'), findsOneWidget);

    // Should show title & private meta
    expect(find.text('Flutter Clean Architecture'), findsOneWidget);
    expect(find.text('Private'), findsOneWidget);
    expect(find.text('CODE ASSISTANT'), findsOneWidget);

    // Should render tags and actions
    expect(find.text('#flutter'), findsOneWidget);
    expect(find.text('Copy'), findsOneWidget);
  });

  testWidgets('Copy button triggers snackbar', (tester) async {
    await tester.pumpWidget(buildDetailWidget(testPromptWithoutImage));
    await tester.pump();

    await tester.tap(find.text('Copy'));
    await tester.pump();

    expect(find.text('Prompt copied to clipboard!'), findsOneWidget);
  });

  testWidgets('Delete button opens confirmation dialog and can be cancelled',
      (tester) async {
    await tester.pumpWidget(buildDetailWidget(testPromptWithoutImage));
    await tester.pump();

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(find.text('DELETE PROMPT?'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);

    // Tap Cancel
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('DELETE PROMPT?'), findsNothing);
  });
}
