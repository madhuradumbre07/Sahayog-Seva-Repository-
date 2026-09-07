import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.enabled = true,
    this.loading = false,
    this.allowTapWhenDisabled = false,
  });

  final String label;
  final VoidCallback onPressed;
  final bool enabled;
  final bool loading;
  final bool allowTapWhenDisabled;

  @override
  Widget build(BuildContext context) {
    final visuallyOn = enabled || loading;
    final tappable = !loading && (enabled || allowTapWhenDisabled);

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: tappable ? onPressed : null,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: visuallyOn
              ? AppColors.primary
              : AppColors.disabledButton,
          foregroundColor: AppColors.onPrimary,
          disabledBackgroundColor: visuallyOn
              ? AppColors.primary
              : AppColors.disabledButton,
          disabledForegroundColor: AppColors.onPrimary,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
        child: loading
            ? const SizedBox.square(
                dimension: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: AppColors.onPrimary,
                ),
              )
            : Text(label, style: AppTypography.button()),
      ),
    );
  }
}
