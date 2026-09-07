// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';
import '../l10n/l10n.dart';

enum BookingConfirmationState {
  confirmed,
  processing,
  incomplete,
  offline,
  cancelled,
}

enum TrackingStage {
  ACCEPTED,
  WORKER_ASSIGNED,
  ON_THE_WAY,
  ARRIVED,
  SERVICE_STARTED,
  COMPLETED;

  String get l10nKey {
    switch (this) {
      case TrackingStage.ACCEPTED:
        return 'stageAccepted';
      case TrackingStage.WORKER_ASSIGNED:
        return 'stageWorkerAssigned';
      case TrackingStage.ON_THE_WAY:
        return 'stageOnTheWay';
      case TrackingStage.ARRIVED:
        return 'stageArrived';
      case TrackingStage.SERVICE_STARTED:
        return 'stageServiceStarted';
      case TrackingStage.COMPLETED:
        return 'stageCompleted';
    }
  }

  IconData get iconData {
    switch (this) {
      case TrackingStage.ACCEPTED:
        return Icons.thumb_up_alt_outlined;
      case TrackingStage.WORKER_ASSIGNED:
        return Icons.assignment_ind_outlined;
      case TrackingStage.ON_THE_WAY:
        return Icons.directions_bike;
      case TrackingStage.ARRIVED:
        return Icons.location_on;
      case TrackingStage.SERVICE_STARTED:
        return Icons.build_circle_outlined;
      case TrackingStage.COMPLETED:
        return Icons.check_circle_outline;
    }
  }
  
  int get stageIndex => index;
}

class BookingTrackingModel {
  final int bookingId;
  final String bookingCode;
  final TrackingStage currentStage;
  final String workerName;
  final String workerPhone;
  final String workerAvatarUrl;
  final String serviceName;
  final String serviceSubcategory;
  final int etaMinutes;
  final double distanceKm;
  final double workerLatitude;
  final double workerLongitude;
  final double customerLatitude;
  final double customerLongitude;
  final String scheduledDate;
  final String scheduledTimeSlot;
  final int totalPrice;
  final String paymentMode;
  final String otpCode;
  final bool isVerified;
  final double ratingAvg;
  final int reviewCount;

  const BookingTrackingModel({
    required this.bookingId,
    required this.bookingCode,
    required this.currentStage,
    required this.workerName,
    required this.workerPhone,
    required this.workerAvatarUrl,
    required this.serviceName,
    required this.serviceSubcategory,
    required this.etaMinutes,
    required this.distanceKm,
    required this.workerLatitude,
    required this.workerLongitude,
    required this.customerLatitude,
    required this.customerLongitude,
    required this.scheduledDate,
    required this.scheduledTimeSlot,
    required this.totalPrice,
    required this.paymentMode,
    required this.otpCode,
    required this.isVerified,
    required this.ratingAvg,
    required this.reviewCount,
  });

  factory BookingTrackingModel.fromJson(Map<String, dynamic> json) {
    TrackingStage stage = TrackingStage.ACCEPTED;
    final stageStr = json['current_stage'] as String?;
    if (stageStr != null) {
      stage = TrackingStage.values.firstWhere(
        (e) => e.name == stageStr,
        orElse: () => TrackingStage.ACCEPTED,
      );
    }

    return BookingTrackingModel(
      bookingId: json['booking_id'] as int? ?? 1,
      bookingCode: json['booking_code'] as String? ?? 'SHS-842109',
      currentStage: stage,
      workerName: json['worker_name'] as String? ?? 'Rahul Sharma',
      workerPhone: json['worker_phone'] as String? ?? '+91 98220 12345',
      workerAvatarUrl: json['worker_avatar_url'] as String? ?? 'https://images.unsplash.com/photo-1540569014015-19a7be504e3a',
      serviceName: json['service_name'] as String? ?? 'Plumbing',
      serviceSubcategory: json['service_subcategory'] as String? ?? 'Tap & Faucet Repair',
      etaMinutes: json['eta_minutes'] as int? ?? 12,
      distanceKm: (json['distance_km'] as num?)?.toDouble() ?? 1.2,
      workerLatitude: (json['worker_latitude'] as num?)?.toDouble() ?? 18.5074,
      workerLongitude: (json['worker_longitude'] as num?)?.toDouble() ?? 73.8077,
      customerLatitude: (json['customer_latitude'] as num?)?.toDouble() ?? 18.4800,
      customerLongitude: (json['customer_longitude'] as num?)?.toDouble() ?? 73.8000,
      scheduledDate: json['scheduled_date'] as String? ?? '2025-05-31',
      scheduledTimeSlot: json['scheduled_time_slot'] as String? ?? '11:00 AM - 11:45 AM',
      totalPrice: json['total_price'] as int? ?? 350,
      paymentMode: json['payment_mode'] as String? ?? 'UPI (Google Pay)',
      otpCode: json['otp_code'] as String? ?? '4289',
      isVerified: json['is_verified'] as bool? ?? true,
      ratingAvg: (json['rating_avg'] as num?)?.toDouble() ?? 4.8,
      reviewCount: json['review_count'] as int? ?? 156,
    );
  }

  factory BookingTrackingModel.fallback() {
    return const BookingTrackingModel(
      bookingId: 1,
      bookingCode: 'BK2505311123',
      currentStage: TrackingStage.ACCEPTED,
      workerName: 'Rahul Sharma',
      workerPhone: '+91 98220 12345',
      workerAvatarUrl: 'https://images.unsplash.com/photo-1540569014015-19a7be504e3a',
      serviceName: 'Plumbing',
      serviceSubcategory: 'Tap / Faucet Repair',
      etaMinutes: 12,
      distanceKm: 1.2,
      workerLatitude: 18.5074,
      workerLongitude: 73.8077,
      customerLatitude: 18.4800,
      customerLongitude: 73.8000,
      scheduledDate: '2025-05-31',
      scheduledTimeSlot: '11:00 AM - 11:45 AM',
      totalPrice: 350,
      paymentMode: 'UPI (Google Pay)',
      otpCode: '4289',
      isVerified: true,
      ratingAvg: 4.8,
      reviewCount: 156,
    );
  }

  BookingTrackingModel copyWith({
    int? bookingId,
    String? bookingCode,
    TrackingStage? currentStage,
    String? workerName,
    String? workerPhone,
    String? workerAvatarUrl,
    String? serviceName,
    String? serviceSubcategory,
    int? etaMinutes,
    double? distanceKm,
    double? workerLatitude,
    double? workerLongitude,
    double? customerLatitude,
    double? customerLongitude,
    String? scheduledDate,
    String? scheduledTimeSlot,
    int? totalPrice,
    String? paymentMode,
    String? otpCode,
    bool? isVerified,
    double? ratingAvg,
    int? reviewCount,
  }) {
    return BookingTrackingModel(
      bookingId: bookingId ?? this.bookingId,
      bookingCode: bookingCode ?? this.bookingCode,
      currentStage: currentStage ?? this.currentStage,
      workerName: workerName ?? this.workerName,
      workerPhone: workerPhone ?? this.workerPhone,
      workerAvatarUrl: workerAvatarUrl ?? this.workerAvatarUrl,
      serviceName: serviceName ?? this.serviceName,
      serviceSubcategory: serviceSubcategory ?? this.serviceSubcategory,
      etaMinutes: etaMinutes ?? this.etaMinutes,
      distanceKm: distanceKm ?? this.distanceKm,
      workerLatitude: workerLatitude ?? this.workerLatitude,
      workerLongitude: workerLongitude ?? this.workerLongitude,
      customerLatitude: customerLatitude ?? this.customerLatitude,
      customerLongitude: customerLongitude ?? this.customerLongitude,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      scheduledTimeSlot: scheduledTimeSlot ?? this.scheduledTimeSlot,
      totalPrice: totalPrice ?? this.totalPrice,
      paymentMode: paymentMode ?? this.paymentMode,
      otpCode: otpCode ?? this.otpCode,
      isVerified: isVerified ?? this.isVerified,
      ratingAvg: ratingAvg ?? this.ratingAvg,
      reviewCount: reviewCount ?? this.reviewCount,
    );
  }

  String localizedWorkerName(BuildContext context) {
    if (workerName == 'Rahul Sharma' || workerName.isEmpty) {
      return context.tr('defaultWorkerName', fallback: workerName);
    }
    return workerName;
  }

  String localizedServiceName(BuildContext context) {
    if (serviceName.toLowerCase().contains('plumb')) {
      return context.tr('servicePlumber', fallback: serviceName);
    }
    return serviceName;
  }

  String localizedSubcategory(BuildContext context) {
    if (serviceSubcategory.toLowerCase().contains('tap') || serviceSubcategory.toLowerCase().contains('faucet')) {
      return context.tr('suggestedPlumbingTitle', fallback: serviceSubcategory);
    }
    return serviceSubcategory;
  }
}
