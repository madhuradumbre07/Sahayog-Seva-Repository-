import 'package:flutter/material.dart';
import '../l10n/l10n.dart';
import 'worker_matching_model.dart';

class AddressItem {
  final String id;
  final String title;
  final String? titleKey;
  final String addressLine;
  final String? addressKey;
  final double latitude;
  final double longitude;
  final bool isDefault;

  const AddressItem({
    required this.id,
    required this.title,
    this.titleKey,
    required this.addressLine,
    this.addressKey,
    required this.latitude,
    required this.longitude,
    this.isDefault = false,
  });

  String localizedTitle(BuildContext context) =>
      titleKey != null ? context.tr(titleKey!, fallback: title) : title;

  String localizedAddressLine(BuildContext context) =>
      addressKey != null ? context.tr(addressKey!, fallback: addressLine) : addressLine;

  static List<AddressItem> get defaultAddresses => [
    const AddressItem(
      id: 'ADDR-1',
      title: 'Home',
      titleKey: 'addrHomeTitle',
      addressLine: '102, Ganesh Apartments, Warje, Pune - 411058, Maharashtra',
      addressKey: 'addrHomeLine',
      latitude: 18.4800,
      longitude: 73.8000,
      isDefault: true,
    ),
    const AddressItem(
      id: 'ADDR-2',
      title: 'Office',
      titleKey: 'addrOfficeTitle',
      addressLine: '504, Sahayog Tower, Senapati Bapat Road, Pune - 411016',
      addressKey: 'addrOfficeLine',
      latitude: 18.5300,
      longitude: 73.8300,
      isDefault: false,
    ),
    const AddressItem(
      id: 'ADDR-3',
      title: 'Parents\' Home',
      titleKey: 'addrParentsTitle',
      addressLine: '12, Mayur Colony, Kothrud, Pune - 411038',
      addressKey: 'addrParentsLine',
      latitude: 18.5050,
      longitude: 73.8100,
      isDefault: false,
    ),
  ];

  factory AddressItem.fromSavedAddress({
    required String id,
    required String title,
    required String addressLine,
    double latitude = 18.4800,
    double longitude = 73.8000,
    bool isDefault = false,
  }) {
    return AddressItem(
      id: id,
      title: title,
      addressLine: addressLine,
      latitude: latitude,
      longitude: longitude,
      isDefault: isDefault,
    );
  }
}

class BookingTimeSlotItem {
  final String id;
  final String timeLabel;
  final String period; // Morning, Afternoon, Evening
  final String? periodKey;
  final bool isAvailable;

  const BookingTimeSlotItem({
    required this.id,
    required this.timeLabel,
    required this.period,
    this.periodKey,
    this.isAvailable = true,
  });

  String localizedPeriod(BuildContext context) =>
      periodKey != null ? context.tr(periodKey!, fallback: period) : period;

  static List<BookingTimeSlotItem> get defaultSlots => [
    const BookingTimeSlotItem(id: 'SLOT-1', timeLabel: '09:00 AM - 10:00 AM', period: 'Morning', periodKey: 'periodMorning'),
    const BookingTimeSlotItem(id: 'SLOT-2', timeLabel: '10:00 AM - 11:00 AM', period: 'Morning', periodKey: 'periodMorning'),
    const BookingTimeSlotItem(id: 'SLOT-3', timeLabel: '11:00 AM - 12:00 PM', period: 'Morning', periodKey: 'periodMorning'),
    const BookingTimeSlotItem(id: 'SLOT-4', timeLabel: '01:00 PM - 02:00 PM', period: 'Afternoon', periodKey: 'periodAfternoon'),
    const BookingTimeSlotItem(id: 'SLOT-5', timeLabel: '02:00 PM - 03:00 PM', period: 'Afternoon', periodKey: 'periodAfternoon'),
    const BookingTimeSlotItem(id: 'SLOT-6', timeLabel: '03:00 PM - 04:00 PM', period: 'Afternoon', periodKey: 'periodAfternoon', isAvailable: false),
    const BookingTimeSlotItem(id: 'SLOT-7', timeLabel: '05:00 PM - 06:00 PM', period: 'Evening', periodKey: 'periodEvening'),
    const BookingTimeSlotItem(id: 'SLOT-8', timeLabel: '06:00 PM - 07:00 PM', period: 'Evening', periodKey: 'periodEvening'),
  ];
}

class BookingDraftModel {
  final WorkerMatchModel? worker;
  final String serviceCategory;
  final String serviceSubcategory;
  final String problemDescription;
  final String? problemDescriptionKey;
  final AddressItem selectedAddress;
  final DateTime scheduledDate;
  final String timeSlot;
  final String specialInstructions;
  final int basePrice;
  final int cooperativeFee;
  final int discountAmount;
  final int totalPrice;
  final String paymentMode;
  final String? bookingCode;

  BookingDraftModel({
    this.worker,
    this.serviceCategory = 'Plumbing',
    this.serviceSubcategory = 'Tap & Faucet Repair',
    this.problemDescription = 'Water is leaking from my kitchen tap.',
    this.problemDescriptionKey = 'sampleKitchenLeakage',
    AddressItem? selectedAddress,
    DateTime? scheduledDate,
    this.timeSlot = '11:00 AM - 12:00 PM',
    this.specialInstructions = '',
    this.basePrice = 350,
    this.cooperativeFee = 35,
    this.discountAmount = 35,
    this.totalPrice = 350,
    this.paymentMode = 'PAY_AFTER_SERVICE',
    this.bookingCode,
  })  : selectedAddress = selectedAddress ?? AddressItem.defaultAddresses.first,
        scheduledDate = scheduledDate ?? DateTime.now().add(const Duration(days: 1));

  String localizedProblemDescription(BuildContext context) {
    if (problemDescriptionKey != null) {
      return context.tr(problemDescriptionKey!, fallback: problemDescription);
    }
    return problemDescription;
  }

  String localizedServiceName(BuildContext context) {
    if (serviceCategory.toLowerCase().contains('plumb')) {
      return context.tr('servicePlumber', fallback: serviceCategory);
    }
    return serviceCategory;
  }

  String localizedSubcategory(BuildContext context) {
    if (serviceSubcategory.toLowerCase().contains('tap') || serviceSubcategory.toLowerCase().contains('faucet')) {
      return context.tr('suggestedPlumbingTitle', fallback: serviceSubcategory);
    }
    return serviceSubcategory;
  }

  BookingDraftModel copyWith({
    WorkerMatchModel? worker,
    String? serviceCategory,
    String? serviceSubcategory,
    String? problemDescription,
    String? problemDescriptionKey,
    AddressItem? selectedAddress,
    DateTime? scheduledDate,
    String? timeSlot,
    String? specialInstructions,
    int? basePrice,
    int? cooperativeFee,
    int? discountAmount,
    int? totalPrice,
    String? paymentMode,
    String? bookingCode,
  }) {
    return BookingDraftModel(
      worker: worker ?? this.worker,
      serviceCategory: serviceCategory ?? this.serviceCategory,
      serviceSubcategory: serviceSubcategory ?? this.serviceSubcategory,
      problemDescription: problemDescription ?? this.problemDescription,
      problemDescriptionKey: problemDescriptionKey ?? this.problemDescriptionKey,
      selectedAddress: selectedAddress ?? this.selectedAddress,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      timeSlot: timeSlot ?? this.timeSlot,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      basePrice: basePrice ?? this.basePrice,
      cooperativeFee: cooperativeFee ?? this.cooperativeFee,
      discountAmount: discountAmount ?? this.discountAmount,
      totalPrice: totalPrice ?? this.totalPrice,
      paymentMode: paymentMode ?? this.paymentMode,
      bookingCode: bookingCode ?? this.bookingCode,
    );
  }

  Map<String, dynamic> toApiPayload() => {
    'worker_id': worker?.id ?? 1,
    'service_category': serviceCategory,
    'service_subcategory': serviceSubcategory,
    'problem_description': problemDescription,
    'address_line': selectedAddress.addressLine,
    'latitude': selectedAddress.latitude,
    'longitude': selectedAddress.longitude,
    'scheduled_date': '${scheduledDate.year}-${scheduledDate.month.toString().padLeft(2, '0')}-${scheduledDate.day.toString().padLeft(2, '0')}',
    'time_slot': timeSlot,
    'special_instructions': specialInstructions,
    'base_price': basePrice,
    'cooperative_fee': cooperativeFee,
    'discount_amount': discountAmount,
    'total_price': totalPrice,
  };
}

