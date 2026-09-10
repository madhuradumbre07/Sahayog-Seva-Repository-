import 'package:flutter/material.dart';

enum BookingStatus { accepted, onTheWay, upcoming, completed, cancelled }

class ServiceSubcategoryItem {
  const ServiceSubcategoryItem({
    required this.id,
    required this.title,
    required this.titleKey,
    required this.startingPrice,
    required this.estimatedTime,
    this.iconName,
  });

  final String id;
  final String title;
  final String titleKey;
  final int startingPrice;
  final String estimatedTime;
  final String? iconName;

  factory ServiceSubcategoryItem.fromJson(Map<String, dynamic> json) {
    return ServiceSubcategoryItem(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      titleKey: (json['title_key'] ?? '').toString(),
      startingPrice: (json['starting_price'] as num?)?.toInt() ?? 199,
      estimatedTime: (json['estimated_time'] ?? '30-45 mins').toString(),
      iconName: json['icon_name'] as String?,
    );
  }
}

class PopularServiceItem {
  const PopularServiceItem({
    required this.id,
    required this.titleKey,
    required this.icon,
    required this.color,
    required this.bgColor,
    this.startingPrice,
    this.description,
    this.subcategories = const [],
  });

  final String id;
  final String titleKey;
  final IconData icon;
  final Color color;
  final Color bgColor;
  final int? startingPrice;
  final String? description;
  final List<ServiceSubcategoryItem> subcategories;

  static IconData _iconFromName(String? name) {
    switch (name) {
      case 'plumbing':
      case 'water_drop':
        return Icons.plumbing;
      case 'bolt':
      case 'electric_bolt':
      case 'toggle_on':
        return Icons.bolt;
      case 'cleaning_services':
      case 'sanitizer':
      case 'water':
      case 'kitchen':
        return Icons.cleaning_services;
      case 'format_paint':
      case 'brush':
      case 'shield':
        return Icons.format_paint;
      case 'tv':
      case 'ac_unit':
      case 'hot_tub':
        return Icons.tv;
      default:
        return Icons.handyman;
    }
  }

  static Color _colorFromHex(String? hex, Color fallback) {
    if (hex == null || hex.isEmpty) return fallback;
    final clean = hex.replaceAll('#', '');
    if (clean.length == 6) {
      return Color(int.parse('FF$clean', radix: 16));
    }
    return fallback;
  }

  factory PopularServiceItem.fromJson(Map<String, dynamic> json) {
    final subList = (json['subcategories'] as List?)
            ?.map((s) => ServiceSubcategoryItem.fromJson(s as Map<String, dynamic>))
            .toList() ??
        const [];

    return PopularServiceItem(
      id: (json['id'] ?? '').toString(),
      titleKey: (json['title_key'] ?? json['title'] ?? '').toString(),
      icon: _iconFromName(json['icon_name'] as String?),
      color: _colorFromHex(json['color_hex'] as String?, const Color(0xFF1976D2)),
      bgColor: _colorFromHex(json['bg_color_hex'] as String?, const Color(0xFFE3F2FD)),
      startingPrice: (json['starting_price'] as num?)?.toInt(),
      description: json['description'] as String?,
      subcategories: subList,
    );
  }

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

  factory BookingItem.fromJson(Map<String, dynamic> json) {
    final rawStatus = (json['status'] ?? json['current_stage'] ?? 'PENDING_WORKER').toString().toUpperCase();
    BookingStatus status = BookingStatus.accepted;
    if (rawStatus.contains('NAVIGAT') || rawStatus.contains('ON_THE_WAY')) {
      status = BookingStatus.onTheWay;
    } else if (rawStatus.contains('ARRIV') || rawStatus.contains('PROGRESS') || rawStatus.contains('STARTED')) {
      status = BookingStatus.upcoming;
    } else if (rawStatus.contains('COMPLET')) {
      status = BookingStatus.completed;
    } else if (rawStatus.contains('CANCEL') || rawStatus.contains('REJECT')) {
      status = BookingStatus.cancelled;
    }

    final cat = (json['service_category'] ?? json['service_name'] ?? 'servicePlumber').toString();
    final subcat = (json['service_subcategory'] ?? '').toString();
    final titleKey = subcat.isNotEmpty ? subcat : cat;

    return BookingItem(
      id: (json['id'] ?? json['booking_id'] ?? '').toString(),
      bookingCode: (json['booking_code'] ?? '').toString(),
      serviceTitleKey: titleKey,
      dateText: (json['scheduled_date'] ?? 'Today').toString(),
      timeText: (json['time_slot'] ?? json['scheduled_time_slot'] ?? '11:00 AM').toString(),
      status: status,
      workerName: (json['worker_name'] ?? 'Assigned Worker').toString(),
      workerRating: (json['rating_avg'] as num?)?.toDouble() ?? 4.8,
      workerTradeKey: cat,
      workerAvatarUrl: json['worker_avatar_url'] as String?,
      price: (json['total_price'] as num?)?.toInt() ?? 350,
      address: (json['address_line'] ?? 'Ganesh Apts, Warje, Pune').toString(),
    );
  }

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
