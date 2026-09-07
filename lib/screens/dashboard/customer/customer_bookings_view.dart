import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../l10n/l10n.dart';
import '../../../providers/customer_dashboard_provider.dart';
import '../../../theme/app_typography.dart';
import '../../../widgets/customer/ongoing_booking_card.dart';

class CustomerBookingsView extends StatelessWidget {
  const CustomerBookingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<CustomerDashboardProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              context.tr('myBookings'),
              style: AppTypography.heading(fontSize: 20),
            ),
          ),
          if (prov.activeBooking != null)
            const OngoingBookingCard()
          else
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  context.tr('noBookingsYet'),
                  style: AppTypography.subtitle(fontSize: 14),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
