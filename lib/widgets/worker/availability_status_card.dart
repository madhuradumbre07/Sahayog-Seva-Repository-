import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/l10n.dart';
import '../../models/worker_dashboard_data.dart';
import '../../providers/worker_dashboard_provider.dart';
import '../../theme/app_typography.dart';

class AvailabilityStatusCard extends StatelessWidget {
  const AvailabilityStatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<WorkerDashboardProvider>();
    final currentStatus = prov.availability;
    final isOnline = currentStatus == WorkerAvailability.online;

    Color statusColor;
    Color statusBgColor;
    String statusTitleKey;
    String statusDescKey;

    switch (currentStatus) {
      case WorkerAvailability.online:
        statusColor = const Color(0xFF2E7D32);
        statusBgColor = const Color(0xFFE8F5E9);
        statusTitleKey = 'availabilityOnline';
        statusDescKey = 'onlineStatusDesc';
        break;
      case WorkerAvailability.busy:
        statusColor = const Color(0xFFE65100);
        statusBgColor = const Color(0xFFFFF3E0);
        statusTitleKey = 'availabilityBusy';
        statusDescKey = 'busyStatusDesc';
        break;
      case WorkerAvailability.offline:
        statusColor = const Color(0xFF757575);
        statusBgColor = const Color(0xFFF5F5F5);
        statusTitleKey = 'availabilityOffline';
        statusDescKey = 'offlineStatusDesc';
        break;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusBgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                context.tr(statusTitleKey),
                style: AppTypography.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
              const Spacer(),
              Switch(
                value: isOnline,
                activeThumbColor: const Color(0xFF2E7D32),
                activeTrackColor: const Color(0xFFA5D6A7),
                onChanged: (_) => prov.toggleOnlineOffline(),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            context.tr(statusDescKey),
            style: AppTypography.poppins(
              fontSize: 12,
              color: statusColor.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 10),

          // Status selector buttons [Online, Busy, Offline]
          Row(
            children: [
              _statusChip(
                context,
                prov,
                WorkerAvailability.online,
                'Online',
                const Color(0xFF2E7D32),
              ),
              const SizedBox(width: 8),
              _statusChip(
                context,
                prov,
                WorkerAvailability.busy,
                'Busy',
                const Color(0xFFE65100),
              ),
              const SizedBox(width: 8),
              _statusChip(
                context,
                prov,
                WorkerAvailability.offline,
                'Offline',
                const Color(0xFF757575),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusChip(
    BuildContext context,
    WorkerDashboardProvider prov,
    WorkerAvailability target,
    String label,
    Color color,
  ) {
    final isSelected = prov.availability == target;
    return Expanded(
      child: GestureDetector(
        onTap: () => prov.setAvailability(target),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? color : Colors.grey.shade300,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: AppTypography.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.grey.shade700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
