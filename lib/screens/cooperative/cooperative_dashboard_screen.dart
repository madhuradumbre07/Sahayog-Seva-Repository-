import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/l10n.dart';
import '../../models/cooperative_dashboard_data.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cooperative_dashboard_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/handshake_logo.dart';
import '../../widgets/language_selector_button.dart';

class CooperativeDashboardScreen extends StatefulWidget {
  const CooperativeDashboardScreen({super.key});

  static const String routeName = '/cooperative/dashboard';

  @override
  State<CooperativeDashboardScreen> createState() => _CooperativeDashboardScreenState();
}

class _CooperativeDashboardScreenState extends State<CooperativeDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CooperativeDashboardProvider>().loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CooperativeDashboardProvider>();
    final auth = context.watch<AuthProvider>();
    final data = provider.dashboardData ?? const CooperativeDashboardData();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAppBar(context, auth, data),
      body: provider.isLoading && provider.dashboardData == null
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () => provider.loadDashboard(showLoading: false),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Mission Banner Pill
                    _buildCommunityMissionPill(context, data),
                    const SizedBox(height: 12),

                    // 2. Dashboard Header Titles
                    _buildDashboardHeader(context),
                    const SizedBox(height: 14),

                    // 3. Dynamic Welcome Hero Banner
                    _buildHeroGreetingBanner(context, auth, data),
                    const SizedBox(height: 18),

                    // 4. KPI Metrics Cards
                    _buildKpiMetricsGrid(context, data.kpiMetrics),
                    const SizedBox(height: 22),

                    // 5. Job Requests Section
                    _buildJobRequestsSection(context, data.jobRequests),
                    const SizedBox(height: 22),

                    // 6. Analytics Section (Service Demand & Worker Availability)
                    _buildAnalyticsSection(context, provider, data),
                    const SizedBox(height: 22),

                    // 7. Earnings Overview
                    _buildEarningsOverviewCard(context, provider, data.earningsOverview),
                    const SizedBox(height: 22),

                    // 8. Recent Assignments
                    _buildRecentAssignmentsSection(context, data.recentAssignments),
                    const SizedBox(height: 22),

                    // 9. Members & Upcoming Jobs Tabs/Accordions
                    _buildMembersAndUpcomingSection(context, data),
                    const SizedBox(height: 22),

                    // 10. 2x2 Quick Actions
                    _buildQuickActionsSection(context, data.quickActions),
                    const SizedBox(height: 24),

                    // 11. Footer Empowerment Banner
                    _buildFooterCard(context),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: _buildPersistentBottomNav(context, provider),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    AuthProvider auth,
    CooperativeDashboardData data,
  ) {
    final societyName = auth.cooperativeName.isNotEmpty ? auth.cooperativeName : data.societyName;

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.5,
      surfaceTintColor: Colors.transparent,
      titleSpacing: 12,
      centerTitle: false,
      leading: IconButton(
        icon: const Icon(Icons.menu, color: AppColors.textPrimary),
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.tr('menuTappedToast', fallback: 'Menu')),
              duration: const Duration(seconds: 1),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const HandshakeLogo(size: 26),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  context.tr('appName'),
                  style: AppTypography.heading(fontSize: 16).copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  context.tr('taglineLine1', fallback: 'हात मिळवा, सेवा वाढवा'),
                  style: AppTypography.poppins(fontSize: 9, color: AppColors.subtitle),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        // Location Badge Chip
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFBFDBFE)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.location_on, size: 13, color: AppColors.primary),
              const SizedBox(width: 3),
              Text(
                data.location,
                style: AppTypography.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),

        // Notification Bell
        Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_none, color: AppColors.textPrimary, size: 22),
              padding: const EdgeInsets.all(6),
              constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(context.tr('noNotifications', fallback: '1 new notification')),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
            Positioned(
              right: 6,
              top: 6,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Text(
                  '1',
                  style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),

        // Profile Avatar Badge
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    societyName.isNotEmpty ? societyName.substring(0, math.min(2, societyName.length)).toUpperCase() : 'SK',
                    style: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 4),
        const LanguageSelectorButton(),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildCommunityMissionPill(BuildContext context, CooperativeDashboardData data) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFA7F3D0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: Color(0xFF10B981),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.groups, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              context.tr(data.communityBadgeKey, fallback: 'Stronger Workers, Brighter Communities'),
              style: AppTypography.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF065F46),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr('cooperativeDashboardTitle', fallback: 'Co-operative Dashboard'),
          style: AppTypography.heading(fontSize: 22).copyWith(
            color: const Color(0xFF0F172A),
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          context.tr('cooperativeDashboardSubtitle', fallback: 'Manage your workforce, assignments and community services'),
          style: AppTypography.subtitle(fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildHeroGreetingBanner(
    BuildContext context,
    AuthProvider auth,
    CooperativeDashboardData data,
  ) {
    final dynamicName = auth.greetingName(context);
    final locale = AppLocaleScope.of(context);
    final formattedDate = AppFormatters.formatDate(DateTime.now(), locale);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEFF6FF), Color(0xFFDBEAFE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFBFDBFE)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(Icons.handshake_outlined, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('greetingDynamicUser', params: {'name': dynamicName}),
                      style: AppTypography.heading(fontSize: 17).copyWith(
                        color: const Color(0xFF1E3A8A),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      context.tr(data.taglineKey, fallback: 'Together we create opportunities.'),
                      style: AppTypography.poppins(
                        fontSize: 12,
                        color: const Color(0xFF3B82F6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFBFDBFE)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, size: 13, color: Color(0xFF475569)),
                  const SizedBox(width: 5),
                  Text(
                    formattedDate,
                    style: AppTypography.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF475569),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF93C5FD)),
                ),
                child: Text(
                  '“${context.tr(data.mottoBadgeKey, fallback: 'सेवा हीच शक्ती')}”',
                  style: AppTypography.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E40AF),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKpiMetricsGrid(BuildContext context, CooperativeKpiData kpi) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 2-column responsive layout for 5 metrics
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                context,
                title: context.tr('totalWorkers', fallback: 'Total Workers'),
                value: '${kpi.totalWorkers}',
                delta: context.tr('thisWeekTrend', params: {'count': '4'}, fallback: kpi.totalWorkersDelta),
                isPositive: true,
                icon: Icons.people_alt,
                color: const Color(0xFF2563EB),
                bgColor: const Color(0xFFEFF6FF),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                context,
                title: context.tr('activeJobs', fallback: 'Active Jobs'),
                value: '${kpi.activeJobs}',
                delta: context.tr('todayTrend', params: {'count': '5'}, fallback: kpi.activeJobsDelta),
                isPositive: true,
                icon: Icons.work,
                color: const Color(0xFF4F46E5),
                bgColor: const Color(0xFFEEF2FF),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                context,
                title: context.tr('pendingRequests', fallback: 'Pending Requests'),
                value: '${kpi.pendingRequests}',
                delta: context.tr('yesterdayTrend', params: {'count': '3'}, fallback: kpi.pendingRequestsDelta),
                isPositive: false,
                icon: Icons.access_time_filled,
                color: const Color(0xFFEF4444),
                bgColor: const Color(0xFFFEF2F2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                context,
                title: context.tr('completedJobs', fallback: 'Completed Jobs'),
                value: '${kpi.completedJobs}',
                delta: context.tr('thisWeekTrend', params: {'count': '18'}, fallback: kpi.completedJobsDelta),
                isPositive: true,
                icon: Icons.check_circle,
                color: const Color(0xFF10B981),
                bgColor: const Color(0xFFECFDF5),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Total Earnings full-width hero card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('₹', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF059669))),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('totalEarnings', fallback: 'Total Earnings'),
                      style: AppTypography.subtitle(fontSize: 12),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      AppFormatters.formatPrice(kpi.totalEarnings, context),
                      style: AppTypography.heading(fontSize: 20).copyWith(
                        color: const Color(0xFF0F172A),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.trending_up, size: 14, color: Color(0xFF059669)),
                    const SizedBox(width: 4),
                    Text(
                      context.tr('thisMonthEarningsTrend', params: {'pct': '17'}, fallback: '+17% this month'),
                      style: AppTypography.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF059669),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    BuildContext context, {
    required String title,
    required String value,
    required String delta,
    required bool isPositive,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: color),
              ),
              Text(
                value,
                style: AppTypography.heading(fontSize: 22).copyWith(
                  color: const Color(0xFF0F172A),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: AppTypography.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF64748B),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                size: 11,
                color: isPositive ? const Color(0xFF10B981) : const Color(0xFFEF4444),
              ),
              const SizedBox(width: 3),
              Expanded(
                child: Text(
                  delta,
                  style: AppTypography.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: isPositive ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildJobRequestsSection(
    BuildContext context,
    List<CooperativeJobRequestModel> requests,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              context.tr('jobRequestsTitle', fallback: 'Job Requests'),
              style: AppTypography.heading(fontSize: 18).copyWith(fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(context.tr('viewAll', fallback: 'All Requests'))),
                );
              },
              child: Text(
                context.tr('viewAll', fallback: 'View All'),
                style: AppTypography.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: requests.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final item = requests[index];
            return _buildJobRequestCard(context, item);
          },
        ),
      ],
    );
  }

  Widget _buildJobRequestCard(BuildContext context, CooperativeJobRequestModel item) {
    final isAssigned = item.status == 'ASSIGNED';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: item.iconBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(item.iconData, color: item.iconColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        context.tr(item.serviceTitleKey, fallback: item.serviceCategory),
                        style: AppTypography.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F172A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: item.priority.backgroundColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        context.tr(item.priority.localizationKey, fallback: item.priority.name),
                        style: AppTypography.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: item.priority.color,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 12, color: Color(0xFF94A3B8)),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        item.area,
                        style: AppTypography.poppins(fontSize: 11, color: const Color(0xFF64748B)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      context.tr(item.timeAgoKey, fallback: '${item.timeAgoMins} min ago'),
                      style: AppTypography.poppins(fontSize: 10, color: const Color(0xFF94A3B8)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: isAssigned ? null : () => _showAssignWorkerSheet(context, item),
            style: ElevatedButton.styleFrom(
              backgroundColor: isAssigned ? const Color(0xFF94A3B8) : AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              minimumSize: const Size(64, 34),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              isAssigned ? context.tr('assignedStatus', fallback: 'Assigned') : context.tr('assignJobBtn', fallback: 'Assign'),
              style: AppTypography.poppins(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showAssignWorkerSheet(BuildContext context, CooperativeJobRequestModel item) {
    final provider = context.read<CooperativeDashboardProvider>();
    provider.fetchAvailableWorkers(trade: item.serviceCategory);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final workers = provider.availableWorkers;
            final isLoading = provider.isLoadingWorkers;

            return Padding(
              padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(bottomSheetContext).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    context.tr('assignWorkerTitle', fallback: 'Assign Worker to Job'),
                    style: AppTypography.heading(fontSize: 18),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${context.tr(item.serviceTitleKey, fallback: item.serviceCategory)} • ${item.area}',
                    style: AppTypography.subtitle(fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    context.tr('availableWorkersLabel', fallback: 'Available Workers'),
                    style: AppTypography.poppins(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  if (isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: CircularProgressIndicator(color: AppColors.primary),
                      ),
                    )
                  else if (workers.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        context.tr('noWorkersFound', fallback: 'No workers available for this trade'),
                        style: AppTypography.poppins(fontSize: 13, color: Colors.grey),
                      ),
                    )
                  else
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 280),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: workers.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (c, idx) {
                          final w = workers[idx];
                          final wId = w['id'] as int? ?? 1;
                          final wName = w['name'] as String? ?? 'Worker';
                          final wRating = w['rating'] as num? ?? 4.8;
                          final wTrade = w['trade'] as String? ?? 'Technician';

                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(vertical: 4),
                            leading: CircleAvatar(
                              backgroundColor: const Color(0xFFEFF6FF),
                              child: Text(wName.isNotEmpty ? wName[0] : 'W', style: const TextStyle(color: AppColors.primary)),
                            ),
                            title: Text(wName, style: AppTypography.poppins(fontWeight: FontWeight.w600)),
                            subtitle: Text('$wTrade • ⭐ $wRating', style: AppTypography.subtitle(fontSize: 12)),
                            trailing: ElevatedButton(
                              onPressed: () async {
                                Navigator.pop(bottomSheetContext);
                                final success = await provider.assignWorker(
                                  requestId: item.id,
                                  workerId: wId,
                                  workerName: wName,
                                );
                                if (context.mounted && success) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(context.tr('workerAssignedSuccess', fallback: 'Worker assigned successfully!')),
                                      backgroundColor: const Color(0xFF059669),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: Text(context.tr('assignJobBtn', fallback: 'Assign')),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAnalyticsSection(
    BuildContext context,
    CooperativeDashboardProvider provider,
    CooperativeDashboardData data,
  ) {
    final selectedTab = provider.selectedAnalyticsTab;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Segmented Tabs
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => provider.setSelectedAnalyticsTab(0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: selectedTab == 0 ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: selectedTab == 0
                            ? [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                )
                              ]
                            : null,
                      ),
                      child: Text(
                        context.tr('serviceDemandTitle', fallback: 'Service Demand'),
                        textAlign: TextAlign.center,
                        style: AppTypography.poppins(
                          fontSize: 12,
                          fontWeight: selectedTab == 0 ? FontWeight.w700 : FontWeight.w500,
                          color: selectedTab == 0 ? AppColors.primary : const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => provider.setSelectedAnalyticsTab(1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: selectedTab == 1 ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: selectedTab == 1
                            ? [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                )
                              ]
                            : null,
                      ),
                      child: Text(
                        context.tr('workerAvailabilityTitle', fallback: 'Worker Availability'),
                        textAlign: TextAlign.center,
                        style: AppTypography.poppins(
                          fontSize: 12,
                          fontWeight: selectedTab == 1 ? FontWeight.w700 : FontWeight.w500,
                          color: selectedTab == 1 ? AppColors.primary : const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Render Chart
          if (selectedTab == 0)
            _buildServiceDemandChart(context, data.serviceDemand)
          else
            _buildWorkerAvailabilityChart(context, data.workerAvailability),
        ],
      ),
    );
  }

  Widget _buildServiceDemandChart(
    BuildContext context,
    ServiceDemandAnalyticsModel model,
  ) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 140,
              height: 140,
              child: CustomPaint(
                painter: _DonutChartPainter(
                  slices: model.breakdown.map((e) => _ChartSlice(e.percentage.toDouble(), e.color)).toList(),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${model.totalRequests}',
                        style: AppTypography.heading(fontSize: 22).copyWith(
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        context.tr('totalRequestsLabel', fallback: 'Total Requests'),
                        style: AppTypography.poppins(fontSize: 9, color: const Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Legend Chips Wrap
        Wrap(
          spacing: 12,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: model.breakdown.map((slice) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(color: slice.color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 5),
                Text(
                  '${context.tr(slice.categoryKey)} ${slice.percentage}%',
                  style: AppTypography.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF334155),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildWorkerAvailabilityChart(
    BuildContext context,
    WorkerAvailabilityAnalyticsModel model,
  ) {
    final breakdown = model.breakdown;
    final total = model.totalWorkers;

    final slices = [
      _ChartSlice(breakdown.available.toDouble(), const Color(0xFF10B981)),
      _ChartSlice(breakdown.onJob.toDouble(), const Color(0xFF2563EB)),
      _ChartSlice(breakdown.onLeave.toDouble(), const Color(0xFFF59E0B)),
      _ChartSlice(breakdown.unavailable.toDouble(), const Color(0xFFEF4444)),
    ];

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 140,
              height: 140,
              child: CustomPaint(
                painter: _DonutChartPainter(slices: slices),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$total',
                        style: AppTypography.heading(fontSize: 22).copyWith(
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        context.tr('totalWorkers', fallback: 'Total Workers'),
                        style: AppTypography.poppins(fontSize: 9, color: const Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 14,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            _legendItem(const Color(0xFF10B981), '${breakdown.available} ${context.tr('availableCount', fallback: 'Available')}'),
            _legendItem(const Color(0xFF2563EB), '${breakdown.onJob} ${context.tr('onJobCount', fallback: 'On Job')}'),
            _legendItem(const Color(0xFFF59E0B), '${breakdown.onLeave} ${context.tr('onLeaveCount', fallback: 'On Leave')}'),
            _legendItem(const Color(0xFFEF4444), '${breakdown.unavailable} ${context.tr('unavailableCount', fallback: 'Unavailable')}'),
          ],
        ),
      ],
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: AppTypography.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF334155),
          ),
        ),
      ],
    );
  }

  Widget _buildEarningsOverviewCard(
    BuildContext context,
    CooperativeDashboardProvider provider,
    EarningsOverviewModel earnings,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.tr('earningsOverviewTitle', fallback: 'Earnings Overview'),
                style: AppTypography.heading(fontSize: 16).copyWith(fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Text(
                      context.tr(earnings.filterPeriodKey, fallback: 'This Month'),
                      style: AppTypography.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF334155)),
                    ),
                    const Icon(Icons.arrow_drop_down, size: 16, color: Color(0xFF64748B)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                AppFormatters.formatPrice(earnings.totalEarnings, context),
                style: AppTypography.heading(fontSize: 24).copyWith(
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.arrow_upward, size: 10, color: Color(0xFF059669)),
                    const SizedBox(width: 2),
                    Text(
                      earnings.growthPercentage,
                      style: AppTypography.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF059669)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Text(
            context.tr(earnings.subtitleKey, fallback: 'Total Earnings (Platform + Direct)'),
            style: AppTypography.subtitle(fontSize: 11),
          ),
          const SizedBox(height: 20),

          // Weekly Bar Chart
          SizedBox(
            height: 110,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: earnings.weeklyBreakdown.map((item) {
                const maxAmount = 80000.0;
                final heightFactor = (item.amount / maxAmount).clamp(0.15, 1.0);

                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 32,
                      height: 80 * heightFactor,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.weekLabel,
                      style: AppTypography.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF64748B)),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentAssignmentsSection(
    BuildContext context,
    List<RecentAssignmentModel> assignments,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              context.tr('recentAssignmentsTitle', fallback: 'Recent Assignments'),
              style: AppTypography.heading(fontSize: 18).copyWith(fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(context.tr('viewAll', fallback: 'View All'))),
                );
              },
              child: Text(
                context.tr('viewAll', fallback: 'View All'),
                style: AppTypography.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: assignments.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final item = assignments[index];
            final timeLabel = item.assignedAtKey != null
                ? context.tr(item.assignedAtKey!, fallback: item.assignedAt)
                : item.assignedAt;

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundImage: NetworkImage(item.workerAvatar),
                    backgroundColor: const Color(0xFFDBEAFE),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.workerName,
                          style: AppTypography.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${context.tr(item.jobTypeKey)} • ${item.location}',
                          style: AppTypography.subtitle(fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: item.status.backgroundColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          context.tr(item.status.localizationKey, fallback: item.status.name),
                          style: AppTypography.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: item.status.color,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        timeLabel,
                        style: AppTypography.poppins(fontSize: 10, color: const Color(0xFF94A3B8)),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildMembersAndUpcomingSection(
    BuildContext context,
    CooperativeDashboardData data,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Co-operative Committee Members Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.tr('cooperativeMembersTitle', fallback: 'Co-operative Members'),
                    style: AppTypography.heading(fontSize: 16).copyWith(fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(padding: EdgeInsets.zero),
                    child: Text(
                      context.tr('viewAll', fallback: 'View All'),
                      style: AppTypography.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...data.cooperativeMembers.map((member) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: const Color(0xFFEFF6FF),
                        child: const Icon(Icons.person, size: 18, color: AppColors.primary),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              member.name,
                              style: AppTypography.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF0F172A)),
                            ),
                            Text(
                              context.tr(member.roleKey, fallback: member.roleTitle),
                              style: AppTypography.subtitle(fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          context.tr('activeBadge', fallback: 'Active'),
                          style: AppTypography.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF059669)),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Upcoming Scheduled Jobs Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.tr('upcomingJobsTitle', fallback: 'Upcoming Jobs'),
                    style: AppTypography.heading(fontSize: 16).copyWith(fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(padding: EdgeInsets.zero),
                    child: Text(
                      context.tr('viewAll', fallback: 'View All'),
                      style: AppTypography.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...data.upcomingJobs.map((job) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFBFDBFE)),
                        ),
                        child: Column(
                          children: [
                            Text(
                              job.dateDay,
                              style: AppTypography.poppins(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.primary),
                            ),
                            Text(
                              job.dateMonth,
                              style: AppTypography.poppins(fontSize: 9, fontWeight: FontWeight.w600, color: const Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.tr(job.serviceTitleKey),
                              style: AppTypography.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF0F172A)),
                            ),
                            Text(
                              job.location,
                              style: AppTypography.subtitle(fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        job.time,
                        style: AppTypography.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF475569)),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionsSection(
    BuildContext context,
    List<QuickActionModel> actions,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr('quickActionsTitle', fallback: 'Quick Actions'),
          style: AppTypography.heading(fontSize: 18).copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: actions.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.6,
          ),
          itemBuilder: (context, index) {
            final action = actions[index];
            return Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(context.tr(action.titleKey)),
                      duration: const Duration(milliseconds: 1200),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(action.iconData, size: 26, color: AppColors.primary),
                      const SizedBox(height: 8),
                      Text(
                        context.tr(action.titleKey),
                        textAlign: TextAlign.center,
                        style: AppTypography.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1E293B),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildFooterCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const HandshakeLogo(size: 20),
              const SizedBox(width: 8),
              Text(
                context.tr('brandName', fallback: 'SahayogSeva'),
                style: AppTypography.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '“${context.tr('footerEmpoweringMotto', fallback: 'स्थानिक कौशल, समृद्ध समाज')}”',
            textAlign: TextAlign.center,
            style: AppTypography.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            context.tr('footerCooperativeStep', fallback: 'A Cooperative Step Towards a Better Tomorrow'),
            textAlign: TextAlign.center,
            style: AppTypography.subtitle(fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildPersistentBottomNav(
    BuildContext context,
    CooperativeDashboardProvider provider,
  ) {
    final currentTab = provider.selectedTab;

    return BottomNavigationBar(
      currentIndex: currentTab.index,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: const Color(0xFF94A3B8),
      selectedLabelStyle: AppTypography.poppins(fontSize: 11, fontWeight: FontWeight.bold),
      unselectedLabelStyle: AppTypography.poppins(fontSize: 11),
      elevation: 10,
      onTap: (index) {
        final newTab = CooperativeTab.values[index];
        provider.setSelectedTab(newTab);
        if (newTab != CooperativeTab.dashboard) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.tr(newTab.labelKey)),
              duration: const Duration(milliseconds: 1000),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      items: CooperativeTab.values.map((tab) {
        return BottomNavigationBarItem(
          icon: Icon(currentTab == tab ? tab.activeIcon : tab.icon),
          label: context.tr(tab.labelKey),
        );
      }).toList(),
    );
  }
}

class _ChartSlice {
  final double value;
  final Color color;

  const _ChartSlice(this.value, this.color);
}

class _DonutChartPainter extends CustomPainter {
  final List<_ChartSlice> slices;

  _DonutChartPainter({required this.slices});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    const strokeWidth = 18.0;

    final total = slices.fold<double>(0, (sum, item) => sum + item.value);
    if (total == 0) return;

    double startAngle = -math.pi / 2;

    for (final slice in slices) {
      final sweepAngle = (slice.value / total) * 2 * math.pi;
      final paint = Paint()
        ..color = slice.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - (strokeWidth / 2)),
        startAngle,
        sweepAngle,
        false,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) => true;
}
