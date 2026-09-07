import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../l10n/l10n.dart';
import '../../../providers/worker_dashboard_provider.dart';
import '../../../theme/app_typography.dart';
import '../../../widgets/worker/job_request_alert_card.dart';

class WorkerJobsView extends StatelessWidget {
  const WorkerJobsView({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<WorkerDashboardProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              context.tr('allJobsPool'),
              style: AppTypography.heading(fontSize: 20),
            ),
          ),
          if (prov.pendingRequests.isNotEmpty)
            const JobRequestAlertCard()
          else
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  context.tr('noJobRequests'),
                  style: AppTypography.subtitle(fontSize: 14),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
