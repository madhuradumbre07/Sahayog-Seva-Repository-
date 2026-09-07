import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../l10n/l10n.dart';
import '../../../providers/customer_dashboard_provider.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';

class CustomerServicesView extends StatelessWidget {
  const CustomerServicesView({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<CustomerDashboardProvider>();
    final services = prov.services;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16).copyWith(bottom: 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr('allServicesCatalog'),
            style: AppTypography.heading(fontSize: 20),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 1.1,
            ),
            itemCount: services.length,
            itemBuilder: (context, index) {
              final service = services[index];
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: service.bgColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(service.icon, color: service.color, size: 28),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      context.tr(service.titleKey),
                      style: AppTypography.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (service.startingPrice != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Starts ₹${service.startingPrice}',
                        style: AppTypography.subtitle(fontSize: 11),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
