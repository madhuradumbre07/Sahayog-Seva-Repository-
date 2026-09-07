import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'primary_button.dart';

class NetworkErrorView extends StatelessWidget {
  const NetworkErrorView({
    super.key,
    this.strings,
    required this.onTryAgain,
  });

  final AppStrings? strings;
  final VoidCallback onTryAgain;

  @override
  Widget build(BuildContext context) {
    final title = strings?.noInternetTitle ?? context.tr('noInternetTitle');
    final body = strings?.noInternetBody ?? context.tr('noInternetBody');
    final tryAgain = strings?.tryAgain ?? context.tr('tryAgain');

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          children: [
            const Spacer(),
            Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.wifi, size: 88, color: AppColors.primary),
                Positioned(
                  right: -4,
                  bottom: -4,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 18,
                      color: AppColors.onPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTypography.heading(fontSize: 22),
            ),
            const SizedBox(height: 8),
            Text(
              body,
              textAlign: TextAlign.center,
              style: AppTypography.subtitle(),
            ),
            const Spacer(),
            PrimaryButton(label: tryAgain, onPressed: onTryAgain),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class TooManyAttemptsView extends StatelessWidget {
  const TooManyAttemptsView({
    super.key,
    this.title,
    required this.countdown,
    this.retryLabel,
  });

  final String? title;
  final String countdown;
  final String? retryLabel;

  @override
  Widget build(BuildContext context) {
    final displayTitle = title ?? context.tr('tooManyAttempts');
    final displayRetry = retryLabel ?? context.tr('tryAgainIn');

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          children: [
            const Spacer(),
            const Icon(Icons.lock, size: 72, color: AppColors.error),
            const SizedBox(height: 20),
            Text(
              displayTitle,
              textAlign: TextAlign.center,
              style: AppTypography.heading(fontSize: 22),
            ),
            const SizedBox(height: 8),
            Text(
              '$displayRetry $countdown',
              textAlign: TextAlign.center,
              style: AppTypography.subtitle(),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

class SecurityBadge extends StatelessWidget {
  const SecurityBadge({super.key, this.label});

  final String? label;

  @override
  Widget build(BuildContext context) {
    final displayLabel = label ?? context.tr('securityBadge');

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.verified_user, size: 18, color: AppColors.primary),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            displayLabel,
            textAlign: TextAlign.center,
            style: AppTypography.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.subtitle,
            ),
          ),
        ),
      ],
    );
  }
}

