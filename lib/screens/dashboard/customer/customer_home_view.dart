import 'package:flutter/material.dart';

import '../../../widgets/customer/ai_problem_card.dart';
import '../../../widgets/customer/greeting_header.dart';
import '../../../widgets/customer/ongoing_booking_card.dart';
import '../../../widgets/customer/popular_services_grid.dart';
import '../../../widgets/customer/promo_banner_card.dart';
import '../../../widgets/customer/trust_guarantee_card.dart';

class CustomerHomeView extends StatelessWidget {
  const CustomerHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GreetingHeader(),
          AiProblemCard(),
          PopularServicesGrid(),
          OngoingBookingCard(),
          TrustGuaranteeCard(),
          PromoBannerCard(),
          SizedBox(height: 80), // Space for bottom nav
        ],
      ),
    );
  }
}
