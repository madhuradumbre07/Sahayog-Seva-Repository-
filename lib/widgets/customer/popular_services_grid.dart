import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/l10n.dart';
import '../../providers/customer_dashboard_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

class PopularServicesGrid extends StatelessWidget {
  const PopularServicesGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<CustomerDashboardProvider>();
    final services = prov.services;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  context.tr('popularServices'),
                  style: AppTypography.heading(fontSize: 17).copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(context.tr('allServicesCatalog')),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: Text(
                  context.tr('viewAll'),
                  style: AppTypography.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            child: Row(
              children: services.map((service) {
                return GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Selected service: ${context.tr(service.titleKey)}'),
                        backgroundColor: service.color,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 14),
                    child: Column(
                      children: [
                        Container(
                          width: 62,
                          height: 62,
                          decoration: BoxDecoration(
                            color: service.bgColor,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: service.color.withValues(alpha: 0.25),
                              width: 1.2,
                            ),
                          ),
                          child: Icon(
                            service.icon,
                            color: service.color,
                            size: 30,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          context.tr(service.titleKey),
                          style: AppTypography.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
