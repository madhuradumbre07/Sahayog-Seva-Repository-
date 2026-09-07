import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/onboarding_illustrations.dart';
import '../../widgets/primary_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  static const String routeName = '/onboarding';

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _index = 0;

  static const _slideCount = 3;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToLogin() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  Future<void> _onNext() async {
    if (_index >= _slideCount - 1) {
      _goToLogin();
      return;
    }
    await _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final slides = [
      (
        title: context.tr('onboardTitle1'),
        body: context.tr('onboardBody1'),
      ),
      (
        title: context.tr('onboardTitle2'),
        body: context.tr('onboardBody2'),
      ),
      (
        title: context.tr('onboardTitle3'),
        body: context.tr('onboardBody3'),
      ),
    ];
    final isLast = _index == _slideCount - 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _goToLogin,
                child: Text(
                  context.tr('skip'),
                  style: AppTypography.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slideCount,
                onPageChanged: (value) => setState(() => _index = value),
                itemBuilder: (context, index) {
                  final slide = slides[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      children: [
                        const Spacer(),
                        OnboardingIllustration(index: index),
                        const SizedBox(height: 28),
                        Text(
                          slide.title,
                          textAlign: TextAlign.center,
                          style: AppTypography.heading(fontSize: 24),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          slide.body,
                          textAlign: TextAlign.center,
                          style: AppTypography.subtitle(fontSize: 14),
                        ),
                        const Spacer(flex: 2),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_slideCount, (dotIndex) {
                      final active = dotIndex == _index;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: active ? 18 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: active
                              ? AppColors.primary
                              : AppColors.border,
                          borderRadius: const BorderRadius.all(
                            Radius.circular(8),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 20),
                  PrimaryButton(
                    label: isLast ? context.tr('getStarted') : context.tr('next'),
                    onPressed: _onNext,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

