import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/l10n.dart';
import '../../models/worker_matching_model.dart';
import '../../providers/booking_flow_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/language_selector_button.dart';
import 'customer_booking_details_screen.dart';

class CustomerWorkerProfileScreen extends StatelessWidget {
  const CustomerWorkerProfileScreen({
    super.key,
    required this.worker,
  });

  final WorkerMatchModel worker;
  static const String routeName = '/customer/worker-profile';

  void _showShareModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              context.tr('shareWorkerProfile'),
              style: AppTypography.heading(fontSize: 16).copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _shareOption(Icons.message, context.tr('shareWhatsApp')),
                _shareOption(Icons.sms, context.tr('shareSms')),
                _shareOption(Icons.link, context.tr('shareCopyLink')),
                _shareOption(Icons.more_horiz, context.tr('shareMore')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _shareOption(IconData icon, String label) {
    return Column(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: const Color(0xFFF1F5F9),
          child: Icon(icon, color: AppColors.primary),
        ),
        const SizedBox(height: 6),
        Text(label, style: AppTypography.subtitle(fontSize: 11)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeLocale = Localizations.localeOf(context).languageCode;
    final name = worker.localizedName(activeLocale);
    final isLowMatch = worker.matchScore < 50;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        surfaceTintColor: Colors.transparent,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          context.tr('workerProfileTitle'),
          style: AppTypography.heading(fontSize: 17).copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: AppColors.textPrimary),
            onPressed: () => _showShareModal(context),
          ),
          const Padding(
            padding: EdgeInsets.only(right: 12),
            child: LanguageSelectorButton(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isLowMatch) ...[
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFFB74D)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Color(0xFFE65100)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        context.tr('lowMatchWarning'),
                        style: AppTypography.poppins(fontSize: 12, color: const Color(0xFFE65100)),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            _buildHeroCard(context, name),
            const SizedBox(height: 14),

            _buildCooperativeCard(context),
            const SizedBox(height: 14),

            _buildExplainableScoreCard(context),
            const SizedBox(height: 14),

            _buildSkillsSection(context),
            const SizedBox(height: 14),

            _buildCertificationsCard(context),
            const SizedBox(height: 14),

            _buildGalleryCard(context),
            const SizedBox(height: 14),

            _buildReviewsCard(context),
          ],
        ),
      ),
      bottomSheet: _buildFixedBottomBar(context),
    );
  }

  Widget _buildHeroCard(BuildContext context, String name) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundImage: NetworkImage(worker.avatarUrl),
                  ),
                  if (worker.isVerified)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: Color(0xFF2E7D32),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.verified, size: 14, color: Colors.white),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: AppTypography.heading(fontSize: 17).copyWith(fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (worker.isVerified) ...[
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${worker.primaryTrade} (${worker.localizedTradeSubtitle(context)})',
                      style: AppTypography.subtitle(fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 16, color: Color(0xFFFFA000)),
                        const SizedBox(width: 4),
                        Text(
                          '${worker.ratingAvg} (${worker.reviewCount} ${context.tr('reviewsLabel')})',
                          style: AppTypography.poppins(fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Text(
                    '${worker.distanceKm} km • ${worker.localizedAddressArea(context)}',
                    style: AppTypography.subtitle(fontSize: 12),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: worker.isAvailable ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: worker.isAvailable ? const Color(0xFF2E7D32) : const Color(0xFFE65100),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      worker.localizedStatusText(context),
                      style: AppTypography.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: worker.isAvailable ? const Color(0xFF2E7D32) : const Color(0xFFE65100),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCooperativeCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF81C784)),
            ),
            child: const Icon(Icons.handshake, color: Color(0xFF2E7D32), size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('cooperativeVerifiedBadge'),
                  style: AppTypography.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2E7D32),
                  ),
                ),
                Text(
                  worker.localizedSociety(context),
                  style: AppTypography.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Member ID: ${worker.memberId}',
                  style: AppTypography.subtitle(fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExplainableScoreCard(BuildContext context) {
    final exp = worker.explainability;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.tr('matchScoreBreakdownTitle'),
                style: AppTypography.poppins(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${worker.matchScore}% Match',
                  style: AppTypography.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2E7D32),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            worker.localizedReasonSummary(context),
            style: AppTypography.subtitle(fontSize: 12),
          ),
          const SizedBox(height: 14),
          _buildScoreBar(context.tr('skillMatchBar'), exp.skillMatchPercent, const Color(0xFF1565C0)),
          const SizedBox(height: 8),
          _buildScoreBar(context.tr('proximityBar'), exp.proximityPercent, const Color(0xFF2E7D32)),
          const SizedBox(height: 8),
          _buildScoreBar(context.tr('availabilityBar'), exp.availabilityPercent, const Color(0xFFE65100)),
          const SizedBox(height: 8),
          _buildScoreBar(context.tr('workloadFairnessBar'), exp.workloadFairnessPercent, const Color(0xFF6A1B9A)),
        ],
      ),
    );
  }

  Widget _buildScoreBar(String label, int value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTypography.subtitle(fontSize: 11)),
            Text('$value%', style: AppTypography.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: value / 100.0,
            backgroundColor: color.withValues(alpha: 0.12),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  Widget _buildSkillsSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr('skillsAndExpLabel'),
            style: AppTypography.poppins(fontSize: 13, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: worker.skills.map((s) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  s,
                  style: AppTypography.poppins(fontSize: 11, color: const Color(0xFF334155)),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _metricItem('${worker.experienceYears}', context.tr('yearsExpMetric')),
              _metricItem('${worker.jobsCompletedCount}', context.tr('completedJobsMetric')),
              _metricItem('${worker.responseTimeMinutes}m', context.tr('responseTimeLabel', params: {'min': '${worker.responseTimeMinutes}'})),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metricItem(String value, String label) {
    return Column(
      children: [
        Text(value, style: AppTypography.heading(fontSize: 15).copyWith(fontWeight: FontWeight.bold, color: AppColors.primary)),
        const SizedBox(height: 2),
        Text(label, style: AppTypography.subtitle(fontSize: 10)),
      ],
    );
  }

  Widget _buildCertificationsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
              const Icon(Icons.verified_user_outlined, size: 18, color: Color(0xFF2E7D32)),
              const SizedBox(width: 8),
              Text(
                context.tr('certificationsLabel'),
                style: AppTypography.poppins(fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...worker.certifications.map((c) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_outline, size: 16, color: Color(0xFF2E7D32)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(c.title, style: AppTypography.poppins(fontSize: 12, fontWeight: FontWeight.w600)),
                        Text(c.issuer, style: AppTypography.subtitle(fontSize: 10)),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildGalleryCard(BuildContext context) {
    if (worker.galleryUrls.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr('workGalleryLabel'),
            style: AppTypography.poppins(fontSize: 13, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 90,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: worker.galleryUrls.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (ctx, idx) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    worker.galleryUrls[idx],
                    width: 110,
                    height: 90,
                    fit: BoxFit.cover,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.tr('reviewsLabel'),
                style: AppTypography.poppins(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  const Icon(Icons.star, size: 16, color: Color(0xFFFFA000)),
                  const SizedBox(width: 4),
                  Text(
                    '${worker.ratingAvg} / 5.0',
                    style: AppTypography.poppins(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (worker.reviews.isEmpty)
            Text(
              'No reviews yet',
              style: AppTypography.subtitle(fontSize: 12),
            ),
          ...worker.reviews.map((r) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(r.localizedAuthor(context), style: AppTypography.poppins(fontSize: 12, fontWeight: FontWeight.bold)),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 14, color: Color(0xFFFFA000)),
                          Text('${r.rating}', style: AppTypography.poppins(fontSize: 11, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(r.localizedComment(context), style: AppTypography.body(fontSize: 12)),
                  const SizedBox(height: 2),
                  Text(r.localizedDate(context), style: AppTypography.subtitle(fontSize: 10)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFixedBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.tr('estCostLabel'),
                style: AppTypography.subtitle(fontSize: 10),
              ),
              Text(
                AppFormatters.formatPriceRange(worker.hourlyRateMin, worker.hourlyRateMax, context),
                style: AppTypography.heading(fontSize: 16).copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),
          OutlinedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(context.tr('chatOpenedToast'))),
              );
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              side: const BorderSide(color: AppColors.primary),
            ),
            child: Row(
              children: [
                const Icon(Icons.chat_bubble_outline, size: 16, color: AppColors.primary),
                const SizedBox(width: 4),
                Text(context.tr('chatBtn'), style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                context.read<BookingFlowProvider>().initializeForWorker(worker);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CustomerBookingDetailsScreen(worker: worker),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                context.tr('bookNowBtn'),
                style: AppTypography.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
