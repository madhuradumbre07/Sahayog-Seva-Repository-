import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../l10n/l10n.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/worker_dashboard_provider.dart';
import '../../../theme/app_typography.dart';
import '../../../widgets/worker/appointment_timeline_card.dart';

class WorkerAppointmentsView extends StatefulWidget {
  const WorkerAppointmentsView({super.key});

  @override
  State<WorkerAppointmentsView> createState() => _WorkerAppointmentsViewState();
}

class _WorkerAppointmentsViewState extends State<WorkerAppointmentsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final id = context.read<AuthProvider>().backendUserId;
      if (id.isNotEmpty) {
        context.read<WorkerDashboardProvider>().loadDashboard(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              context.tr('todayAppointments'),
              style: AppTypography.heading(fontSize: 20),
            ),
          ),
          const AppointmentTimelineCard(),
        ],
      ),
    );
  }
}
