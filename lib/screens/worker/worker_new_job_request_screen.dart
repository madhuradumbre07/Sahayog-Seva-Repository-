import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../l10n/l10n.dart';
import '../../models/worker_job_model.dart';
import '../../providers/worker_job_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/language_selector_button.dart';
import '../../widgets/map_view.dart';
import 'worker_job_details_screen.dart';
import 'worker_job_response_result_screen.dart';

class WorkerNewJobRequestScreen extends StatefulWidget {
  const WorkerNewJobRequestScreen({super.key});

  static const String routeName = '/worker/new-job-request';

  @override
  State<WorkerNewJobRequestScreen> createState() =>
      _WorkerNewJobRequestScreenState();
}

class _WorkerNewJobRequestScreenState extends State<WorkerNewJobRequestScreen> {
  WorkerJobProvider? _jobProv;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<WorkerJobProvider>().startCountdownTimer();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _jobProv = context.read<WorkerJobProvider>();
  }

  @override
  void dispose() {
    _jobProv?.stopCountdownTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<WorkerJobProvider>();
    final job = prov.job;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: true,
        title: Text(
          context.tr('newJobRequestTitle'),
          style: AppTypography.heading(
            fontSize: 17,
          ).copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_none,
              color: AppColors.textPrimary,
            ),
            tooltip: context.tr('newJobRequestTitle'),
            onPressed: () {},
          ),
          const Padding(
            padding: EdgeInsets.only(right: 8),
            child: LanguageSelectorButton(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Request ID & Expiry Pill
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Request ID: ${job.id}',
                  style: AppTypography.subtitle(fontSize: 12)
                      .copyWith(fontWeight: FontWeight.w600),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: prov.countdownSeconds <= 30
                        ? const Color(0xFFFFEBEE)
                        : const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: prov.countdownSeconds <= 30
                          ? const Color(0xFFEF5350)
                          : const Color(0xFFFFB74D),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        size: 14,
                        color: prov.countdownSeconds <= 30
                            ? const Color(0xFFD32F2F)
                            : const Color(0xFFE65100),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        context.tr(
                          'expiresInLabel',
                          params: {'time': prov.formattedCountdown},
                        ),
                        style: AppTypography.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: prov.countdownSeconds <= 30
                              ? const Color(0xFFD32F2F)
                              : const Color(0xFFE65100),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Alternate State Banner Card
            _buildStateCard(context, prov),
            const SizedBox(height: 12),

            // Customer Info Card
            _buildCustomerCard(context, job.customer),
            const SizedBox(height: 12),

            // Service & Problem Card
            _buildServiceProblemCard(context, job),
            const SizedBox(height: 12),

            // Location Card
            _buildLocationCard(context, job),
            const SizedBox(height: 12),

            // 3-Column Quick Metrics Card
            _buildMetricsRow(context, job),
            const SizedBox(height: 12),

            // Time & Slot Card
            _buildTimeSlotCard(context, job),
            const SizedBox(height: 12),

            // Customer Request Note Card
            _buildCustomerNoteCard(context, job),
            const SizedBox(height: 20),

            // Action Buttons
            _buildActionButtons(context, prov),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStateCard(BuildContext context, WorkerJobProvider prov) {
    final state = prov.currentState;
    Color bgColor;
    Color borderColor;
    Color iconColor;
    IconData icon;
    String headline;
    String sub;

    switch (state) {
      case JobRequestState.normal:
        bgColor = const Color(0xFFF1F8E9);
        borderColor = const Color(0xFFC5E1A5);
        iconColor = const Color(0xFF33691E);
        icon = Icons.notifications_active;
        headline = context.tr('normalStateHeadline');
        sub = context.tr('normalStateSub');
        break;
      case JobRequestState.expiring:
        bgColor = const Color(0xFFFFF3E0);
        borderColor = const Color(0xFFFFCC80);
        iconColor = const Color(0xFFE65100);
        icon = Icons.alarm;
        headline = context.tr('expiringStateHeadline');
        sub = context.tr('expiringStateSub');
        break;
      case JobRequestState.expired:
        bgColor = const Color(0xFFFFEBEE);
        borderColor = const Color(0xFFFFCDD2);
        iconColor = const Color(0xFFC62828);
        icon = Icons.cancel;
        headline = context.tr('expiredStateHeadline');
        sub = context.tr('expiredStateSub');
        break;
      case JobRequestState.acceptedByOther:
        bgColor = const Color(0xFFE0F2F1);
        borderColor = const Color(0xFF80CBC4);
        iconColor = const Color(0xFF00695C);
        icon = Icons.check_circle_outline;
        headline = context.tr('acceptedByOtherHeadline');
        sub = context.tr('acceptedByOtherSub');
        break;
      case JobRequestState.youAccepted:
        bgColor = const Color(0xFFE8F5E9);
        borderColor = const Color(0xFFA5D6A7);
        iconColor = const Color(0xFF2E7D32);
        icon = Icons.assignment_turned_in;
        headline = context.tr('youAcceptedHeadline');
        sub = context.tr('youAcceptedSub');
        break;
      case JobRequestState.youRejected:
        bgColor = const Color(0xFFECEFF1);
        borderColor = const Color(0xFFCFD8DC);
        iconColor = const Color(0xFF455A64);
        icon = Icons.highlight_off;
        headline = context.tr('youRejectedHeadline');
        sub = context.tr('youRejectedSub');
        break;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: iconColor.withValues(alpha: 0.15),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  headline,
                  style: AppTypography.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(sub, style: AppTypography.subtitle(fontSize: 12)),
              ],
            ),
          ),
          if (state == JobRequestState.youAccepted)
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const WorkerJobDetailsScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                context.tr('viewJobDetailsBtn'),
                style: AppTypography.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCustomerCard(BuildContext context, JobCustomerInfo customer) {
    return InkWell(
      onTap: () => _showCustomerInfoModal(context, customer),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: const Color(0xFFE8F0FE),
              backgroundImage: NetworkImage(customer.avatarUrl),
              onBackgroundImageError: (_, _) {},
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          context.tr(customer.nameKey, fallback: customer.name),
                          style: AppTypography.heading(fontSize: 15)
                              .copyWith(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.verified,
                              color: Color(0xFF2E7D32),
                              size: 12,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              context.tr('verifiedBadge'),
                              style: AppTypography.poppins(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF2E7D32),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${customer.rating} ',
                        style: AppTypography.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        context.tr(
                          'reviewsCountText',
                          params: {'count': customer.reviewsCount.toString()},
                        ),
                        style: AppTypography.subtitle(fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFFE8F0FE),
                child: const Icon(
                  Icons.phone,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '${context.tr('callCustomerBtn')}: ${customer.phone}',
                    ),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceProblemCard(
    BuildContext context,
    WorkerJobDetailModel job,
  ) {
    return InkWell(
      onTap: () => _showServiceDetailsModal(context, job),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F0FE),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.plumbing,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr(job.problemTitleKey),
                        style: AppTypography.heading(fontSize: 15)
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        context.tr(job.problemDescriptionKey),
                        style: AppTypography.subtitle(fontSize: 12),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                context.tr(job.serviceCategoryKey),
                style: AppTypography.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationCard(BuildContext context, WorkerJobDetailModel job) {
    return InkWell(
      onTap: () => _showLocationModal(context, job),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.location_on, color: AppColors.primary, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr('locationInfoTitle'),
                    style: AppTypography.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    context.tr(
                      job.addressLineKey,
                      fallback: job.addressLineRaw,
                    ),
                    style: AppTypography.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: () => _showLocationModal(context, job),
              icon: const Icon(Icons.map_outlined, size: 14),
              label: Text(
                context.tr('mapBtnLabel'),
                style: AppTypography.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                visualDensity: VisualDensity.compact,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsRow(BuildContext context, WorkerJobDetailModel job) {
    return Row(
      children: [
        Expanded(
          child: _metricPill(
            context,
            icon: Icons.navigation_outlined,
            iconColor: const Color(0xFF1976D2),
            title: context.tr('distanceLabel'),
            value: AppFormatters.formatDistance(job.distanceKm, context),
            onTap: () => _showLocationModal(context, job),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _metricPill(
            context,
            icon: Icons.currency_rupee,
            iconColor: const Color(0xFF388E3C),
            title: context.tr('estimatedPriceLabel'),
            value: AppFormatters.formatPriceRange(
              job.pricing.totalMin,
              job.pricing.totalMax,
              context,
            ),
            onTap: () => _showPriceBreakdownModal(context, job),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _metricPill(
            context,
            icon: Icons.flag,
            iconColor: job.priority.color,
            title: context.tr('priorityLabel'),
            value: context.tr(job.priority.key),
            badgeColor: job.priority.backgroundColor,
            valueColor: job.priority.color,
            onTap: () => _showPriorityModal(context, job),
          ),
        ),
      ],
    );
  }

  Widget _metricPill(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    Color? badgeColor,
    Color? valueColor,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(icon, size: 14, color: iconColor),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    title,
                    style: AppTypography.subtitle(fontSize: 10),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Container(
              padding: badgeColor != null
                  ? const EdgeInsets.symmetric(horizontal: 6, vertical: 2)
                  : EdgeInsets.zero,
              decoration: badgeColor != null
                  ? BoxDecoration(
                      color: badgeColor,
                      borderRadius: BorderRadius.circular(6),
                    )
                  : null,
              child: Text(
                value,
                style: AppTypography.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: valueColor ?? AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSlotCard(BuildContext context, WorkerJobDetailModel job) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.access_time, color: AppColors.primary, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('timeLabel'),
                  style: AppTypography.subtitle(fontSize: 11),
                ),
                const SizedBox(height: 2),
                Text(
                  context.tr(job.scheduledTimeKey),
                  style: AppTypography.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              context.tr(job.scheduledFlexibilityKey),
              style: AppTypography.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2E7D32),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerNoteCard(
    BuildContext context,
    WorkerJobDetailModel job,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.chat_bubble_outline,
            color: AppColors.textSecondary,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('customerRequestLabel'),
                  style: AppTypography.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  context.tr(job.customerNoteKey),
                  style: AppTypography.subtitle(fontSize: 12)
                      .copyWith(fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, WorkerJobProvider prov) {
    final isActionable = prov.currentState.isActionable;

    if (!isActionable) {
      return OutlinedButton(
        onPressed: () => Navigator.of(context).pop(),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          context.tr('dismissBtn'),
          style: AppTypography.poppins(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return Row(
      children: [
        // Reject Button
        Expanded(
          child: OutlinedButton(
            onPressed: prov.isLoading
                ? null
                : () async {
                    final ok = await prov.rejectJob();
                    if (ok && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(context.tr('jobRejectedSuccessToast')),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      Navigator.pushNamed(
                        context,
                        WorkerJobResponseResultScreen.routeName,
                      );
                    }
                  },
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFD32F2F),
              side: const BorderSide(color: Color(0xFFD32F2F), width: 1.5),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              '✕ ${context.tr('rejectJobBtn')}',
              style: AppTypography.poppins(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFD32F2F),
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),

        // Accept Button
        Expanded(
          child: ElevatedButton(
            onPressed: prov.isLoading
                ? null
                : () async {
                    final ok = await prov.acceptJob();
                    if (ok && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(context.tr('jobAcceptedSuccessToast')),
                          backgroundColor: const Color(0xFF2E7D32),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      Navigator.pushNamed(
                        context,
                        WorkerJobResponseResultScreen.routeName,
                      );
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            child: Text(
              '✓ ${context.tr('acceptJobBtn')}',
              style: AppTypography.poppins(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // --- MODAL SHEETS ---

  void _showCustomerInfoModal(BuildContext context, JobCustomerInfo customer) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ctx.tr('customerInfoTitle'),
              style: AppTypography.heading(fontSize: 18)
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            const Divider(),
            const SizedBox(height: 8),
            _infoRow(
              ctx.tr('customerInfoTitle'),
              ctx.tr(customer.nameKey, fallback: customer.name),
            ),
            _infoRow(
              ctx.tr('totalJobsLabel'),
              customer.totalBookings.toString(),
            ),
            _infoRow(ctx.tr('membershipLabel'), ctx.tr('verifiedBadge')),
            _infoRow(
              ctx.tr('lastJobLabel'),
              ctx.tr(customer.memberDurationKey),
            ),
            _infoRow(
              ctx.tr('cancelledJobsLabel'),
              customer.cancelledBookings.toString(),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(double.infinity, 44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                ctx.tr('viewProfileBtn'),
                style: AppTypography.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showServiceDetailsModal(
    BuildContext context,
    WorkerJobDetailModel job,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ctx.tr('serviceDetailsTitle'),
              style: AppTypography.heading(fontSize: 18)
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            const Divider(),
            const SizedBox(height: 8),
            _infoRow(ctx.tr('categoryLabel'), ctx.tr(job.serviceCategoryKey)),
            _infoRow(ctx.tr('skillLabel'), ctx.tr(job.serviceSubcategoryKey)),
            _infoRow(ctx.tr('estTimeLabel'), ctx.tr(job.estimatedDurationKey)),
            _infoRow(ctx.tr('requiredToolsLabel'), ctx.tr('basicToolsValue')),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(double.infinity, 44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                ctx.tr('viewJobDetailsBtn'),
                style: AppTypography.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLocationModal(BuildContext context, WorkerJobDetailModel job) {
    final customerPos = LatLng(job.customerLatitude, job.customerLongitude);
    final workerPos = LatLng(job.workerLatitude, job.workerLongitude);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ctx.tr('locationInfoTitle'),
              style: AppTypography.heading(fontSize: 18)
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              AppFormatters.formatDistance(job.distanceKm, ctx),
              style: AppTypography.poppins(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              ctx.tr(job.addressLineKey, fallback: job.addressLineRaw),
              style: AppTypography.subtitle(fontSize: 13),
            ),
            const SizedBox(height: 14),
            //Map Preview
            Container(
              height: 180,
              width: double.infinity,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFBBDEFB)),
              ),
              child: AppMapView(
                initialPosition: customerPos,
                initialZoom: 13.5,
                polylines: [
                  Polyline(
                    points: [workerPos, customerPos],
                    color: AppColors.primary,
                    strokeWidth: 4.0,
                  ),
                ],
                markers: [
                  // Worker Marker
                  Marker(
                    point: workerPos,
                    width: 36,
                    height: 36,
                    child: const CircleAvatar(
                      backgroundColor: AppColors.primary,
                      child: Icon(
                        Icons.person_pin,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  // Customer Destination Pin
                  Marker(
                    point: customerPos,
                    width: 36,
                    height: 36,
                    child: const CircleAvatar(
                      backgroundColor: Color(0xFFD32F2F),
                      child: Icon(
                        Icons.location_on,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(double.infinity, 44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                ctx.tr('closeMapBtn', fallback: 'Close Map'),
                style: AppTypography.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPriceBreakdownModal(
    BuildContext context,
    WorkerJobDetailModel job,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ctx.tr('estPriceTitle'),
              style: AppTypography.heading(fontSize: 18)
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            const Divider(),
            const SizedBox(height: 8),
            _infoRow(
              ctx.tr('serviceChargeLabel'),
              AppFormatters.formatPriceRange(
                job.pricing.laborMin,
                job.pricing.laborMax,
                ctx,
              ),
            ),
            _infoRow(
              ctx.tr('visitingChargeLabel'),
              AppFormatters.formatPriceRange(
                job.pricing.visitingMin,
                job.pricing.visitingMax,
                ctx,
              ),
            ),
            _infoRow(
              ctx.tr('materialsEstLabel'),
              AppFormatters.formatPriceRange(
                job.pricing.materialsMin,
                job.pricing.materialsMax,
                ctx,
              ),
            ),
            const Divider(),
            _infoRow(
              ctx.tr('totalExpectedLabel'),
              AppFormatters.formatPriceRange(
                job.pricing.totalMin,
                job.pricing.totalMax,
                ctx,
              ),
              isBold: true,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(double.infinity, 44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                ctx.tr('dismissBtn'),
                style: AppTypography.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPriorityModal(BuildContext context, WorkerJobDetailModel job) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.flag, color: job.priority.color, size: 22),
                const SizedBox(width: 8),
                Text(
                  ctx.tr('priorityInfoTitle'),
                  style: AppTypography.heading(fontSize: 18)
                      .copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              ctx.tr(job.priority.key),
              style: AppTypography.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: job.priority.color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              ctx.tr('priorityUrgentDesc'),
              style: AppTypography.subtitle(fontSize: 13),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(double.infinity, 44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                ctx.tr('dismissBtn'),
                style: AppTypography.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            flex: 2,
            child: Text(label, style: AppTypography.subtitle(fontSize: 13)),
          ),
          const SizedBox(width: 8),
          Flexible(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: AppTypography.poppins(
                fontSize: 13,
                fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
                color: isBold ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
