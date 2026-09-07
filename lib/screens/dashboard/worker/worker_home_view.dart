import 'package:flutter/material.dart';

import '../../../widgets/worker/appointment_timeline_card.dart';
import '../../../widgets/worker/availability_status_card.dart';
import '../../../widgets/worker/job_request_alert_card.dart';
import '../../../widgets/worker/metrics_summary_card.dart';
import '../../../widgets/worker/worker_profile_header.dart';

class WorkerHomeView extends StatelessWidget {
  const WorkerHomeView({super.key});

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
          SizedBox(height: 80), // Space for bottom nav
        ],
      ),
    );
  }
}
