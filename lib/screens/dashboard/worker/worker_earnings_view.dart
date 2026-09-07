import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../l10n/l10n.dart';
import '../../../providers/worker_dashboard_provider.dart';
import '../../../theme/app_typography.dart';

class WorkerEarningsView extends StatelessWidget {
  const WorkerEarningsView({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<WorkerDashboardProvider>();
    final metrics = prov.metrics;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16).copyWith(bottom: 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr('earningsOverview'),
            style: AppTypography.heading(fontSize: 20),
          ),
          const SizedBox(height: 16),

          // Total Earnings Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('monthlyTotalEarnings'),
                  style: AppTypography.poppins(
                    fontSize: 13,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  AppFormatters.formatPrice(metrics.monthlyEarnings, context),
                  style: AppTypography.heading(fontSize: 28).copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Divider(color: Colors.white24, height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      context.tr('todayEarningsLabel', params: {'amount': metrics.todayEarnings.toString()}),
                      style: AppTypography.poppins(
                        fontSize: 13,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      context.tr('completedJobsCount', params: {'count': metrics.completedJobsToday.toString()}),
                      style: AppTypography.poppins(
                        fontSize: 13,
                        color: const Color(0xFFA5D6A7),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
