import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/brutal_button.dart';
import '../../auth/screens/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback? onComplete;

  const OnboardingScreen({super.key, this.onComplete});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late final PageController _pageController;
  int _currentPage = 0;

  static const int _pageCount = 3;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onSkip() {
    if (widget.onComplete != null) {
      widget.onComplete!();
    } else if (_currentPage < _pageCount - 1) {
      _pageController.animateToPage(
        _pageCount - 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _onComplete();
    }
  }

  void _onNext() {
    if (_currentPage < _pageCount - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _onComplete();
    }
  }

  void _onComplete() {
    if (widget.onComplete != null) {
      widget.onComplete!();
    } else {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }

  Widget _buildPage1() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.pagePadding),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            child: Image.asset(
              'assets/images/onboard-1.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(
          'Save, organize, and visualize your\nbest prompts in one place.',
          style: AppTypography.bodyLarge,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildPage2() {
    return Column(
      children: [
        const SizedBox(height: AppSpacing.pagePadding),
        Expanded(
          child: Image.asset(
            'assets/images/onboard-2.png',
            fit: BoxFit.contain,
          ),
        ),
      ],
    );
  }

  Widget _buildPage3() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Image.asset(
            'assets/images/onboard-3.png',
            fit: BoxFit.contain,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = _currentPage == _pageCount - 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.pagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Action Row
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: _onSkip,
                  child: Text('Skip', style: AppTypography.button),
                ),
              ),

              // Page Content
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  children: [_buildPage1(), _buildPage2(), _buildPage3()],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Page Indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_pageCount, (index) {
                  final isActive = _currentPage == index;
                  return GestureDetector(
                    onTap: () {
                      _pageController.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isActive
                            ? AppColors.ink
                            : AppColors.muted.withValues(alpha: 0.3),
                      ),
                    ),
                  );
                }),
              ),

              const SizedBox(height: AppSpacing.xxl),

              // Next / Get Started Button
              BrutalButton(
                text: isLastPage ? 'Get Started' : 'Next  →',
                isFullWidth: true,
                onPressed: _onNext,
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
          ),
        ),
      ),
    );
  }
}
