import 'package:flutter/material.dart';

enum WorkerAvailability { online, busy, offline }

class JobRequestItem {
  const JobRequestItem({
    required this.id,
    required this.titleKey,
    required this.categoryKey,
    required this.location,
    required this.distanceText,
    required this.priceRange,
    required this.timeAgoKey,
    required this.customerName,
    this.initialCountdownSeconds = 165, // 02:45
  });

  final String id;
  final String titleKey;
  final String categoryKey;
  final String location;
  final String distanceText;
  final String priceRange;
  final String timeAgoKey;
  final String customerName;
  final int initialCountdownSeconds;

  static const sample = JobRequestItem(
    id: 'job_req_101',
    titleKey: 'tapFaucetRepair',
    categoryKey: 'servicePlumber',
    location: 'Ganesh Apts, Warje, Pune',
    distanceText: '1.2 km away',
    priceRange: '₹250 - ₹500',
    timeAgoKey: 'jobExpiringIn',
    customerName: 'Pooja Deshmukh',
  );
}

class AppointmentItem {
  const AppointmentItem({
    required this.id,
    required this.timeText,
    required this.titleKey,
    required this.location,
    required this.statusKey,
    required this.statusColor,
    required this.statusBgColor,
    required this.customerName,
  });

  final String id;
  final String timeText;
  final String titleKey;
  final String location;
  final String statusKey;
  final Color statusColor;
  final Color statusBgColor;
  final String customerName;

  static const List<AppointmentItem> defaults = [
    AppointmentItem(
      id: 'apt_1',
      timeText: '11:00 AM',
      titleKey: 'appointment1Title',
      location: 'Kothrud, Pune',
      statusKey: 'statusOnTheWay',
      statusColor: Color(0xFF2E7D32),
      statusBgColor: Color(0xFFE8F5E9),
      customerName: 'Amit Joshi',
    ),
    AppointmentItem(
      id: 'apt_2',
      timeText: '03:30 PM',
      titleKey: 'appointment2Title',
      location: 'Kothrud, Pune',
      statusKey: 'statusUpcoming',
      statusColor: Color(0xFFE65100),
      statusBgColor: Color(0xFFFFF3E0),
      customerName: 'Sunita Kulkarni',
    ),
  ];
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

  static const sample = WorkerMetrics(
    todayEarnings: 1250,
    completedJobsToday: 2,
    monthlyEarnings: 28450,
    rating: 4.8,
    reviewsCount: 156,
  );
}

class QuickActionItem {
  const QuickActionItem({
    required this.id,
    required this.titleKey,
    required this.icon,
    required this.color,
  });

  final String id;
  final String titleKey;
  final IconData icon;
  final Color color;

  static const List<QuickActionItem> defaults = [
    QuickActionItem(
      id: 'availability',
      titleKey: 'quickAvailability',
      icon: Icons.access_time_filled,
      color: Color(0xFF0D47A1),
    ),
    QuickActionItem(
      id: 'history',
      titleKey: 'quickJobHistory',
      icon: Icons.history,
      color: Color(0xFF0D47A1),
    ),
    QuickActionItem(
      id: 'earnings',
      titleKey: 'quickEarnings',
      icon: Icons.account_balance_wallet,
      color: Color(0xFF0D47A1),
    ),
    QuickActionItem(
      id: 'profile',
      titleKey: 'quickProfile',
      icon: Icons.person,
      color: Color(0xFF0D47A1),
    ),
  ];
}
