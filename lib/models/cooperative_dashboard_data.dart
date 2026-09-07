import 'package:flutter/material.dart';

enum CooperativeJobPriority {
  urgent,
  normal,
  low;

  static CooperativeJobPriority fromString(String? val) {
    switch (val?.toUpperCase()) {
      case 'URGENT':
        return CooperativeJobPriority.urgent;
      case 'LOW':
        return CooperativeJobPriority.low;
      case 'NORMAL':
      default:
        return CooperativeJobPriority.normal;
    }
  }

  Color get color {
    switch (this) {
      case CooperativeJobPriority.urgent:
        return const Color(0xFFEF4444);
      case CooperativeJobPriority.normal:
        return const Color(0xFF10B981);
      case CooperativeJobPriority.low:
        return const Color(0xFF6B7280);
    }
  }

  Color get backgroundColor {
    switch (this) {
      case CooperativeJobPriority.urgent:
        return const Color(0xFFFEE2E2);
      case CooperativeJobPriority.normal:
        return const Color(0xFFD1FAE5);
      case CooperativeJobPriority.low:
        return const Color(0xFFF3F4F6);
    }
  }

  String get localizationKey {
    switch (this) {
      case CooperativeJobPriority.urgent:
        return 'urgentPriority';
      case CooperativeJobPriority.normal:
        return 'normalPriority';
      case CooperativeJobPriority.low:
        return 'lowPriority';
    }
  }
}

enum CooperativeAssignmentStatus {
  assigned,
  inProgress,
  completed;

  static CooperativeAssignmentStatus fromString(String? val) {
    switch (val?.toUpperCase()) {
      case 'IN_PROGRESS':
        return CooperativeAssignmentStatus.inProgress;
      case 'COMPLETED':
        return CooperativeAssignmentStatus.completed;
      case 'ASSIGNED':
      default:
        return CooperativeAssignmentStatus.assigned;
    }
  }

  Color get color {
    switch (this) {
      case CooperativeAssignmentStatus.assigned:
        return const Color(0xFF2563EB);
      case CooperativeAssignmentStatus.inProgress:
        return const Color(0xFFD97706);
      case CooperativeAssignmentStatus.completed:
        return const Color(0xFF059669);
    }
  }

  Color get backgroundColor {
    switch (this) {
      case CooperativeAssignmentStatus.assigned:
        return const Color(0xFFDBEAFE);
      case CooperativeAssignmentStatus.inProgress:
        return const Color(0xFFFEF3C7);
      case CooperativeAssignmentStatus.completed:
        return const Color(0xFFD1FAE5);
    }
  }

  String get localizationKey {
    switch (this) {
      case CooperativeAssignmentStatus.assigned:
        return 'assignedStatus';
      case CooperativeAssignmentStatus.inProgress:
        return 'inProgressStatus';
      case CooperativeAssignmentStatus.completed:
        return 'completedStatus';
    }
  }
}

enum CooperativeTab {
  dashboard,
  requests,
  workforce,
  earnings,
  settings;

  String get labelKey {
    switch (this) {
      case CooperativeTab.dashboard:
        return 'navDashboard';
      case CooperativeTab.requests:
        return 'navRequests';
      case CooperativeTab.workforce:
        return 'navWorkforce';
      case CooperativeTab.earnings:
        return 'navEarnings';
      case CooperativeTab.settings:
        return 'navSettings';
    }
  }

  IconData get icon {
    switch (this) {
      case CooperativeTab.dashboard:
        return Icons.dashboard_outlined;
      case CooperativeTab.requests:
        return Icons.assignment_outlined;
      case CooperativeTab.workforce:
        return Icons.people_alt_outlined;
      case CooperativeTab.earnings:
        return Icons.account_balance_wallet_outlined;
      case CooperativeTab.settings:
        return Icons.settings_outlined;
    }
  }

  IconData get activeIcon {
    switch (this) {
      case CooperativeTab.dashboard:
        return Icons.dashboard;
      case CooperativeTab.requests:
        return Icons.assignment;
      case CooperativeTab.workforce:
        return Icons.people_alt;
      case CooperativeTab.earnings:
        return Icons.account_balance_wallet;
      case CooperativeTab.settings:
        return Icons.settings;
    }
  }
}

class CooperativeKpiData {
  final int totalWorkers;
  final String totalWorkersDelta;
  final int activeJobs;
  final String activeJobsDelta;
  final int pendingRequests;
  final String pendingRequestsDelta;
  final int completedJobs;
  final String completedJobsDelta;
  final int totalEarnings;
  final String totalEarningsDelta;

  const CooperativeKpiData({
    this.totalWorkers = 48,
    this.totalWorkersDelta = '+4 this week',
    this.activeJobs = 18,
    this.activeJobsDelta = '+5 today',
    this.pendingRequests = 12,
    this.pendingRequestsDelta = '-3 from yesterday',
    this.completedJobs = 96,
    this.completedJobsDelta = '+18 this week',
    this.totalEarnings = 248000,
    this.totalEarningsDelta = '+17% this month',
  });

  factory CooperativeKpiData.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const CooperativeKpiData();
    return CooperativeKpiData(
      totalWorkers: json['total_workers'] as int? ?? 48,
      totalWorkersDelta: json['total_workers_delta'] as String? ?? '+4 this week',
      activeJobs: json['active_jobs'] as int? ?? 18,
      activeJobsDelta: json['active_jobs_delta'] as String? ?? '+5 today',
      pendingRequests: json['pending_requests'] as int? ?? 12,
      pendingRequestsDelta: json['pending_requests_delta'] as String? ?? '-3 from yesterday',
      completedJobs: json['completed_jobs'] as int? ?? 96,
      completedJobsDelta: json['completed_jobs_delta'] as String? ?? '+18 this week',
      totalEarnings: json['total_earnings'] as int? ?? 248000,
      totalEarningsDelta: json['total_earnings_delta'] as String? ?? '+17% this month',
    );
  }
}

class CooperativeJobRequestModel {
  final String id;
  final String serviceTitleKey;
  final String serviceCategory;
  final String area;
  final String timeAgoKey;
  final int timeAgoMins;
  final CooperativeJobPriority priority;
  final String status;
  final String iconName;
  final int estimatedPriceMin;
  final int estimatedPriceMax;
  final String customerName;
  final String customerPhone;

  const CooperativeJobRequestModel({
    required this.id,
    required this.serviceTitleKey,
    required this.serviceCategory,
    required this.area,
    required this.timeAgoKey,
    required this.timeAgoMins,
    required this.priority,
    required this.status,
    required this.iconName,
    required this.estimatedPriceMin,
    required this.estimatedPriceMax,
    required this.customerName,
    required this.customerPhone,
  });

  factory CooperativeJobRequestModel.fromJson(Map<String, dynamic> json) {
    return CooperativeJobRequestModel(
      id: json['id'] as String? ?? '',
      serviceTitleKey: json['service_title_key'] as String? ?? 'servicePlumber',
      serviceCategory: json['service_category'] as String? ?? 'Plumbing Work',
      area: json['area'] as String? ?? 'Pune',
      timeAgoKey: json['time_ago_key'] as String? ?? 'timeAgo10Mins',
      timeAgoMins: json['time_ago_mins'] as int? ?? 10,
      priority: CooperativeJobPriority.fromString(json['priority'] as String?),
      status: json['status'] as String? ?? 'PENDING',
      iconName: json['icon_name'] as String? ?? 'plumbing',
      estimatedPriceMin: json['estimated_price_min'] as int? ?? 300,
      estimatedPriceMax: json['estimated_price_max'] as int? ?? 600,
      customerName: json['customer_name'] as String? ?? '',
      customerPhone: json['customer_phone'] as String? ?? '',
    );
  }

  IconData get iconData {
    switch (iconName) {
      case 'electric_bolt':
        return Icons.bolt;
      case 'ac_unit':
        return Icons.ac_unit;
      case 'cleaning_services':
        return Icons.cleaning_services;
      case 'carpenter':
        return Icons.handyman;
      case 'plumbing':
      default:
        return Icons.plumbing;
    }
  }

  Color get iconColor {
    switch (iconName) {
      case 'electric_bolt':
        return const Color(0xFFF59E0B);
      case 'ac_unit':
        return const Color(0xFF06B6D4);
      case 'cleaning_services':
        return const Color(0xFF10B981);
      case 'carpenter':
        return const Color(0xFFB45309);
      case 'plumbing':
      default:
        return const Color(0xFFEF4444);
    }
  }

  Color get iconBgColor {
    switch (iconName) {
      case 'electric_bolt':
        return const Color(0xFFFEF3C7);
      case 'ac_unit':
        return const Color(0xFFE0F2FE);
      case 'cleaning_services':
        return const Color(0xFFD1FAE5);
      case 'carpenter':
        return const Color(0xFFFDE68A);
      case 'plumbing':
      default:
        return const Color(0xFFFEE2E2);
    }
  }
}

class ServiceDemandSlice {
  final String categoryKey;
  final int percentage;
  final Color color;

  const ServiceDemandSlice({
    required this.categoryKey,
    required this.percentage,
    required this.color,
  });

  factory ServiceDemandSlice.fromJson(Map<String, dynamic> json) {
    Color parsedColor = const Color(0xFF2563EB);
    final hex = json['color_hex'] as String?;
    if (hex != null && hex.startsWith('#')) {
      final buffer = StringBuffer();
      if (hex.length == 7) buffer.write('ff');
      buffer.write(hex.replaceFirst('#', ''));
      parsedColor = Color(int.parse(buffer.toString(), radix: 16));
    }
    return ServiceDemandSlice(
      categoryKey: json['category_key'] as String? ?? 'servicePlumbing',
      percentage: json['percentage'] as int? ?? 10,
      color: parsedColor,
    );
  }
}

class ServiceDemandAnalyticsModel {
  final int totalRequests;
  final List<ServiceDemandSlice> breakdown;

  const ServiceDemandAnalyticsModel({
    this.totalRequests = 128,
    this.breakdown = const [],
  });

  factory ServiceDemandAnalyticsModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const ServiceDemandAnalyticsModel();
    final rawList = json['breakdown'] as List? ?? [];
    return ServiceDemandAnalyticsModel(
      totalRequests: json['total_requests'] as int? ?? 128,
      breakdown: rawList.map((e) => ServiceDemandSlice.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}

class WorkerAvailabilityBreakdownModel {
  final int available;
  final int onJob;
  final int onLeave;
  final int unavailable;

  const WorkerAvailabilityBreakdownModel({
    this.available = 32,
    this.onJob = 10,
    this.onLeave = 4,
    this.unavailable = 2,
  });

  factory WorkerAvailabilityBreakdownModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const WorkerAvailabilityBreakdownModel();
    return WorkerAvailabilityBreakdownModel(
      available: json['available'] as int? ?? 32,
      onJob: json['on_job'] as int? ?? 10,
      onLeave: json['on_leave'] as int? ?? 4,
      unavailable: json['unavailable'] as int? ?? 2,
    );
  }
}

class WorkerAvailabilityAnalyticsModel {
  final int totalWorkers;
  final WorkerAvailabilityBreakdownModel breakdown;

  const WorkerAvailabilityAnalyticsModel({
    this.totalWorkers = 48,
    this.breakdown = const WorkerAvailabilityBreakdownModel(),
  });

  factory WorkerAvailabilityAnalyticsModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const WorkerAvailabilityAnalyticsModel();
    return WorkerAvailabilityAnalyticsModel(
      totalWorkers: json['total_workers'] as int? ?? 48,
      breakdown: WorkerAvailabilityBreakdownModel.fromJson(json['breakdown'] as Map<String, dynamic>?),
    );
  }
}

class WeeklyEarningsItem {
  final String weekLabel;
  final int amount;

  const WeeklyEarningsItem({required this.weekLabel, required this.amount});

  factory WeeklyEarningsItem.fromJson(Map<String, dynamic> json) {
    return WeeklyEarningsItem(
      weekLabel: json['week_label'] as String? ?? 'W1',
      amount: json['amount'] as int? ?? 0,
    );
  }
}

class EarningsOverviewModel {
  final int totalEarnings;
  final String growthPercentage;
  final String filterPeriodKey;
  final String subtitleKey;
  final List<WeeklyEarningsItem> weeklyBreakdown;

  const EarningsOverviewModel({
    this.totalEarnings = 248000,
    this.growthPercentage = '+12%',
    this.filterPeriodKey = 'thisMonth',
    this.subtitleKey = 'platformDirectEarnings',
    this.weeklyBreakdown = const [],
  });

  factory EarningsOverviewModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const EarningsOverviewModel();
    final rawList = json['weekly_breakdown'] as List? ?? [];
    return EarningsOverviewModel(
      totalEarnings: json['total_earnings'] as int? ?? 248000,
      growthPercentage: json['growth_percentage'] as String? ?? '+12%',
      filterPeriodKey: json['filter_period_key'] as String? ?? 'thisMonth',
      subtitleKey: json['subtitle_key'] as String? ?? 'platformDirectEarnings',
      weeklyBreakdown: rawList.map((e) => WeeklyEarningsItem.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}

class RecentAssignmentModel {
  final String id;
  final String workerName;
  final String workerAvatar;
  final String jobTypeKey;
  final String location;
  final CooperativeAssignmentStatus status;
  final String assignedAt;
  final String? assignedAtKey;

  const RecentAssignmentModel({
    required this.id,
    required this.workerName,
    required this.workerAvatar,
    required this.jobTypeKey,
    required this.location,
    required this.status,
    required this.assignedAt,
    this.assignedAtKey,
  });

  factory RecentAssignmentModel.fromJson(Map<String, dynamic> json) {
    return RecentAssignmentModel(
      id: json['id'] as String? ?? '',
      workerName: json['worker_name'] as String? ?? '',
      workerAvatar: json['worker_avatar'] as String? ?? '',
      jobTypeKey: json['job_type_key'] as String? ?? 'servicePlumbing',
      location: json['location'] as String? ?? '',
      status: CooperativeAssignmentStatus.fromString(json['status'] as String?),
      assignedAt: json['assigned_at'] as String? ?? '',
      assignedAtKey: json['assigned_at_key'] as String?,
    );
  }
}

class CooperativeMemberModel {
  final String id;
  final String name;
  final String roleKey;
  final String roleTitle;
  final String status;
  final String? avatarUrl;

  const CooperativeMemberModel({
    required this.id,
    required this.name,
    required this.roleKey,
    required this.roleTitle,
    required this.status,
    this.avatarUrl,
  });

  factory CooperativeMemberModel.fromJson(Map<String, dynamic> json) {
    return CooperativeMemberModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      roleKey: json['role_key'] as String? ?? 'roleMember',
      roleTitle: json['role_title'] as String? ?? 'Member',
      status: json['status'] as String? ?? 'ACTIVE',
      avatarUrl: json['avatar_url'] as String?,
    );
  }
}

class UpcomingJobModel {
  final String id;
  final String dateDay;
  final String dateMonth;
  final String serviceTitleKey;
  final String location;
  final String time;
  final String status;

  const UpcomingJobModel({
    required this.id,
    required this.dateDay,
    required this.dateMonth,
    required this.serviceTitleKey,
    required this.location,
    required this.time,
    required this.status,
  });

  factory UpcomingJobModel.fromJson(Map<String, dynamic> json) {
    return UpcomingJobModel(
      id: json['id'] as String? ?? '',
      dateDay: json['date_day'] as String? ?? '01',
      dateMonth: json['date_month'] as String? ?? 'Jan',
      serviceTitleKey: json['service_title_key'] as String? ?? 'servicePlumber',
      location: json['location'] as String? ?? '',
      time: json['time'] as String? ?? '',
      status: json['status'] as String? ?? 'SCHEDULED',
    );
  }
}

class QuickActionModel {
  final String id;
  final String titleKey;
  final String iconName;
  final String actionType;

  const QuickActionModel({
    required this.id,
    required this.titleKey,
    required this.iconName,
    required this.actionType,
  });

  factory QuickActionModel.fromJson(Map<String, dynamic> json) {
    return QuickActionModel(
      id: json['id'] as String? ?? '',
      titleKey: json['title_key'] as String? ?? '',
      iconName: json['icon_name'] as String? ?? 'settings',
      actionType: json['action_type'] as String? ?? '',
    );
  }

  IconData get iconData {
    switch (iconName) {
      case 'group_add':
        return Icons.group_add_outlined;
      case 'location_on':
        return Icons.location_on_outlined;
      case 'description':
        return Icons.description_outlined;
      case 'campaign':
        return Icons.campaign_outlined;
      default:
        return Icons.touch_app_outlined;
    }
  }
}

class CooperativeDashboardData {
  final int societyId;
  final String societyName;
  final String societyNameMr;
  final String location;
  final String taglineKey;
  final String communityBadgeKey;
  final String mottoBadgeKey;
  final int notificationsCount;
  final CooperativeKpiData kpiMetrics;
  final List<CooperativeJobRequestModel> jobRequests;
  final ServiceDemandAnalyticsModel serviceDemand;
  final WorkerAvailabilityAnalyticsModel workerAvailability;
  final EarningsOverviewModel earningsOverview;
  final List<RecentAssignmentModel> recentAssignments;
  final List<CooperativeMemberModel> cooperativeMembers;
  final List<UpcomingJobModel> upcomingJobs;
  final List<QuickActionModel> quickActions;

  const CooperativeDashboardData({
    this.societyId = 1,
    this.societyName = 'Shivneri Seva Co-operative',
    this.societyNameMr = 'शिवनेरी सेवा सहकारी संस्था',
    this.location = 'Pune, Maharashtra',
    this.taglineKey = 'heroOpportunitiesTagline',
    this.communityBadgeKey = 'communityPillMotto',
    this.mottoBadgeKey = 'cooperativeMottoBadge',
    this.notificationsCount = 1,
    this.kpiMetrics = const CooperativeKpiData(),
    this.jobRequests = const [],
    this.serviceDemand = const ServiceDemandAnalyticsModel(),
    this.workerAvailability = const WorkerAvailabilityAnalyticsModel(),
    this.earningsOverview = const EarningsOverviewModel(),
    this.recentAssignments = const [],
    this.cooperativeMembers = const [],
    this.upcomingJobs = const [],
    this.quickActions = const [],
  });

  factory CooperativeDashboardData.fromJson(Map<String, dynamic> json) {
    return CooperativeDashboardData(
      societyId: json['society_id'] as int? ?? 1,
      societyName: json['society_name'] as String? ?? 'Shivneri Seva Co-operative',
      societyNameMr: json['society_name_mr'] as String? ?? 'शिवनेरी सेवा सहकारी संस्था',
      location: json['location'] as String? ?? 'Pune, Maharashtra',
      taglineKey: json['tagline_key'] as String? ?? 'heroOpportunitiesTagline',
      communityBadgeKey: json['community_badge_key'] as String? ?? 'communityPillMotto',
      mottoBadgeKey: json['motto_badge_key'] as String? ?? 'cooperativeMottoBadge',
      notificationsCount: json['notifications_count'] as int? ?? 1,
      kpiMetrics: CooperativeKpiData.fromJson(json['kpi_metrics'] as Map<String, dynamic>?),
      jobRequests: (json['job_requests'] as List? ?? [])
          .map((e) => CooperativeJobRequestModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      serviceDemand: ServiceDemandAnalyticsModel.fromJson(json['service_demand'] as Map<String, dynamic>?),
      workerAvailability: WorkerAvailabilityAnalyticsModel.fromJson(json['worker_availability'] as Map<String, dynamic>?),
      earningsOverview: EarningsOverviewModel.fromJson(json['earnings_overview'] as Map<String, dynamic>?),
      recentAssignments: (json['recent_assignments'] as List? ?? [])
          .map((e) => RecentAssignmentModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      cooperativeMembers: (json['cooperative_members'] as List? ?? [])
          .map((e) => CooperativeMemberModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      upcomingJobs: (json['upcoming_jobs'] as List? ?? [])
          .map((e) => UpcomingJobModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      quickActions: (json['quick_actions'] as List? ?? [])
          .map((e) => QuickActionModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
