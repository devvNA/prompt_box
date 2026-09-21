import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prompt_box/core/theme/app_theme.dart';
import 'package:prompt_box/features/dashboard/widgets/prompt_card.dart';
import 'package:prompt_box/features/prompt/models/prompt_model.dart';

void main() {
  Widget buildTestCard(PromptModel prompt) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(
        body: SizedBox(
          width: 180,
          height: 310,
          child: PromptCard(prompt: prompt, onUpdate: () {}, onDelete: () {}),
        ),
      ),
    );
  }

  testWidgets('PromptCard renders prompt snippet and quote icon', (
    tester,
  ) async {
    const testPrompt = PromptModel(
      id: 'test-1',
      title: 'Cinematic Portrait',
      content:
          'A close up photo of an astronaut in space with reflection on helmet',
      category: 'Image Generation',
      tags: ['space', 'portrait'],
    );

    await tester.pumpWidget(buildTestCard(testPrompt));
    await tester.pump();

    // Verify Title
    expect(find.text('Cinematic Portrait'), findsOneWidget);

    // Verify Quote icon for snippet
    expect(find.byIcon(Icons.format_quote_rounded), findsOneWidget);

    // Verify Snippet text
    expect(
      find.text(
        'A close up photo of an astronaut in space with reflection on helmet',
      ),
      findsOneWidget,
    );

    // Verify Tags
    expect(find.text('#space'), findsOneWidget);
    expect(find.text('#portrait'), findsOneWidget);
  });
}
