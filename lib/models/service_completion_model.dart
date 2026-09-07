import 'package:flutter/material.dart';
import '../l10n/l10n.dart';

enum PaymentStatus {
  paymentPending,
  paymentSuccess,
  rated;

  String get l10nKey {
    switch (this) {
      case PaymentStatus.paymentPending:
        return 'paymentPendingBadge';
      case PaymentStatus.paymentSuccess:
        return 'paymentSuccessfulBadge';
      case PaymentStatus.rated:
        return 'ratingSubmittedSuccess';
    }
  }
}

enum PaymentMethodType {
  upiGpay('UPI (Google Pay)', Icons.account_balance_wallet_outlined),
  cards('Credit / Debit Card', Icons.credit_card_outlined),
  cash('Cash after Service', Icons.money_outlined);

  final String label;
  final IconData icon;
  const PaymentMethodType(this.label, this.icon);
}

class MaterialUsedItem {
  final String name;
  final int quantity;
  final String unit;

  const MaterialUsedItem({
    required this.name,
    required this.quantity,
    this.unit = 'nos.',
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'quantity': quantity,
    'unit': unit,
  };

  factory MaterialUsedItem.fromJson(Map<String, dynamic> json) => MaterialUsedItem(
    name: json['name'] as String? ?? '',
    quantity: json['quantity'] as int? ?? 1,
    unit: json['unit'] as String? ?? 'nos.',
  );
}

class ServiceCompletionModel {
  final int bookingId;
  final String bookingCode;
  final int workerId;
  final String workerName;
  final String workerPhone;
  final String workerAvatarUrl;
  final String serviceCategory;
  final String serviceSubcategory;
  final double workerRating;
  final int reviewCount;
  final bool isVerified;
  final String scheduledDate;
  final String scheduledTimeSlot;
  final String customerAddress;
  final int actualDurationMinutes;
  final String completionTime;
  final String problemDescription;
  final String workDoneDescription;
  final int basePrice;
  final int materialsCost;
  final int platformFee;
  final int discountAmount;
  final int totalPrice;
  final List<MaterialUsedItem> materialsUsed;
  final String beforePhotoUrl;
  final String afterPhotoUrl;
  final PaymentStatus paymentStatus;
  final String paymentMethod;
  final String txnId;
  final String invoiceNumber;
  final double rating;
  final String reviewComment;
  final int warrantyDays;

  const ServiceCompletionModel({
    required this.bookingId,
    required this.bookingCode,
    required this.workerId,
    required this.workerName,
    required this.workerPhone,
    required this.workerAvatarUrl,
    required this.serviceCategory,
    required this.serviceSubcategory,
    required this.workerRating,
    required this.reviewCount,
    required this.isVerified,
    required this.scheduledDate,
    required this.scheduledTimeSlot,
    required this.customerAddress,
    required this.actualDurationMinutes,
    required this.completionTime,
    required this.problemDescription,
    required this.workDoneDescription,
    required this.basePrice,
    required this.materialsCost,
    required this.platformFee,
    required this.discountAmount,
    required this.totalPrice,
    required this.materialsUsed,
    required this.beforePhotoUrl,
    required this.afterPhotoUrl,
    this.paymentStatus = PaymentStatus.paymentPending,
    this.paymentMethod = 'UPI (Google Pay)',
    this.txnId = 'UPIS1987451236',
    this.invoiceNumber = 'INV-250531-1123',
    this.rating = 5.0,
    this.reviewComment = '',
    this.warrantyDays = 7,
  });

  factory ServiceCompletionModel.mock({
    String bookingCode = 'BK2505311123',
    PaymentStatus paymentStatus = PaymentStatus.paymentPending,
  }) {
    return ServiceCompletionModel(
      bookingId: 1,
      bookingCode: bookingCode,
      workerId: 1,
      workerName: 'Rahul Sharma',
      workerPhone: '+91 98220 12345',
      workerAvatarUrl: 'https://images.unsplash.com/photo-1540569014015-19a7be504e3a',
      serviceCategory: 'Plumbing',
      serviceSubcategory: 'Plumber – Tap Repair',
      workerRating: 4.8,
      reviewCount: 156,
      isVerified: true,
      scheduledDate: '31 May 2025',
      scheduledTimeSlot: '11:00 AM - 11:45 AM',
      customerAddress: '102, Ganesh Apartment, Warje, Pune – 411058',
      actualDurationMinutes: 45,
      completionTime: '11:45 AM, 31 May 2025',
      problemDescription: 'Water was leaking from the tap.',
      workDoneDescription: 'Joint repaired and rubber washer replaced.',
      basePrice: 350,
      materialsCost: 50,
      platformFee: 20,
      discountAmount: 0,
      totalPrice: 420,
      materialsUsed: const [
        MaterialUsedItem(name: 'Tap Washer', quantity: 1),
        MaterialUsedItem(name: 'PTFE Tape', quantity: 1),
        MaterialUsedItem(name: 'Coupling', quantity: 1),
      ],
      beforePhotoUrl: 'https://images.unsplash.com/photo-1584622650111-993a426fbf0a?w=400',
      afterPhotoUrl: 'https://images.unsplash.com/photo-1585704032915-c3400ca199e7?w=400',
      paymentStatus: paymentStatus,
      paymentMethod: 'UPI (Google Pay)',
      txnId: 'UPIS1987451236',
      invoiceNumber: 'INV-250531-1123',
      rating: 5.0,
      reviewComment: '',
      warrantyDays: 7,
    );
  }

  ServiceCompletionModel copyWith({
    int? bookingId,
    String? bookingCode,
    int? workerId,
    String? workerName,
    String? workerPhone,
    String? workerAvatarUrl,
    String? serviceCategory,
    String? serviceSubcategory,
    double? workerRating,
    int? reviewCount,
    bool? isVerified,
    String? scheduledDate,
    String? scheduledTimeSlot,
    String? customerAddress,
    int? actualDurationMinutes,
    String? completionTime,
    String? problemDescription,
    String? workDoneDescription,
    int? basePrice,
    int? materialsCost,
    int? platformFee,
    int? discountAmount,
    int? totalPrice,
    List<MaterialUsedItem>? materialsUsed,
    String? beforePhotoUrl,
    String? afterPhotoUrl,
    PaymentStatus? paymentStatus,
    String? paymentMethod,
    String? txnId,
    String? invoiceNumber,
    double? rating,
    String? reviewComment,
    int? warrantyDays,
  }) {
    return ServiceCompletionModel(
      bookingId: bookingId ?? this.bookingId,
      bookingCode: bookingCode ?? this.bookingCode,
      workerId: workerId ?? this.workerId,
      workerName: workerName ?? this.workerName,
      workerPhone: workerPhone ?? this.workerPhone,
      workerAvatarUrl: workerAvatarUrl ?? this.workerAvatarUrl,
      serviceCategory: serviceCategory ?? this.serviceCategory,
      serviceSubcategory: serviceSubcategory ?? this.serviceSubcategory,
      workerRating: workerRating ?? this.workerRating,
      reviewCount: reviewCount ?? this.reviewCount,
      isVerified: isVerified ?? this.isVerified,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      scheduledTimeSlot: scheduledTimeSlot ?? this.scheduledTimeSlot,
      customerAddress: customerAddress ?? this.customerAddress,
      actualDurationMinutes: actualDurationMinutes ?? this.actualDurationMinutes,
      completionTime: completionTime ?? this.completionTime,
      problemDescription: problemDescription ?? this.problemDescription,
      workDoneDescription: workDoneDescription ?? this.workDoneDescription,
      basePrice: basePrice ?? this.basePrice,
      materialsCost: materialsCost ?? this.materialsCost,
      platformFee: platformFee ?? this.platformFee,
      discountAmount: discountAmount ?? this.discountAmount,
      totalPrice: totalPrice ?? this.totalPrice,
      materialsUsed: materialsUsed ?? this.materialsUsed,
      beforePhotoUrl: beforePhotoUrl ?? this.beforePhotoUrl,
      afterPhotoUrl: afterPhotoUrl ?? this.afterPhotoUrl,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      txnId: txnId ?? this.txnId,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      rating: rating ?? this.rating,
      reviewComment: reviewComment ?? this.reviewComment,
      warrantyDays: warrantyDays ?? this.warrantyDays,
    );
  }

  String localizedWorkerName(BuildContext context) {
    if (workerName == 'Rahul Sharma' || workerName.isEmpty) {
      return context.tr('defaultWorkerName', fallback: workerName);
    }
    return workerName;
  }

  String localizedServiceSubcategory(BuildContext context) {
    if (serviceSubcategory.contains('Tap') || serviceSubcategory.contains('Plumber')) {
      return '${context.tr('servicePlumber')} – ${context.tr('suggestedPlumbingTitle')}';
    }
    return serviceSubcategory;
  }
}
