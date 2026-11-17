import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prompt_box/core/theme/app_spacing.dart';
import 'package:prompt_box/core/widgets/prompt_tag.dart';
import 'package:prompt_box/features/dashboard/widgets/prompt_card.dart';
import 'package:prompt_box/features/explore/providers/explore_provider.dart';
import 'package:prompt_box/features/explore/screens/explore_screen.dart';
import 'package:prompt_box/features/prompt/models/prompt_model.dart';

class _FakeExploreNotifier extends ExplorePromptsNotifier {
  final List<PromptModel> prompts;

  _FakeExploreNotifier(this.prompts);

  @override
  Future<List<PromptModel>> build() async => prompts;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  final samplePrompts = [
    PromptModel(
      id: 'older-popular',
      title: 'Enhance Image Ultra Portrait With Very Long Descriptive Title',
      content:
          'Enhance and restore the reference image to ultra-high definition 8k studio photography lighting with sharp details.',
      category: 'Image Generation',
      tags: const ['enhancement', 'photography', 'portrait', 'studio'],
      likes: 99,
      createdAt: DateTime(2026, 1, 1),
      authorName: 'PopularCreatorWithLongName',
    ),
    PromptModel(
      id: 'newer-less-likes',
      title: 'Create Professional Ecommerce Product Shot In Minimalist Studio',
      content:
          'Create a professional, photorealistic 4K ecommerce product photograph with soft natural shadows and crisp typography.',
      category: 'Marketing & Copy',
      tags: const ['ecommerce', 'product', 'branding'],
      likes: 2,
      createdAt: DateTime(2026, 5, 1),
      authorName: 'RecentCreator',
    ),
  ];

  testWidgets(
    'ExploreScreen defaults to Most Recent and has no overflow on narrow/scaled screens',
    (tester) async {
      final errors = <FlutterErrorDetails>[];
      final oldOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        errors.add(details);
      };
      addTearDown(() => FlutterError.onError = oldOnError);

      final viewports = [
        const Size(320, 640),
        const Size(360, 780),
        const Size(412, 915),
        const Size(768, 1024),
      ];
      final textScales = [1.0, 1.3, 1.5];

      for (final size in viewports) {
        for (final scale in textScales) {
          errors.clear();
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1.0;

          await tester.pumpWidget(
            ProviderScope(
              overrides: [
                explorePromptsNotifierProvider.overrideWith(
                  () => _FakeExploreNotifier(samplePrompts),
                ),
              ],
              child: MaterialApp(
                home: MediaQuery(
                  data: MediaQueryData(
                    size: size,
                    textScaler: TextScaler.linear(scale),
                  ),
                  child: const ExploreScreen(showBottomNav: false),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();

          expect(
            errors,
            isEmpty,
            reason:
                'Unexpected layout error at size=$size, textScale=$scale: ${errors.map((e) => e.exceptionAsString()).join('\n')}',
          );

          // Verify "Most Recent" prompt appears before the older popular prompt
          final recentTop = tester
              .getTopLeft(find.textContaining('Create Professional Ecommerce'))
              .dy;
          final popularTop = tester
              .getTopLeft(find.textContaining('Enhance Image Ultra Portrait'))
              .dy;
          expect(
            recentTop,
            lessThanOrEqualTo(popularTop),
            reason: 'Most Recent prompt should be ordered first by default',
          );
        }
      }

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    },
  );

  testWidgets(
    'PromptCard, PromptCardSkeleton, and PromptCardTagRow fit without overflow',
    (tester) async {
      final errors = <FlutterErrorDetails>[];
      final oldOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        errors.add(details);
      };
      addTearDown(() => FlutterError.onError = oldOnError);

      for (final width in [320.0, 360.0, 412.0]) {
        for (final scale in [1.0, 1.4]) {
          errors.clear();
          tester.view.physicalSize = Size(width, 800);
          tester.view.devicePixelRatio = 1.0;

          await tester.pumpWidget(
            MaterialApp(
              home: MediaQuery(
                data: MediaQueryData(
                  size: Size(width, 800),
                  textScaler: TextScaler.linear(scale),
                ),
                child: Scaffold(
                  body: LayoutBuilder(
                    builder: (context, constraints) {
                      return GridView.builder(
                        padding: const EdgeInsets.all(AppSpacing.pagePadding),
                        gridDelegate: AppSpacing.promptGridDelegate(
                          context,
                          constraints.maxWidth,
                        ),
                        itemCount: 3,
                        itemBuilder: (context, index) {
                          if (index == 2) {
                            return const PromptCardSkeleton(index: 0);
                          }
                          return PromptCard(
                            prompt: samplePrompts[index],
                            onUpdate: () {},
                            onDelete: () {},
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
          );
          await tester.pump();

          expect(
            errors,
            isEmpty,
            reason:
                'Unexpected layout error at width=$width, textScale=$scale: ${errors.map((e) => e.exceptionAsString()).join('\n')}',
          );
          expect(find.byType(PromptCardTagRow), findsNWidgets(2));
        }
      }

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    },
  );
}
