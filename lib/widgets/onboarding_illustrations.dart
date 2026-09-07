import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class OnboardingIllustration extends StatelessWidget {
  const OnboardingIllustration({super.key, required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: switch (index) {
        0 => const _NeedsIllustration(),
        1 => const _VerifiedIllustration(),
        _ => const _CommunityIllustration(),
      },
    );
  }
}

class _NeedsIllustration extends StatelessWidget {
  const _NeedsIllustration();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        const _SoftBlob(),
        const Icon(Icons.smartphone, size: 88, color: AppColors.primary),
        const Positioned(
          left: 28,
          top: 28,
          child: _ServiceChip(icon: Icons.plumbing),
        ),
        const Positioned(
          right: 24,
          top: 40,
          child: _ServiceChip(icon: Icons.lightbulb_outline),
        ),
        const Positioned(
          right: 48,
          bottom: 24,
          child: _ServiceChip(icon: Icons.cleaning_services_outlined),
        ),
      ],
    );
  }
}

class _VerifiedIllustration extends StatelessWidget {
  const _VerifiedIllustration();

  @override
  Widget build(BuildContext context) {
    return const Stack(
      alignment: Alignment.center,
      children: [
        _SoftBlob(),
        Icon(Icons.engineering, size: 96, color: AppColors.primary),
        Positioned(
          right: 36,
          top: 32,
          child: _ServiceChip(icon: Icons.verified_user, size: 56),
        ),
        Positioned(
          left: 40,
          bottom: 28,
          child: Icon(Icons.thumb_up_alt, color: AppColors.primary, size: 36),
        ),
      ],
    );
  }
}

class _CommunityIllustration extends StatelessWidget {
  const _CommunityIllustration();

  @override
  Widget build(BuildContext context) {
    return const Stack(
      alignment: Alignment.center,
      children: [
        _SoftBlob(),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _PersonDot(),
            SizedBox(width: 8),
            _PersonDot(size: 58),
            SizedBox(width: 8),
            _PersonDot(),
            SizedBox(width: 8),
            _PersonDot(size: 50),
          ],
        ),
        Positioned(
          top: 20,
          child: Icon(Icons.favorite, color: AppColors.primary, size: 32),
        ),
      ],
    );
  }
}

class _SoftBlob extends StatelessWidget {
  const _SoftBlob();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.illustrationSoft.withValues(alpha: 0.45),
      ),
    );
  }
}

class _ServiceChip extends StatelessWidget {
  const _ServiceChip({required this.icon, this.size = 48});

  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: AppColors.onPrimary, size: size * 0.48),
    );
  }
}

class _PersonDot extends StatelessWidget {
  const _PersonDot({this.size = 52});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.person,
        color: AppColors.onPrimary,
        size: size * 0.55,
      ),
    );
  }
}
