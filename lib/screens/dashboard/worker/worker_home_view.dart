import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/auth_provider.dart';
import '../../../providers/worker_dashboard_provider.dart';
import '../../../providers/worker_profile_provider.dart';
import '../../../widgets/worker/appointment_timeline_card.dart';
import '../../../widgets/worker/availability_status_card.dart';
import '../../../widgets/worker/job_request_alert_card.dart';
import '../../../widgets/worker/metrics_summary_card.dart';
import '../../../widgets/worker/worker_profile_header.dart';

class WorkerHomeView extends StatefulWidget {
  const WorkerHomeView({super.key});

  @override
  State<WorkerHomeView> createState() => _WorkerHomeViewState();
}

class _WorkerHomeViewState extends State<WorkerHomeView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      final userId = auth.backendUserId;
      if (userId.isEmpty) return;
      context.read<WorkerProfileProvider>().loadProfile(userId);
      context.read<WorkerDashboardProvider>().loadDashboard(userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          WorkerProfileHeader(),
          AvailabilityStatusCard(),
          JobRequestAlertCard(),
          AppointmentTimelineCard(),
          MetricsSummaryCard(),
          SizedBox(height: 80),
        ],
      ),
    );
  }
}
