import 'package:flutter/material.dart';

import 'worker_job_model.dart';

enum WorkerAvailability { online, busy, offline }

class JobRequestItem {
  const JobRequestItem({
    required this.id,
    required this.title,
    required this.category,
    required this.location,
    required this.distanceText,
    required this.priceRange,
    required this.customerName,
    this.titleKey = '',
    this.categoryKey = '',
    this.timeAgoKey = '',
    this.initialCountdownSeconds = 0,
  });

  final String id;
  final String title;
  final String category;
  final String location;
  final String distanceText;
  final String priceRange;
  final String customerName;
  final String titleKey;
  final String categoryKey;
  final String timeAgoKey;
  final int initialCountdownSeconds;

  factory JobRequestItem.fromJob(WorkerJobDetailModel job) {
    final min = job.pricing.totalMin;
    final max = job.pricing.totalMax;
    final price = min == max ? '₹$min' : '₹$min - ₹$max';
    return JobRequestItem(
      id: job.id,
      title: job.problemTitleKey,
      category: job.serviceCategoryKey,
      location: job.addressLineRaw.isNotEmpty ? job.addressLineRaw : job.addressLineKey,
      distanceText: job.distanceKm > 0 ? '${job.distanceKm.toStringAsFixed(1)} km away' : '',
      priceRange: price,
      customerName: job.customer.name,
      titleKey: job.problemTitleKey,
      categoryKey: job.serviceCategoryKey,
      initialCountdownSeconds: job.countdownSeconds,
    );
  }
}

class AppointmentItem {
  const AppointmentItem({
    required this.id,
    required this.timeText,
    required this.title,
    required this.location,
    required this.statusKey,
    required this.statusColor,
    required this.statusBgColor,
    required this.customerName,
    this.titleKey = '',
  });

  final String id;
  final String timeText;
  final String title;
  final String location;
  final String statusKey;
  final Color statusColor;
  final Color statusBgColor;
  final String customerName;
  final String titleKey;

  factory AppointmentItem.fromJob(WorkerJobDetailModel job) {
    final status = _statusFor(job.lifecycleState);
    return AppointmentItem(
      id: job.id,
      timeText: job.scheduledTimeKey.isNotEmpty ? job.scheduledTimeKey : '--',
      title: job.problemTitleKey,
      titleKey: job.problemTitleKey,
      location: job.addressLineRaw.isNotEmpty ? job.addressLineRaw : job.addressLineKey,
      statusKey: status.$1,
      statusColor: status.$2,
      statusBgColor: status.$3,
      customerName: job.customer.name,
    );
  }

  factory AppointmentItem.fromRequest(JobRequestItem request) {
    return AppointmentItem(
      id: request.id,
      timeText: '--',
      title: request.title,
      titleKey: request.titleKey,
      location: request.location,
      statusKey: 'statusUpcoming',
      statusColor: const Color(0xFFE65100),
      statusBgColor: const Color(0xFFFFF3E0),
      customerName: request.customerName,
    );
  }

  static (String, Color, Color) _statusFor(WorkerJobLifecycleState state) {
    switch (state) {
      case WorkerJobLifecycleState.navigating:
        return ('statusOnTheWay', const Color(0xFF2E7D32), const Color(0xFFE8F5E9));
      case WorkerJobLifecycleState.inProgress:
      case WorkerJobLifecycleState.arrivedOtp:
        return ('statusInProgress', const Color(0xFF1565C0), const Color(0xFFE3F2FD));
      case WorkerJobLifecycleState.accepted:
        return ('statusUpcoming', const Color(0xFFE65100), const Color(0xFFFFF3E0));
      default:
        return ('statusUpcoming', const Color(0xFFE65100), const Color(0xFFFFF3E0));
    }
  }
}

class WorkerMetrics {
  const WorkerMetrics({
    required this.todayEarnings,
    required this.completedJobsToday,
    required this.monthlyEarnings,
    required this.rating,
    required this.reviewsCount,
  });

  final int todayEarnings;
  final int completedJobsToday;
  final int monthlyEarnings;
  final double rating;
  final int reviewsCount;

  static const empty = WorkerMetrics(
    todayEarnings: 0,
    completedJobsToday: 0,
    monthlyEarnings: 0,
    rating: 0,
    reviewsCount: 0,
  );
}
