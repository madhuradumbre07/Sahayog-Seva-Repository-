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

class WorkerJobDetailsScreen extends StatefulWidget {
  const WorkerJobDetailsScreen({super.key});

  static const String routeName = '/worker/job-details';

  @override
  State<WorkerJobDetailsScreen> createState() => _WorkerJobDetailsScreenState();
}

class _WorkerJobDetailsScreenState extends State<WorkerJobDetailsScreen> {
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
          context.tr('jobDetailsTitle'),
          style: AppTypography.heading(fontSize: 17).copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: AppColors.textPrimary),
            tooltip: 'Share',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Job ID: ${job.id}'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
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
            // Top summary: Request ID & Priority Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Request ID: ${job.id}',
                  style: AppTypography.subtitle(fontSize: 12).copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: job.priority.backgroundColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.flag, size: 12, color: job.priority.color),
                      const SizedBox(width: 4),
                      Text(
                        context.tr('highPriorityBadge'),
                        style: AppTypography.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: job.priority.color,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Customer Summary Card
            _buildCustomerCard(context, job.customer),
            const SizedBox(height: 10),

            // Service & Location Card
            _buildServiceLocationCard(context, job),
            const SizedBox(height: 10),

            // Expiry Banner
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEBEE),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFFFCDD2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.timer, color: Color(0xFFD32F2F), size: 18),
                  const SizedBox(width: 8),
                  Text(
                    context.tr('requestExpiresInBanner', params: {'time': prov.formattedCountdown}),
                    style: AppTypography.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFD32F2F),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Contact & Profile Quick Actions
            _buildContactActions(context, job.customer),
            const SizedBox(height: 18),

            // 1. Problem & AI Analysis
            _buildProblemAndAiSection(context, job),
            const SizedBox(height: 16),

            // 2. Scope of Work
            _buildScopeOfWorkSection(context, job),
            const SizedBox(height: 16),

            // 3. Required Tools
            _buildRequiredToolsSection(context, job),
            const SizedBox(height: 16),

            // 4. Location & Map
            _buildLocationAndMapSection(context, job),
            const SizedBox(height: 16),

            // 5. Estimated Earnings & Materials
            _buildEarningsAndMaterialsSection(context, job),
            const SizedBox(height: 16),

            // 6. Customer Notes
            _buildCustomerNotesSection(context, job),
            const SizedBox(height: 16),

            // 7. Safety Guidelines
            _buildSafetyGuidelinesSection(context, job),
            const SizedBox(height: 16),

            // 8. Additional Information
            _buildAdditionalInfoSection(context, job),
            const SizedBox(height: 16),

            // 9. Customer Profile Summary
            _buildCustomerProfileSummary(context, job.customer),
            const SizedBox(height: 24),

            // Accepted jobs can only be released during the short cancellation window.
            _buildReleaseAction(context, prov),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerCard(BuildContext context, JobCustomerInfo customer) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xFFE8F0FE),
            backgroundImage: NetworkImage(customer.avatarUrl),
            onBackgroundImageError: (_, _) {},
            child: const Icon(Icons.person, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      context.tr(customer.nameKey, fallback: customer.name),
                      style: AppTypography.heading(fontSize: 15).copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        context.tr('verifiedBadge'),
                        style: AppTypography.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2E7D32),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '${customer.rating} ',
                      style: AppTypography.poppins(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      context.tr('reviewsCountText', params: {'count': customer.reviewsCount.toString()}),
                      style: AppTypography.subtitle(fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFFE8F0FE),
              child: const Icon(Icons.phone, color: AppColors.primary, size: 18),
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${context.tr('callCustomerBtn')}: ${customer.phone}'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildServiceLocationCard(BuildContext context, WorkerJobDetailModel job) {
    return Container(
      padding: const EdgeInsets.all(12),
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
              const Icon(Icons.plumbing, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  context.tr(job.problemTitleKey),
                  style: AppTypography.poppins(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F4F8),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  context.tr(job.serviceCategoryKey),
                  style: AppTypography.subtitle(fontSize: 11),
                ),
              ),
            ],
          ),
          const Divider(height: 16),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  context.tr(job.addressLineKey, fallback: job.addressLineRaw),
                  style: AppTypography.subtitle(fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                AppFormatters.formatDistance(job.distanceKm, context),
                style: AppTypography.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.access_time, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(
                context.tr(job.scheduledTimeKey),
                style: AppTypography.subtitle(fontSize: 12),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  context.tr(job.scheduledFlexibilityKey),
                  style: AppTypography.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: const Color(0xFF2E7D32)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.currency_rupee, size: 16, color: Color(0xFF388E3C)),
              const SizedBox(width: 6),
              Text(
                '${context.tr('estEarningsLabel')}: ',
                style: AppTypography.subtitle(fontSize: 12),
              ),
              Text(
                AppFormatters.formatPriceRange(job.pricing.totalMin, job.pricing.totalMax, context),
                style: AppTypography.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF388E3C)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactActions(BuildContext context, JobCustomerInfo customer) {
    return Row(
      children: [
        Expanded(
          child: _contactButton(
            context,
            icon: Icons.phone,
            label: context.tr('callCustomerBtn'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${context.tr('callCustomerBtn')}: ${customer.phone}')),
              );
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _contactButton(
            context,
            icon: Icons.chat_bubble_outline,
            label: context.tr('chatCustomerBtn'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(context.tr('chatCustomerBtn'))),
              );
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _contactButton(
            context,
            icon: Icons.person_outline,
            label: context.tr('customerProfileBtn'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(context.tr('customerProfileBtn'))),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _contactButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 10),
        side: BorderSide(color: Colors.grey.shade300),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTypography.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // 1. Problem & AI Analysis
  Widget _buildProblemAndAiSection(BuildContext context, WorkerJobDetailModel job) {
    return _sectionContainer(
      title: context.tr('problemAndAiSection'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr('customerReportedProblem'),
            style: AppTypography.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Text(
              context.tr(job.problemDescriptionKey),
              style: AppTypography.poppins(fontSize: 13, color: AppColors.textPrimary),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            context.tr('aiAnalysisLabel'),
            style: AppTypography.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F0FE),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFBBDEFB)),
            ),
            child: Text(
              context.tr(job.aiAnalysisKey),
              style: AppTypography.poppins(fontSize: 13, color: const Color(0xFF1565C0)),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(context.tr('recommendedService'), style: AppTypography.subtitle(fontSize: 11)),
                  Text(context.tr(job.serviceSubcategoryKey), style: AppTypography.poppins(fontSize: 13, fontWeight: FontWeight.bold)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(context.tr('estDurationLabel'), style: AppTypography.subtitle(fontSize: 11)),
                  Text(context.tr(job.estimatedDurationKey), style: AppTypography.poppins(fontSize: 13, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text('${context.tr('difficultyLabel')}: ', style: AppTypography.subtitle(fontSize: 11)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  context.tr(job.difficultyKey),
                  style: AppTypography.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF2E7D32)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 2. Scope of Work
  Widget _buildScopeOfWorkSection(BuildContext context, WorkerJobDetailModel job) {
    return _sectionContainer(
      title: context.tr('scopeOfWorkSection'),
      child: Column(
        children: job.scopeOfWork.map((item) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.check_circle, color: Color(0xFF2E7D32), size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    context.tr(item.titleKey),
                    style: AppTypography.poppins(fontSize: 13, color: AppColors.textPrimary),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // 3. Required Tools
  Widget _buildRequiredToolsSection(BuildContext context, WorkerJobDetailModel job) {
    return _sectionContainer(
      title: context.tr('requiredToolsSection'),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: job.requiredTools.map((tool) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(tool.icon, size: 16, color: AppColors.primary),
                const SizedBox(width: 6),
                Text(
                  context.tr(tool.nameKey),
                  style: AppTypography.poppins(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // 4. Location & Map
  Widget _buildLocationAndMapSection(BuildContext context, WorkerJobDetailModel job) {
    final workerPos = LatLng(job.workerLatitude, job.workerLongitude);
    final customerPos = LatLng(job.customerLatitude, job.customerLongitude);
    return _sectionContainer(
      title: context.tr('locationAndMapSection'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr(job.addressLineKey, fallback: job.addressLineRaw),
            style: AppTypography.poppins(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            AppFormatters.formatDistance(job.distanceKm, context),
            style: AppTypography.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
          ),
          const SizedBox(height: 10),

          // Interactive OpenStreetMap Container
          Container(
            height: 160,
            width: double.infinity,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFBBDEFB)),
            ),
            child: Stack(
              children: [
                AppMapView(
                  initialPosition: customerPos,
                  initialZoom: 13.0,
                  polylines: [
                    Polyline(
                      points: [workerPos, customerPos],
                      color: AppColors.primary,
                      strokeWidth: 4.0,
                    ),
                  ],
                  markers: [
                    // Worker Pin
                    Marker(
                      point: workerPos,
                      width: 36,
                      height: 36,
                      child: const CircleAvatar(
                        backgroundColor: AppColors.primary,
                        child: Icon(Icons.person_pin, size: 20, color: Colors.white),
                      ),
                    ),
                    // Customer Pin
                    Marker(
                      point: customerPos,
                      width: 36,
                      height: 36,
                      child: const CircleAvatar(
                        backgroundColor: Color(0xFFD32F2F),
                        child: Icon(Icons.home, size: 20, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: ElevatedButton.icon(
                    onPressed: () {
                        _showFullMapModal(context, workerPos, customerPos, job);
                    },
                    icon: const Icon(Icons.map, size: 14),
                    label: Text(
                      context.tr('openMapBtn'),
                      style: AppTypography.poppins(fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                      elevation: 2,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${context.tr('premiseTypeLabel')}: ${context.tr(job.premiseTypeKey)}', style: AppTypography.subtitle(fontSize: 12)),
              Text('${context.tr('floorLabel')}: ${context.tr(job.floorKey)}', style: AppTypography.subtitle(fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  void _showFullMapModal(
    BuildContext context,
    LatLng workerPos,
    LatLng customerPos,
    WorkerJobDetailModel job,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        insetPadding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 450,
          child: Column(
            children: [
              AppBar(
                title: Text(
                  context.tr(job.addressLineKey, fallback: job.addressLineRaw),
                ),
                automaticallyImplyLeading: false,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              Expanded(
                child: AppMapView(
                  initialPosition: customerPos,
                  initialZoom: 14.0,
                  polylines: [
                    Polyline(
                      points: [workerPos, customerPos],
                      color: AppColors.primary,
                      strokeWidth: 4.0,
                    ),
                  ],
                  markers: [
                    Marker(
                      point: workerPos,
                      width: 40,
                      height: 40,
                      child: const CircleAvatar(
                        backgroundColor: AppColors.primary,
                        child: Icon(
                          Icons.person_pin,
                          size: 24,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Marker(
                      point: customerPos,
                      width: 40,
                      height: 40,
                      child: const CircleAvatar(
                        backgroundColor: Color(0xFFD32F2F),
                        child: Icon(Icons.home, size: 24, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 5. Estimated Earnings & Materials
  Widget _buildEarningsAndMaterialsSection(BuildContext context, WorkerJobDetailModel job) {
    return _sectionContainer(
      title: context.tr('earningsAndMaterialsSection'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.tr('estEarningsLabel'),
                style: AppTypography.poppins(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              Text(
                AppFormatters.formatPriceRange(job.pricing.totalMin, job.pricing.totalMax, context),
                style: AppTypography.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF2E7D32)),
              ),
            ],
          ),
          const Divider(height: 16),
          _infoRow(
            context.tr('laborChargeLabel'),
            AppFormatters.formatPriceRange(job.pricing.laborMin, job.pricing.laborMax, context),
          ),
          _infoRow(
            context.tr('materialsChargeLabel'),
            AppFormatters.formatPriceRange(job.pricing.materialsMin, job.pricing.materialsMax, context),
          ),
          _infoRow(
            context.tr('totalExpectedLabel'),
            AppFormatters.formatPriceRange(job.pricing.totalMin, job.pricing.totalMax, context),
            isBold: true,
          ),
          const SizedBox(height: 10),

          // Pricing disclaimer
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8E1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFFFE082)),
            ),
            child: Text(
              context.tr('pricingDisclaimerNote'),
              style: AppTypography.subtitle(fontSize: 11).copyWith(
                color: const Color(0xFFF57F17),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Materials Required List
          Text(
            context.tr('materialsRequiredSection'),
            style: AppTypography.poppins(fontSize: 13, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          ...job.materials.map((mat) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(context.tr(mat.nameKey), style: AppTypography.subtitle(fontSize: 12)),
                  Text(
                    AppFormatters.formatPriceRange(mat.priceMin, mat.priceMax, context),
                    style: AppTypography.poppins(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // 6. Customer Notes
  Widget _buildCustomerNotesSection(BuildContext context, WorkerJobDetailModel job) {
    return _sectionContainer(
      title: context.tr('customerNotesSection'),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.format_quote, color: AppColors.textSecondary, size: 22),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                context.tr(job.customerNoteKey),
                style: AppTypography.poppins(fontSize: 13).copyWith(fontStyle: FontStyle.italic),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 7. Safety Guidelines
  Widget _buildSafetyGuidelinesSection(BuildContext context, WorkerJobDetailModel job) {
    return _sectionContainer(
      title: context.tr('safetyGuidelinesSection'),
      child: Column(
        children: job.safetyGuidelines.map((key) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.shield_outlined, color: Color(0xFF2E7D32), size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    context.tr(key),
                    style: AppTypography.subtitle(fontSize: 12),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // 8. Additional Information
  Widget _buildAdditionalInfoSection(BuildContext context, WorkerJobDetailModel job) {
    return _sectionContainer(
      title: context.tr('additionalInfoSection'),
      child: Column(
        children: [
          _infoRow(context.tr('payMethodOnlineUpi'), context.tr('payMethodOnlineUpi')),
          _infoRow(context.tr('cancellationPolicyTitle'), context.tr(job.cancellationPolicyKey)),
          _infoRow(context.tr('supportTitle'), context.tr(job.supportAvailabilityKey)),
        ],
      ),
    );
  }

  // 9. Customer Profile Summary
  Widget _buildCustomerProfileSummary(BuildContext context, JobCustomerInfo customer) {
    return _sectionContainer(
      title: context.tr('customerProfileSummaryTitle'),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFFE8F0FE),
                backgroundImage: NetworkImage(customer.avatarUrl),
                onBackgroundImageError: (_, _) {},
                child: const Icon(Icons.person, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr(customer.nameKey, fallback: customer.name),
                    style: AppTypography.poppins(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 14),
                      const SizedBox(width: 4),
                      Text('${customer.rating}', style: AppTypography.poppins(fontSize: 12, fontWeight: FontWeight.bold)),
                      Text(
                        ' ${context.tr('reviewsCountText', params: {'count': customer.reviewsCount.toString()})}',
                        style: AppTypography.subtitle(fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 20),
          Row(
            children: [
              Expanded(
                child: _miniStat(
                  context,
                  title: context.tr('totalJobsLabel'),
                  value: customer.totalBookings.toString(),
                ),
              ),
              Expanded(
                child: _miniStat(
                  context,
                  title: context.tr('successfulJobsCount'),
                  value: customer.completedBookings.toString(),
                  color: const Color(0xFF2E7D32),
                ),
              ),
              Expanded(
                child: _miniStat(
                  context,
                  title: context.tr('cancelledJobsCount'),
                  value: customer.cancelledBookings.toString(),
                  color: const Color(0xFFD32F2F),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniStat(BuildContext context, {required String title, required String value, Color? color}) {
    return Column(
      children: [
        Text(
          value,
          style: AppTypography.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color ?? AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          title,
          style: AppTypography.subtitle(fontSize: 10),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildReleaseAction(BuildContext context, WorkerJobProvider prov) {
    return OutlinedButton.icon(
      onPressed: prov.isLoading
          ? null
          : () async {
              final ok = await prov.releaseAcceptedJob();
              if (!context.mounted) return;
              if (ok) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(context.tr('jobRejectedSuccessToast')),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                Navigator.of(context).pop();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(context.tr('jobReleaseWindowExpired')),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
      icon: const Icon(Icons.close),
      label: Text(context.tr('rejectJobBtn')),
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFFD32F2F),
        side: const BorderSide(color: Color(0xFFD32F2F), width: 1.5),
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _sectionContainer({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.heading(fontSize: 15).copyWith(fontWeight: FontWeight.bold),
          ),
          const Divider(height: 20),
          child,
        ],
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
            child: Text(label, style: AppTypography.subtitle(fontSize: 12)),
          ),
          const SizedBox(width: 8),
          Flexible(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: AppTypography.poppins(
                fontSize: 12,
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
