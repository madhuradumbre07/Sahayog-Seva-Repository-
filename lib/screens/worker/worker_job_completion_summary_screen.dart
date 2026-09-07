import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/l10n.dart';
import '../../providers/worker_job_provider.dart';
import '../../theme/app_typography.dart';
import '../home/home_screen.dart';

class WorkerJobCompletionSummaryScreen extends StatelessWidget {
  const WorkerJobCompletionSummaryScreen({super.key});

  static const routeName = '/worker/job-completion-summary';

  @override
  Widget build(BuildContext context) {
    final job = context.watch<WorkerJobProvider>().job;
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('completionSummaryTitle'))),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Icon(Icons.verified, color: Colors.green, size: 72),
          const SizedBox(height: 16),
          Text(context.tr('completedMessage'), textAlign: TextAlign.center, style: AppTypography.heading(fontSize: 20)),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _row(context, context.tr('serviceLabel'), context.tr(job.problemTitleKey)),
                  _row(context, context.tr('customerLabel'), context.tr(job.customer.nameKey, fallback: job.customer.name)),
                  _row(context, context.tr('totalEarningsLabel'), AppFormatters.formatPriceRange(job.pricing.totalMin, job.pricing.totalMax, context)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () { 
              Navigator.of(context).pushNamedAndRemoveUntil(
                HomeScreen.routeName,
                (route) => false,
              );
            },
            child: Text(context.tr('continueToHome')),
          ),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.subtitle(fontSize: 13)),
          Flexible(child: Text(value, textAlign: TextAlign.end, style: AppTypography.poppins(fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }
}
