import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/l10n.dart';
import '../../models/worker_job_model.dart';
import '../../providers/worker_job_provider.dart';
import '../../theme/app_typography.dart';
import 'worker_job_completion_summary_screen.dart';

class WorkerJobInProgressScreen extends StatelessWidget {
  const WorkerJobInProgressScreen({super.key});

  static const routeName = '/worker/job-in-progress';

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WorkerJobProvider>();
    final job = provider.job;
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('jobInProgressTitle'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(context.tr(job.problemTitleKey), style: AppTypography.heading(fontSize: 20)),
          const SizedBox(height: 8),
          Text(context.tr(job.addressLineKey, fallback: job.addressLineRaw), style: AppTypography.subtitle(fontSize: 14)),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(context.tr('scopeOfWorkSection'), style: AppTypography.heading(fontSize: 16)),
                  const SizedBox(height: 10),
                  ...job.scopeOfWork.map((item) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.check_circle_outline, color: Colors.green),
                        title: Text(context.tr(item.titleKey)),
                      )),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(context.tr(job.customerNoteKey), style: AppTypography.subtitle(fontSize: 14)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: provider.isLoading
                ? null
                : () async {
                    final ok = await provider.transitionTo(WorkerJobLifecycleState.completed);
                    if (ok && context.mounted) Navigator.pushNamed(context, WorkerJobCompletionSummaryScreen.routeName);
                  },
            child: Text(context.tr('completeJob')),
          ),
        ],
      ),
    );
  }
}
