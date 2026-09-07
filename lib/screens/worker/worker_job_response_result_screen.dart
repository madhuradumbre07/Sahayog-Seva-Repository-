import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../l10n/l10n.dart';
import '../../models/worker_job_model.dart';
import '../../providers/worker_job_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/map_view.dart';
import 'worker_job_details_screen.dart';
import 'worker_job_in_progress_screen.dart';

class WorkerJobResponseResultScreen extends StatefulWidget {
  const WorkerJobResponseResultScreen({super.key});

  static const routeName = '/worker/job-response-result';

  @override
  State<WorkerJobResponseResultScreen> createState() =>
      _WorkerJobResponseResultScreenState();
}

class _WorkerJobResponseResultScreenState
    extends State<WorkerJobResponseResultScreen> {
  String? _selectedReason;
  final _reasonController = TextEditingController();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WorkerJobProvider>();
    final accepted =
        provider.lifecycleState == WorkerJobLifecycleState.accepted;
    final job = provider.job;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Text(
          context.tr('workerResponseTitle'),
          style: AppTypography.heading(fontSize: 17),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.timer_outlined),
            tooltip: context.tr('requestExpiresSoon'),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildJobSummary(context, job),
            const SizedBox(height: 14),
            _buildDecisionHeader(context),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildAcceptedCard(context, provider, job)),
                const SizedBox(width: 12),
                Expanded(child: _buildRejectedCard(context, provider, job)),
              ],
            ),
            const SizedBox(height: 14),
            if (!accepted) _buildRejectionReasons(context),
            if (!accepted) const SizedBox(height: 14),
            _buildSafetyCard(context),
            const SizedBox(height: 14),
            _buildCustomerRatingCard(context, job),
            const SizedBox(height: 20),
            Text(
              context.tr('responseTrustNote'),
              textAlign: TextAlign.center,
              style: AppTypography.subtitle(fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJobSummary(BuildContext context, WorkerJobDetailModel job) {
    return Card(
      margin: EdgeInsets.zero,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: const Color(0xFFE8F0FE),
                  backgroundImage: NetworkImage(job.customer.avatarUrl),
                  onBackgroundImageError: (_, _) {},
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr(
                          job.customer.nameKey,
                          fallback: job.customer.name,
                        ),
                        style: AppTypography.heading(fontSize: 14),
                      ),
                      Text(
                        '${job.customer.rating} ${context.tr('ratingReviewsCompact', params: {'count': job.customer.reviewsCount.toString()})}',
                        style: AppTypography.subtitle(fontSize: 11),
                      ),
                    ],
                  ),
                ),
                Text(
                  context.tr(job.priority.key),
                  style: AppTypography.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: job.priority.color,
                  ),
                ),
              ],
            ),
            const Divider(height: 18),
            Row(
              children: [
                const Icon(Icons.plumbing, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    context.tr(job.problemTitleKey),
                    style: AppTypography.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  AppFormatters.formatPriceRange(
                    job.pricing.totalMin,
                    job.pricing.totalMax,
                    context,
                  ),
                  style: AppTypography.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2E7D32),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _summaryLine(
              context,
              Icons.location_on_outlined,
              context.tr(job.addressLineKey, fallback: job.addressLineRaw),
            ),
            _summaryLine(
              context,
              Icons.access_time,
              context.tr(job.scheduledTimeKey),
            ),
            _summaryLine(
              context,
              Icons.near_me_outlined,
              AppFormatters.formatDistance(job.distanceKm, context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryLine(BuildContext context, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: Row(
        children: [
          Icon(icon, size: 15, color: AppColors.textSecondary),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              text,
              style: AppTypography.subtitle(fontSize: 11),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDecisionHeader(BuildContext context) {
    return Text(
      context.tr('decisionHeader'),
      style: AppTypography.heading(fontSize: 16)
          .copyWith(color: AppColors.primary),
    );
  }

  Widget _buildAcceptedCard(
    BuildContext context,
    WorkerJobProvider provider,
    WorkerJobDetailModel job,
  ) {
    return _decisionCard(
      context,
      icon: Icons.check_circle,
      color: const Color(0xFF0B8F4D),
      backgroundColor: const Color(0xFFF2FBF5),
      title: context.tr('youAcceptedHeadline'),
      description: context.tr('acceptedDescription'),
      details: [
        '${context.tr('scheduledTimeLabel')}: ${context.tr(job.scheduledTimeKey)}',
        '${context.tr('estimatedEarningsLabel')}: ${AppFormatters.formatPriceRange(job.pricing.totalMin, job.pricing.totalMax, context)}',
      ],
      buttonLabel: context.tr('acceptJobBtn'),
      onPressed: provider.isLoading
          ? null
          : () async {
              final ok = await provider.transitionTo(
                WorkerJobLifecycleState.navigating,
              );
              if (ok && context.mounted)
                Navigator.pushNamed(
                  context,
                  WorkerJobNavigationScreen.routeName,
                );
            },
      secondaryLabel: context.tr('viewJobDetailsBtn'),
      onSecondaryPressed: () =>
          Navigator.pushNamed(context, WorkerJobDetailsScreen.routeName),
    );
  }

  Widget _buildRejectedCard(
    BuildContext context,
    WorkerJobProvider provider,
    WorkerJobDetailModel job,
  ) {
    return _decisionCard(
      context,
      icon: Icons.cancel,
      color: const Color(0xFFE52420),
      backgroundColor: const Color(0xFFFFF7F7),
      title: context.tr('youRejectedHeadline'),
      description: context.tr('rejectedDescription'),
      details: [
        context.tr('jobReturnedToPool'),
        context.tr('noPenaltyForDeclining'),
      ],
      buttonLabel: context.tr('rejectJobBtn'),
      onPressed: provider.isLoading
          ? null
          : () async {
              final ok = await provider.rejectJob();
              if (ok && context.mounted)
                Navigator.popUntil(context, (route) => route.isFirst);
            },
    );
  }

  Widget _decisionCard(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required Color backgroundColor,
    required String title,
    required String description,
    required List<String> details,
    required String buttonLabel,
    required VoidCallback? onPressed,
    String? secondaryLabel,
    VoidCallback? onSecondaryPressed,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 48),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTypography.poppins(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            textAlign: TextAlign.center,
            style: AppTypography.subtitle(fontSize: 11),
          ),
          const SizedBox(height: 10),
          ...details.map(
            (detail) => Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                detail,
                style: AppTypography.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 11),
                elevation: 0,
              ),
              child: Text(
                buttonLabel,
                textAlign: TextAlign.center,
                style: AppTypography.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          if (secondaryLabel != null) ...[
            const SizedBox(height: 4),
            TextButton(
              onPressed: onSecondaryPressed,
              child: Text(secondaryLabel),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRejectionReasons(BuildContext context) {
    final reasons = <String>[
      'reasonBusy',
      'reasonDistance',
      'reasonSchedule',
      'reasonTools',
      'reasonOther',
    ];
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.tr('rejectionReasonTitle'),
              style: AppTypography.heading(fontSize: 15),
            ),
            const SizedBox(height: 8),
            ...reasons.map((key) => _reasonOption(context, key)),
            TextField(
              controller: _reasonController,
              maxLength: 120,
              decoration: InputDecoration(
                hintText: context.tr('reasonHint'),
                counterText: '',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _reasonOption(BuildContext context, String key) {
    final selected = _selectedReason == key;
    return InkWell(
      onTap: () => setState(() => _selectedReason = key),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: selected ? AppColors.primary : Colors.grey,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                context.tr(key),
                style: AppTypography.subtitle(fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSafetyCard(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      color: const Color(0xFFFFFBF0),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.tr('safetyFirstTitle'),
              style: AppTypography.heading(fontSize: 14),
            ),
            const SizedBox(height: 6),
            ...['safetyResponse1', 'safetyResponse2', 'safetyResponse3'].map(
              (key) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    const Icon(Icons.check, color: Colors.green, size: 16),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        context.tr(key),
                        style: AppTypography.subtitle(fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerRatingCard(
    BuildContext context,
    WorkerJobDetailModel job,
  ) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            const Icon(Icons.star, color: Colors.amber, size: 28),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                context.tr('customerRatingLabel'),
                style: AppTypography.subtitle(fontSize: 12),
              ),
            ),
            Text(
              '${job.customer.rating}',
              style: AppTypography.heading(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}

class WorkerJobNavigationScreen extends StatelessWidget {
  const WorkerJobNavigationScreen({super.key});

  static const routeName = '/worker/job-navigation';

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WorkerJobProvider>();
    final job = provider.job;

    final workerPos = LatLng(job.workerLatitude, job.workerLongitude);
    final customerPos = LatLng(job.customerLatitude, job.customerLongitude);

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('navigationTitle'))),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              context.tr(job.addressLineKey, fallback: job.addressLineRaw),
              style: AppTypography.heading(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              AppFormatters.formatDistance(job.distanceKm, context),
              style: AppTypography.subtitle(fontSize: 14),
            ),
            const SizedBox(height: 20),

            // Live Interactive OpenStreetMap Navigation View
            Expanded(
              child: Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFBBDEFB)),
                ),
                child: AppMapView(
                  initialPosition: workerPos,
                  initialZoom: 14.5,
                  polylines: [
                    Polyline(
                      points: [workerPos, customerPos],
                      color: AppColors.primary,
                      strokeWidth: 5.0,
                    ),
                  ],
                  markers: [
                    // Worker Location Marker
                    Marker(
                      point: workerPos,
                      width: 44,
                      height: 44,
                      child: const CircleAvatar(
                        backgroundColor: AppColors.primary,
                        child: Icon(
                          Icons.navigation,
                          size: 24,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    // Customer Destination Pin
                    Marker(
                      point: customerPos,
                      width: 44,
                      height: 44,
                      child: const CircleAvatar(
                        backgroundColor: Color(0xFFD32F2F),
                        child: Icon(
                          Icons.location_on,
                          size: 26,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: provider.isLoading
                  ? null
                  : () async {
                      final ok = await provider.transitionTo(
                        WorkerJobLifecycleState.arrivedOtp,
                      );
                      if (ok && context.mounted) {
                        Navigator.pushNamed(
                          context,
                          WorkerJobOtpVerifyScreen.routeName,
                        );
                      }
                    },
              icon: const Icon(Icons.location_on_outlined),
              label: Text(context.tr('markArrived')),
            ),
          ],
        ),
      ),
    );
  }
}

class WorkerJobOtpVerifyScreen extends StatefulWidget {
  const WorkerJobOtpVerifyScreen({super.key});

  static const routeName = '/worker/job-otp-verify';

  @override
  State<WorkerJobOtpVerifyScreen> createState() =>
      _WorkerJobOtpVerifyScreenState();
}

class _WorkerJobOtpVerifyScreenState extends State<WorkerJobOtpVerifyScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WorkerJobProvider>();
    final job = provider.job;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          context.tr('otpScreenTitle'),
          style: AppTypography.heading(fontSize: 17),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.headset_mic_outlined),
            label: Text(context.tr('helpLabel')),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _otpMapBanner(context),
            const SizedBox(height: 12),
            _customerOtpCard(context, job),
            const SizedBox(height: 12),
            _otpEntryCard(context, provider),
            const SizedBox(height: 12),
            _locationVerifiedCard(context),
            const SizedBox(height: 12),
            _otpSafetyCard(context),
            const SizedBox(height: 16),
            _otpHelpCard(context),
          ],
        ),
      ),
    );
  }

  Widget _otpMapBanner(BuildContext context) {
    return Container(
      height: 125,
      decoration: BoxDecoration(
        color: const Color(0xFFDCEBFA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          const Center(
            child: Icon(Icons.location_on, color: AppColors.primary, size: 48),
          ),
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: Text(
              context.tr('otpArrivalInstruction'),
              textAlign: TextAlign.center,
              style: AppTypography.poppins(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _customerOtpCard(BuildContext context, WorkerJobDetailModel job) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: const Color(0xFFE8F0FE),
              backgroundImage: NetworkImage(job.customer.avatarUrl),
              onBackgroundImageError: (_, _) {},
              child: const Icon(Icons.person, color: AppColors.primary),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr(
                      job.customer.nameKey,
                      fallback: job.customer.name,
                    ),
                    style: AppTypography.heading(fontSize: 14),
                  ),
                  Text(
                    context.tr(job.problemTitleKey),
                    style: AppTypography.subtitle(fontSize: 11),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.phone, color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _otpEntryCard(BuildContext context, WorkerJobProvider provider) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.tr('otpEnterLabel'),
              style: AppTypography.heading(fontSize: 15),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: AppTypography.heading(fontSize: 26)
                  .copyWith(letterSpacing: 8),
              decoration: InputDecoration(
                hintText: '------',
                counterText: '',
                hintStyle: AppTypography.heading(fontSize: 24)
                    .copyWith(color: Colors.grey.shade300, letterSpacing: 8),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.verified, color: Colors.green, size: 17),
                const SizedBox(width: 5),
                Text(
                  context.tr('otpVerifiedLabel'),
                  style: AppTypography.poppins(
                    fontSize: 11,
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: provider.isLoading
                  ? null
                  : () async {
                      final ok = await provider.verifyOtp(
                        _controller.text.trim(),
                      );
                      if (ok && context.mounted)
                        Navigator.pushNamed(
                          context,
                          WorkerJobInProgressScreen.routeName,
                        );
                    },
              icon: const Icon(Icons.arrow_forward),
              label: Text(context.tr('verifyAndStartJob')),
            ),
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.refresh),
              label: Text(context.tr('resendOtp')),
            ),
            if (provider.error != null)
              Text(
                context.tr('invalidOtp'),
                style: const TextStyle(color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }

  Widget _locationVerifiedCard(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      color: const Color(0xFFF2FBF5),
      child: ListTile(
        leading: const Icon(Icons.location_on_outlined, color: Colors.green),
        title: Text(
          context.tr('locationVerifiedTitle'),
          style: AppTypography.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        subtitle: Text(
          context.tr('locationVerifiedDescription'),
          style: AppTypography.subtitle(fontSize: 11),
        ),
      ),
    );
  }

  Widget _otpSafetyCard(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      color: const Color(0xFFFFFBF0),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.tr('otpSafetyTitle'),
              style: AppTypography.heading(fontSize: 14),
            ),
            ...['otpSafety1', 'otpSafety2', 'otpSafety3'].map(
              (key) => Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      size: 16,
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        context.tr(key),
                        style: AppTypography.subtitle(fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _otpHelpCard(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.tr('otpProblemTitle'),
              style: AppTypography.heading(fontSize: 14),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    child: Text(context.tr('resendOtp')),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    child: Text(context.tr('contactSupport')),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
