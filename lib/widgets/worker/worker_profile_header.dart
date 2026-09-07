import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/l10n.dart';
import '../../models/worker_dashboard_data.dart';
import '../../providers/auth_provider.dart';
import '../../providers/worker_dashboard_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../workspace_switcher_sheet.dart';

class WorkerProfileHeader extends StatelessWidget {
  const WorkerProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final workerProv = context.watch<WorkerDashboardProvider>();
    final isOnline = workerProv.availability == WorkerAvailability.online;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar with status indicator
          Stack(
            children: [
              const CircleAvatar(
                radius: 28,
                backgroundColor: Color(0xFFE8F0FE),
                child: Icon(Icons.handyman, color: AppColors.primary, size: 28),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: isOnline ? const Color(0xFF2E7D32) : Colors.grey,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),

          // Worker Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 6,
                  runSpacing: 2,
                  children: [
                    Text(
                      auth.localizedWorkerName(context),
                      style: AppTypography.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (auth.isWorkerVerified)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          context.tr('workerVerified'),
                          style: AppTypography.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2E7D32),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  context.tr('plumberTradeExp'),
                  style: AppTypography.subtitle(fontSize: 12),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, color: Color(0xFFFFA000), size: 14),
                    const SizedBox(width: 4),
                    Text(
                      context.tr('workerRating'),
                      style: AppTypography.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF475569),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Switch Role button
          IconButton(
            onPressed: () => WorkspaceSwitcherSheet.show(context),
            icon: const Icon(Icons.swap_horiz, color: AppColors.primary),
            tooltip: context.tr('switchWorkspace'),
          ),
        ],
      ),
    );
  }
}
