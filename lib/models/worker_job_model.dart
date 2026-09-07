import 'package:flutter/material.dart';

enum JobPriority {
  low,
  medium,
  high,
  urgent;

  String get key {
    switch (this) {
      case JobPriority.low:
        return 'priorityLow';
      case JobPriority.medium:
        return 'priorityMedium';
      case JobPriority.high:
        return 'priorityHigh';
      case JobPriority.urgent:
        return 'priorityUrgent';
    }
  }

  Color get color {
    switch (this) {
      case JobPriority.low:
        return const Color(0xFF2E7D32);
      case JobPriority.medium:
        return const Color(0xFFF57C00);
      case JobPriority.high:
      case JobPriority.urgent:
        return const Color(0xFFD32F2F);
    }
  }

  Color get backgroundColor {
    switch (this) {
      case JobPriority.low:
        return const Color(0xFFE8F5E9);
      case JobPriority.medium:
        return const Color(0xFFFFF3E0);
      case JobPriority.high:
      case JobPriority.urgent:
        return const Color(0xFFFFEBEE);
    }
  }
}

enum JobRequestState {
  normal,
  expiring,
  expired,
  acceptedByOther,
  youAccepted,
  youRejected;

  bool get isActionable =>
      this == JobRequestState.normal || this == JobRequestState.expiring;
}

enum WorkerJobLifecycleState {
  newRequest,
  accepted,
  navigating,
  arrivedOtp,
  inProgress,
  completed,
  rejected;

  static WorkerJobLifecycleState fromApi(String value) {
    switch (value) {
      case 'ACCEPTED':
        return accepted;
      case 'NAVIGATING':
        return navigating;
      case 'ARRIVED_OTP':
        return arrivedOtp;
      case 'IN_PROGRESS':
        return inProgress;
      case 'COMPLETED':
        return completed;
      case 'REJECTED':
        return rejected;
      default:
        return newRequest;
    }
  }

  String get apiValue {
    switch (this) {
      case newRequest:
        return 'PENDING';
      case accepted:
        return 'ACCEPTED';
      case navigating:
        return 'NAVIGATING';
      case arrivedOtp:
        return 'ARRIVED_OTP';
      case inProgress:
        return 'IN_PROGRESS';
      case completed:
        return 'COMPLETED';
      case rejected:
        return 'REJECTED';
    }
  }
}

class JobCustomerInfo {
  final String id;
  final String name;
  final String nameKey;
  final String avatarUrl;
  final double rating;
  final int reviewsCount;
  final String phone;
  final bool isVerified;
  final int totalBookings;
  final int completedBookings;
  final int cancelledBookings;
  final String memberDurationKey;

  const JobCustomerInfo({
    required this.id,
    required this.name,
    required this.nameKey,
    required this.avatarUrl,
    required this.rating,
    required this.reviewsCount,
    required this.phone,
    this.isVerified = true,
    this.totalBookings = 12,
    this.completedBookings = 10,
    this.cancelledBookings = 1,
    this.memberDurationKey = 'memberTwoMonthsAgo',
  });

  static const sample = JobCustomerInfo(
    id: 'CUST-9842',
    name: 'Sandeep Patil',
    nameKey: 'customerSandeepPatil',
    avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d',
    rating: 4.7,
    reviewsCount: 84,
    phone: '+91 98765 43210',
    isVerified: true,
    totalBookings: 12,
    completedBookings: 10,
    cancelledBookings: 1,
    memberDurationKey: 'memberTwoMonthsAgo',
  );

  factory JobCustomerInfo.fromJson(Map<String, dynamic> json) {
    return JobCustomerInfo(
      id: json['id'] as String,
      name: json['name'] as String,
      nameKey: json['name_key'] as String,
      avatarUrl: json['avatar_url'] as String,
      rating: (json['rating'] as num).toDouble(),
      reviewsCount: json['reviews_count'] as int,
      phone: json['phone'] as String,
      isVerified: json['is_verified'] as bool? ?? true,
      totalBookings: json['total_bookings'] as int? ?? 0,
      completedBookings: json['completed_bookings'] as int? ?? 0,
      cancelledBookings: json['cancelled_bookings'] as int? ?? 0,
      memberDurationKey: json['membership_duration_key'] as String? ?? 'memberTwoMonthsAgo',
    );
  }
}

class JobScopeItem {
  final String id;
  final String titleKey;
  final bool isDone;

  const JobScopeItem({
    required this.id,
    required this.titleKey,
    this.isDone = false,
  });

  factory JobScopeItem.fromJson(Map<String, dynamic> json) => JobScopeItem(
        id: json['id'] as String,
        titleKey: json['title_key'] as String,
        isDone: json['is_done'] as bool? ?? false,
      );
}

class JobToolItem {
  final String id;
  final String nameKey;
  final IconData icon;

  const JobToolItem({
    required this.id,
    required this.nameKey,
    required this.icon,
  });

  factory JobToolItem.fromJson(Map<String, dynamic> json) => JobToolItem(
        id: json['id'] as String,
        nameKey: json['name_key'] as String,
        icon: Icons.build,
      );
}

class JobMaterialItem {
  final String id;
  final String nameKey;
  final int priceMin;
  final int priceMax;

  const JobMaterialItem({
    required this.id,
    required this.nameKey,
    required this.priceMin,
    required this.priceMax,
  });

  factory JobMaterialItem.fromJson(Map<String, dynamic> json) => JobMaterialItem(
        id: json['id'] as String,
        nameKey: json['name_key'] as String,
        priceMin: json['price_min'] as int,
        priceMax: json['price_max'] as int,
      );
}

class JobPricingBreakdown {
  final int laborMin;
  final int laborMax;
  final int visitingMin;
  final int visitingMax;
  final int materialsMin;
  final int materialsMax;
  final int totalMin;
  final int totalMax;

  const JobPricingBreakdown({
    this.laborMin = 150,
    this.laborMax = 300,
    this.visitingMin = 50,
    this.visitingMax = 100,
    this.materialsMin = 50,
    this.materialsMax = 150,
    this.totalMin = 250,
    this.totalMax = 500,
  });

  factory JobPricingBreakdown.fromJson(Map<String, dynamic> json) => JobPricingBreakdown(
        laborMin: json['labor_min'] as int? ?? 0,
        laborMax: json['labor_max'] as int? ?? 0,
        visitingMin: json['visiting_charge_min'] as int? ?? 0,
        visitingMax: json['visiting_charge_max'] as int? ?? 0,
        materialsMin: json['materials_min'] as int? ?? 0,
        materialsMax: json['materials_max'] as int? ?? 0,
        totalMin: json['total_min'] as int? ?? 0,
        totalMax: json['total_max'] as int? ?? 0,
      );
}

class WorkerJobDetailModel {
  final WorkerJobLifecycleState lifecycleState;
  final String id;
  final JobPriority priority;
  final JobRequestState state;
  final int countdownSeconds;
  final String serviceCategoryKey;
  final String serviceSubcategoryKey;
  final String problemTitleKey;
  final String problemDescriptionKey;
  final String aiAnalysisKey;
  final String difficultyKey;
  final String estimatedDurationKey;
  final String addressLineKey;
  final String addressLineRaw;
  final String premiseTypeKey;
  final String floorKey;
  final double distanceKm;
  final double workerLatitude;
  final double workerLongitude;
  final double customerLatitude;
  final double customerLongitude;
  final String scheduledTimeKey;
  final String scheduledFlexibilityKey;
  final String customerNoteKey;
  final JobCustomerInfo customer;
  final JobPricingBreakdown pricing;
  final List<JobScopeItem> scopeOfWork;
  final List<JobToolItem> requiredTools;
  final List<JobMaterialItem> materials;
  final List<String> safetyGuidelines;
  final String paymentMethodKey;
  final String cancellationPolicyKey;
  final String supportAvailabilityKey;

  const WorkerJobDetailModel({
    this.lifecycleState = WorkerJobLifecycleState.newRequest,
    this.id = 'REQ-250531-0178',
    this.priority = JobPriority.high,
    this.state = JobRequestState.normal,
    this.countdownSeconds = 165,
    this.serviceCategoryKey = 'servicePlumber',
    this.serviceSubcategoryKey = 'tapFaucetRepair',
    this.problemTitleKey = 'tapFaucetRepair',
    this.problemDescriptionKey = 'jobProblemTapDesc',
    this.aiAnalysisKey = 'jobAiAnalysisDesc',
    this.difficultyKey = 'difficultyEasy',
    this.estimatedDurationKey = 'estDuration30to45',
    this.addressLineKey = 'jobAddressGaneshApts',
    this.addressLineRaw = '102, Ganesh Apartments, Warje, Pune - 411058, Maharashtra',
    this.premiseTypeKey = 'premiseApartment',
    this.floorKey = 'floorSecond',
    this.distanceKm = 1.2,
    this.workerLatitude = 18.5074,
    this.workerLongitude = 73.8077,
    this.customerLatitude = 18.4800,
    this.customerLongitude = 73.8000,
    this.scheduledTimeKey = 'jobScheduledTimeToday',
    this.scheduledFlexibilityKey = 'flexibility30mins',
    this.customerNoteKey = 'jobCustomerNoteText',
    this.customer = JobCustomerInfo.sample,
    this.pricing = const JobPricingBreakdown(),
    this.scopeOfWork = const [
      JobScopeItem(id: 'scope_1', titleKey: 'scopeTapInspection'),
      JobScopeItem(id: 'scope_2', titleKey: 'scopeWasherReplacement'),
      JobScopeItem(id: 'scope_3', titleKey: 'scopeStopLeakage'),
      JobScopeItem(id: 'scope_4', titleKey: 'scopeWaterFlowTest'),
      JobScopeItem(id: 'scope_5', titleKey: 'scopeCleanupPostWork'),
    ],
    this.requiredTools = const [
      JobToolItem(id: 'tool_1', nameKey: 'toolAdjustableWrench', icon: Icons.build),
      JobToolItem(id: 'tool_2', nameKey: 'toolScrewdriver', icon: Icons.hardware),
      JobToolItem(id: 'tool_3', nameKey: 'toolTapKey', icon: Icons.vpn_key),
      JobToolItem(id: 'tool_4', nameKey: 'toolPlumberTape', icon: Icons.straighten),
      JobToolItem(id: 'tool_5', nameKey: 'toolBasinWrench', icon: Icons.plumbing),
    ],
    this.materials = const [
      JobMaterialItem(id: 'mat_1', nameKey: 'matWasherOring', priceMin: 20, priceMax: 40),
      JobMaterialItem(id: 'mat_2', nameKey: 'matPlumberTape', priceMin: 10, priceMax: 20),
      JobMaterialItem(id: 'mat_3', nameKey: 'matOtherRequired', priceMin: 20, priceMax: 40),
    ],
    this.safetyGuidelines = const [
      'safetyElectricalPrecaution',
      'safetyTurnOffMainValve',
      'safetyUseProtectiveGear',
      'safetyPoliteCommunication',
    ],
    this.paymentMethodKey = 'payMethodOnlineUpi',
    this.cancellationPolicyKey = 'jobCancelPolicy2Hours',
    this.supportAvailabilityKey = 'support24x7Available',
  });

  factory WorkerJobDetailModel.fromJson(Map<String, dynamic> json) {
    final status = json['status'] as String? ?? 'PENDING';
    final lifecycle = WorkerJobLifecycleState.fromApi(status);
    return WorkerJobDetailModel(
      lifecycleState: lifecycle,
      id: json['id'] as String,
      priority: JobPriority.values.firstWhere(
        (item) => item.name.toUpperCase() == (json['priority'] as String? ?? 'HIGH'),
        orElse: () => JobPriority.high,
      ),
      state: lifecycle == WorkerJobLifecycleState.accepted ? JobRequestState.youAccepted : JobRequestState.normal,
      countdownSeconds: json['countdown_seconds'] as int? ?? 0,
      serviceCategoryKey: json['service_category_key'] as String,
      serviceSubcategoryKey: json['service_subcategory_key'] as String,
      problemTitleKey: json['problem_title_key'] as String,
      problemDescriptionKey: json['problem_description_key'] as String,
      aiAnalysisKey: json['ai_analysis_key'] as String,
      difficultyKey: json['difficulty_key'] as String,
      estimatedDurationKey: json['estimated_duration_key'] as String,
      addressLineKey: json['address_line_key'] as String,
      addressLineRaw: json['address_line_raw'] as String,
      premiseTypeKey: json['premise_type_key'] as String,
      floorKey: json['floor_key'] as String,
      distanceKm: (json['distance_km'] as num).toDouble(),
      workerLatitude: (json['worker_latitude'] as num).toDouble(),
      workerLongitude: (json['worker_longitude'] as num).toDouble(),
      customerLatitude: (json['customer_latitude'] as num).toDouble(),
      customerLongitude: (json['customer_longitude'] as num).toDouble(),
      scheduledTimeKey: json['scheduled_time_key'] as String,
      scheduledFlexibilityKey: json['scheduled_flexibility_key'] as String,
      customerNoteKey: json['customer_note_key'] as String,
      customer: JobCustomerInfo.fromJson(json['customer'] as Map<String, dynamic>),
      pricing: JobPricingBreakdown.fromJson(json['pricing'] as Map<String, dynamic>),
      scopeOfWork: (json['scope_of_work'] as List<dynamic>).map((item) => JobScopeItem.fromJson(item as Map<String, dynamic>)).toList(),
      requiredTools: (json['required_tools'] as List<dynamic>).map((item) => JobToolItem.fromJson(item as Map<String, dynamic>)).toList(),
      materials: (json['materials'] as List<dynamic>).map((item) => JobMaterialItem.fromJson(item as Map<String, dynamic>)).toList(),
      safetyGuidelines: (json['safety_guidelines'] as List<dynamic>).cast<String>(),
      paymentMethodKey: json['payment_method_key'] as String,
      cancellationPolicyKey: json['cancellation_policy_key'] as String,
      supportAvailabilityKey: json['support_availability_key'] as String,
    );
  }

  WorkerJobDetailModel copyWith({
    WorkerJobLifecycleState? lifecycleState,
    String? id,
    JobPriority? priority,
    JobRequestState? state,
    int? countdownSeconds,
    String? serviceCategoryKey,
    String? serviceSubcategoryKey,
    String? problemTitleKey,
    String? problemDescriptionKey,
    String? aiAnalysisKey,
    String? difficultyKey,
    String? estimatedDurationKey,
    String? addressLineKey,
    String? addressLineRaw,
    String? premiseTypeKey,
    String? floorKey,
    double? distanceKm,
    double? workerLatitude,
    double? workerLongitude,
    double? customerLatitude,
    double? customerLongitude,
    String? scheduledTimeKey,
    String? scheduledFlexibilityKey,
    String? customerNoteKey,
    JobCustomerInfo? customer,
    JobPricingBreakdown? pricing,
    List<JobScopeItem>? scopeOfWork,
    List<JobToolItem>? requiredTools,
    List<JobMaterialItem>? materials,
    List<String>? safetyGuidelines,
    String? paymentMethodKey,
    String? cancellationPolicyKey,
    String? supportAvailabilityKey,
  }) {
    return WorkerJobDetailModel(
      lifecycleState: lifecycleState ?? this.lifecycleState,
      id: id ?? this.id,
      priority: priority ?? this.priority,
      state: state ?? this.state,
      countdownSeconds: countdownSeconds ?? this.countdownSeconds,
      serviceCategoryKey: serviceCategoryKey ?? this.serviceCategoryKey,
      serviceSubcategoryKey: serviceSubcategoryKey ?? this.serviceSubcategoryKey,
      problemTitleKey: problemTitleKey ?? this.problemTitleKey,
      problemDescriptionKey: problemDescriptionKey ?? this.problemDescriptionKey,
      aiAnalysisKey: aiAnalysisKey ?? this.aiAnalysisKey,
      difficultyKey: difficultyKey ?? this.difficultyKey,
      estimatedDurationKey: estimatedDurationKey ?? this.estimatedDurationKey,
      addressLineKey: addressLineKey ?? this.addressLineKey,
      addressLineRaw: addressLineRaw ?? this.addressLineRaw,
      premiseTypeKey: premiseTypeKey ?? this.premiseTypeKey,
      floorKey: floorKey ?? this.floorKey,
      distanceKm: distanceKm ?? this.distanceKm,
      workerLatitude: workerLatitude ?? this.workerLatitude,
      workerLongitude: workerLongitude ?? this.workerLongitude,
      customerLatitude: customerLatitude ?? this.customerLatitude,
      customerLongitude: customerLongitude ?? this.customerLongitude,
      scheduledTimeKey: scheduledTimeKey ?? this.scheduledTimeKey,
      scheduledFlexibilityKey: scheduledFlexibilityKey ?? this.scheduledFlexibilityKey,
      customerNoteKey: customerNoteKey ?? this.customerNoteKey,
      customer: customer ?? this.customer,
      pricing: pricing ?? this.pricing,
      scopeOfWork: scopeOfWork ?? this.scopeOfWork,
      requiredTools: requiredTools ?? this.requiredTools,
      materials: materials ?? this.materials,
      safetyGuidelines: safetyGuidelines ?? this.safetyGuidelines,
      paymentMethodKey: paymentMethodKey ?? this.paymentMethodKey,
      cancellationPolicyKey: cancellationPolicyKey ?? this.cancellationPolicyKey,
      supportAvailabilityKey: supportAvailabilityKey ?? this.supportAvailabilityKey,
    );
  }

  static const sample = WorkerJobDetailModel();
}
