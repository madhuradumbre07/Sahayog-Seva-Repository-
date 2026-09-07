import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'handshake_logo.dart';

class BrandHeader extends StatelessWidget {
  const BrandHeader({
    super.key,
    this.strings,
    this.logoSize = 56,
    this.onGlobePressed,
    this.showGlobe = false,
  });

  final AppStrings? strings;
  final double logoSize;
  final VoidCallback? onGlobePressed;
  final bool showGlobe;

  @override
  Widget build(BuildContext context) {
    final brandName = strings?.brandName ?? context.tr('brandName');
    final tagline1 = strings?.taglineLine1 ?? context.tr('taglineLine1');
    final tagline2 = strings?.taglineLine2 ?? context.tr('taglineLine2');
    final chooseLanguage =
        strings?.chooseLanguage ?? context.tr('chooseLanguage');

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            HandshakeLogo(size: logoSize),
            if (showGlobe)
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  tooltip: chooseLanguage,
                  onPressed: onGlobePressed,
                  icon: const Icon(
                    Icons.public,
                    color: AppColors.primary,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          brandName,
          textAlign: TextAlign.center,
          style: AppTypography.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
            height: 1.15,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '$tagline1\n$tagline2',
          textAlign: TextAlign.center,
          style: AppTypography.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: AppColors.subtitle,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

