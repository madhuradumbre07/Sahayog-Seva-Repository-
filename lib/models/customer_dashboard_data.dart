import 'package:flutter/material.dart';

enum BookingStatus { accepted, onTheWay, upcoming, completed, cancelled }

class PopularServiceItem {
  const PopularServiceItem({
    required this.id,
    required this.titleKey,
    required this.icon,
    required this.color,
    required this.bgColor,
    this.startingPrice,
  });

  final String id;
  final String titleKey;
  final IconData icon;
  final Color color;
  final Color bgColor;
  final int? startingPrice;

  static const List<PopularServiceItem> defaults = [
    PopularServiceItem(
      id: 'plumber',
      titleKey: 'servicePlumber',
      icon: Icons.plumbing,
      color: Color(0xFF1976D2),
      bgColor: Color(0xFFE3F2FD),
      startingPrice: 249,
    ),
    PopularServiceItem(
      id: 'electrician',
      titleKey: 'serviceElectrician',
      icon: Icons.bolt,
      color: Color(0xFFF57C00),
      bgColor: Color(0xFFFFF3E0),
      startingPrice: 199,
    ),
    PopularServiceItem(
      id: 'cleaning',
      titleKey: 'serviceCleaning',
      icon: Icons.cleaning_services,
      color: Color(0xFF388E3C),
      bgColor: Color(0xFFE8F5E9),
      startingPrice: 399,
    ),
    PopularServiceItem(
      id: 'painting',
      titleKey: 'servicePainting',
      icon: Icons.format_paint,
      color: Color(0xFFD32F2F),
      bgColor: Color(0xFFFFEBEE),
      startingPrice: 499,
    ),
    PopularServiceItem(
      id: 'appliance',
      titleKey: 'serviceAppliance',
      icon: Icons.tv,
      color: Color(0xFF7B1FA2),
      bgColor: Color(0xFFF3E5F5),
      startingPrice: 299,
    ),
  ];
}

class BookingItem {
  const BookingItem({
    required this.id,
    required this.bookingCode,
    required this.serviceTitleKey,
    required this.dateText,
    required this.timeText,
    required this.status,
    required this.workerName,
    required this.workerRating,
    required this.workerTradeKey,
    this.workerAvatarUrl,
    this.price = 350,
    this.address = 'Ganesh Apts, Warje, Pune',
  });

  final String id;
  final String bookingCode;
  final String serviceTitleKey;
  final String dateText;
  final String timeText;
  final BookingStatus status;
  final String workerName;
  final double workerRating;
  final String workerTradeKey;
  final String? workerAvatarUrl;
  final int price;
  final String address;

  static const sample = BookingItem(
    id: 'b1',
    bookingCode: '#BK12345',
    serviceTitleKey: 'tapFaucetRepair',
    dateText: '12 May 2025',
    timeText: '11:00 AM',
    status: BookingStatus.accepted,
    workerName: 'Sandeep Patil',
    workerRating: 4.8,
    workerTradeKey: 'servicePlumber',
  );
}

class TrustFeatureItem {
  const TrustFeatureItem({
    required this.icon,
    required this.titleKey,
  });

  final IconData icon;
  final String titleKey;

  static const List<TrustFeatureItem> defaults = [
    TrustFeatureItem(
      icon: Icons.verified_user,
      titleKey: 'trustVerifiedWorkers',
    ),
    TrustFeatureItem(
      icon: Icons.price_check,
      titleKey: 'trustFairPricing',
    ),
    TrustFeatureItem(
      icon: Icons.schedule,
      titleKey: 'trustOnTime',
    ),
    TrustFeatureItem(
      icon: Icons.lock_outline,
      titleKey: 'trustSecurePay',
    ),
  ];
}

class PromoBannerItem {
  const PromoBannerItem({
    required this.id,
    required this.titleKey,
    required this.descKey,
    required this.code,
    required this.discountPercent,
  });

  final String id;
  final String titleKey;
  final String descKey;
  final String code;
  final int discountPercent;

  static const sample = PromoBannerItem(
    id: 'first10',
    titleKey: 'firstBookingPromoTitle',
    descKey: 'firstBookingPromoDesc',
    code: 'FIRST10',
    discountPercent: 10,
  );
}
