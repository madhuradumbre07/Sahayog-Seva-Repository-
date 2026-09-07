import 'package:flutter/material.dart';

import '../../../l10n/l10n.dart';
import '../../../theme/app_typography.dart';
import '../../../widgets/worker/appointment_timeline_card.dart';

class WorkerAppointmentsView extends StatelessWidget {
  const WorkerAppointmentsView({super.key});

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
