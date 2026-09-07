import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';

import '../../l10n/l10n.dart';
import '../../models/booking_tracking_model.dart';
import '../../providers/booking_tracking_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/language_selector_button.dart';
import '../../widgets/map_view.dart';

class CustomerTrackServiceScreen extends StatefulWidget {
  const CustomerTrackServiceScreen({super.key, required this.bookingId});

  final String bookingId;
  static const String routeName = '/customer/track-service';

  @override
  State<CustomerTrackServiceScreen> createState() =>
      _CustomerTrackServiceScreenState();
}

class _CustomerTrackServiceScreenState
    extends State<CustomerTrackServiceScreen> {
  BookingTrackingProvider? _trackingProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final provider = context.read<BookingTrackingProvider>();
      _trackingProvider = provider;
      if (provider.hasInjectedMockData) {
        provider.startPolling(widget.bookingId);
        return;
      }
      provider.resetTracking();
      provider.fetchTrackingData(widget.bookingId).then((_) {
        if (mounted) {
          provider.startPolling(widget.bookingId);
        }
      });
    });
  }

  @override
  void dispose() {
    _trackingProvider?.stopPolling();
    super.dispose();
  }

  void _showReportIssueSheet(BuildContext context, AppStrings l10n) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.reportIssueTitle,
                style: AppTypography.heading(fontSize: 18)
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.reportIssueSub,
                style: AppTypography.subtitle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(
                  Icons.timer_off_outlined,
                  color: AppColors.error,
                ),
                title: Text(
                  l10n.issueWorkerLate,
                  style: AppTypography.body(fontSize: 14),
                ),
                onTap: () => Navigator.pop(ctx),
              ),
              ListTile(
                leading: const Icon(
                  Icons.person_off_outlined,
                  color: AppColors.error,
                ),
                title: Text(
                  l10n.issueWrongWorker,
                  style: AppTypography.body(fontSize: 14),
                ),
                onTap: () => Navigator.pop(ctx),
              ),
              ListTile(
                leading: const Icon(
                  Icons.error_outline,
                  color: AppColors.error,
                ),
                title: Text(
                  l10n.issueOtherProblem,
                  style: AppTypography.body(fontSize: 14),
                ),
                onTap: () => Navigator.pop(ctx),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProgressBar(TrackingStage currentStage) {
    final stages = [
      TrackingStage.ACCEPTED,
      TrackingStage.WORKER_ASSIGNED,
      TrackingStage.ON_THE_WAY,
      TrackingStage.ARRIVED,
      TrackingStage.SERVICE_STARTED,
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(stages.length, (index) {
        final stage = stages[index];
        final isCompleted = currentStage.stageIndex >= stage.stageIndex;
        final isCurrent = currentStage == stage;

        return Expanded(
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 4,
                  color: isCompleted ? AppColors.primary : Colors.grey.shade300,
                ),
              ),
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted ? AppColors.primary : Colors.grey.shade300,
                  border: isCurrent
                      ? Border.all(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          width: 4,
                        )
                      : null,
                ),
                child: Icon(
                  stage.iconData,
                  size: 14,
                  color: isCompleted ? Colors.white : Colors.grey.shade600,
                ),
              ),
              Expanded(
                child: Container(
                  height: 4,
                  color: currentStage.stageIndex > stage.stageIndex
                      ? AppColors.primary
                      : Colors.grey.shade300,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildMapPreview() {
    final provider = context.watch<BookingTrackingProvider>();
    final trackingData = provider.trackingData;

    // Fallback state if data is loading or missing
    if (trackingData == null) {
      return Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFE8F0FE),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    // Extract LatLng coordinates from your model
    final workerPos = LatLng(
      trackingData.workerLatitude,
      trackingData.workerLongitude,
    );
    final customerPos = LatLng(
      trackingData.customerLatitude,
      trackingData.customerLongitude,
    );

    return Container(
      height: 200,
      width: double.infinity,
      clipBehavior:
          Clip.antiAlias, // Clips the map corners to match border radius
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
      child: AppMapView(
        initialPosition: workerPos,
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
            width: 40,
            height: 40,
            child: const Icon(
              Icons.directions_bike,
              size: 32,
              color: AppColors.primary,
            ),
          ),
          // Customer Location Marker
          Marker(
            point: customerPos,
            width: 40,
            height: 40,
            child: const Icon(
              Icons.location_on,
              size: 36,
              color: AppColors.error,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppStrings.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          l10n.trackServiceTitle,
          style: AppTypography.heading(
            fontSize: 17,
          ).copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => _showReportIssueSheet(context, l10n),
          ),
          const Padding(
            padding: EdgeInsets.only(right: 12),
            child: LanguageSelectorButton(),
          ),
        ],
      ),
      body: Consumer<BookingTrackingProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.trackingData == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = provider.trackingData;
          if (data == null) {
            return Center(child: Text(l10n.noTrackingDataFound));
          }

          final stage = data.currentStage;
          final isCompleted = stage == TrackingStage.COMPLETED;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Booking ID & Status Chip
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${l10n.bookingIdLabel}: ${data.bookingCode}',
                      style: AppTypography.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? AppColors.success.withValues(alpha: 0.1)
                            : AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        l10n.tr(stage.l10nKey),
                        style: AppTypography.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isCompleted
                              ? AppColors.success
                              : AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Map Preview (only active when tracking)
                if (stage == TrackingStage.ON_THE_WAY ||
                    stage == TrackingStage.WORKER_ASSIGNED) ...[
                  _buildMapPreview(),
                  const SizedBox(height: 24),
                ],

                // Dynamic ETA Hero
                if (stage == TrackingStage.ON_THE_WAY) ...[
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          l10n.etaMinutesAway(data.etaMinutes),
                          style: AppTypography.poppins(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.workerOnTheWayMsg,
                          style: AppTypography.body(fontSize: 14)
                              .copyWith(color: Colors.white70),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ] else if (stage == TrackingStage.ARRIVED) ...[
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.warning,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 48,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.workerArrivedMsg,
                          style: AppTypography.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ] else if (stage == TrackingStage.SERVICE_STARTED) ...[
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF673AB7),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.build_circle,
                          size: 48,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.serviceStartedMsg,
                          style: AppTypography.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ] else if (isCompleted) ...[
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          size: 48,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.serviceCompletedMsg,
                          style: AppTypography.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // 5-Stage Progress Bar
                _buildProgressBar(stage),
                const SizedBox(height: 32),

                // Worker Info Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundImage: data.workerAvatarUrl.isNotEmpty
                            ? NetworkImage(data.workerAvatarUrl)
                            : null,
                        child: data.workerAvatarUrl.isEmpty
                            ? const Icon(Icons.person)
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  data.localizedWorkerName(context),
                                  style: AppTypography.poppins(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                if (data.isVerified)
                                  const Icon(
                                    Icons.verified,
                                    size: 16,
                                    color: AppColors.primary,
                                  ),
                              ],
                            ),
                            Text(
                              '${data.localizedServiceName(context)} - ${data.localizedSubcategory(context)}',
                              style: AppTypography.subtitle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF8E1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.star,
                              size: 14,
                              color: AppColors.warning,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              data.ratingAvg.toStringAsFixed(1),
                              style: AppTypography.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.warning,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Dynamic Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.call, size: 18),
                        label: Text(l10n.callWorkerBtn),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.chat_bubble_outline, size: 18),
                        label: Text(l10n.chatWorkerBtn),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (!isCompleted && stage != TrackingStage.SERVICE_STARTED)
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.qr_code),
                    label: Text(l10n.shareOtpBtn),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 54),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: AppTypography.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                else if (isCompleted)
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/customer/service-completion',
                        arguments: widget.bookingId,
                      );
                    },
                    icon: const Icon(Icons.arrow_forward),
                    label: Text(l10n.proceedToPaymentBtn),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 54),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: AppTypography.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
