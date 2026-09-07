import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';
import '../../models/customer_dashboard_data.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

class TrustGuaranteeCard extends StatelessWidget {
  const TrustGuaranteeCard({super.key});

  @override
  Widget build(BuildContext context) {
    const features = TrustFeatureItem.defaults;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr('whyTrustUs'),
            style: AppTypography.heading(fontSize: 15).copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: features.map((f) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(f.icon, size: 14, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        context.tr(f.titleKey),
                        style: AppTypography.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
