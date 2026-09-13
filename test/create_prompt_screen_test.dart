import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prompt_box/core/theme/app_theme.dart';
import 'package:prompt_box/features/prompt/models/prompt_model.dart';
import 'package:prompt_box/features/prompt/screens/create_prompt_screen.dart';

void main() {
  Widget buildTestWidget({PromptModel? initialPrompt}) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: CreatePromptScreen(
        initialPrompt: initialPrompt ??
            const PromptModel(
              id: '1',
              title: 'Cinematic Coffee Photography',
              content: 'A cinematic product photography prompt...',
              category: 'Image Generation',
              tags: ['coffee', 'cinematic', 'product'],
              resultImageUrl: null,
            ),
      ),
    );
  }

  testWidgets('CreatePromptScreen renders all required form sections', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pump();

    // Verify Header
    expect(find.text('Create New Prompt'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back), findsOneWidget);

    // Verify Title & Content labels
    expect(find.text('TITLE'), findsOneWidget);
    expect(find.text('CONTENT'), findsOneWidget);
    expect(find.text('CATEGORY'), findsOneWidget);
    expect(find.text('TAGS'), findsOneWidget);
    expect(find.text('RESULT IMAGE'), findsOneWidget);
    expect(find.text('VISIBILITY'), findsOneWidget);

    // Verify Save button
    expect(find.text('Save Prompt'), findsOneWidget);

    // Verify Visibility choices
    expect(find.text('Private'), findsOneWidget);
    expect(find.text('Public'), findsOneWidget);

    // Verify initial tags
    expect(find.text('coffee'), findsOneWidget);
    expect(find.text('cinematic'), findsOneWidget);
    expect(find.text('product'), findsOneWidget);
  });

  testWidgets('User can add and remove tags dynamically', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pump();

    // Remove 'coffee' tag
    final removeCoffeeFinder = find.descendant(
      of: find.widgetWithText(Container, 'coffee'),
      matching: find.text('✕'),
    );
    expect(removeCoffeeFinder, findsOneWidget);
    await tester.tap(removeCoffeeFinder);
    await tester.pump();

    expect(find.text('coffee'), findsNothing);

    // Add new tag 'minimalist'
    final addTagInput = find.widgetWithText(TextField, 'Add a tag...');
    expect(addTagInput, findsOneWidget);
    await tester.enterText(addTagInput, 'minimalist');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    expect(find.text('minimalist'), findsOneWidget);
  });

  testWidgets('User can switch visibility between Public and Private', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pump();

    // Scroll to make Visibility section visible
    await tester.ensureVisible(find.text('Private'));
    await tester.pump(const Duration(milliseconds: 100));

    // Tap Private
    await tester.tap(find.text('Private'));
    await tester.pump(const Duration(milliseconds: 200));

    // Tap Public
    await tester.tap(find.text('Public'));
    await tester.pump(const Duration(milliseconds: 200));
  });
}
