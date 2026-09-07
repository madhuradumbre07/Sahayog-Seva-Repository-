import 'dart:convert';
import 'package:flutter/material.dart';
import '../l10n/l10n.dart';

enum WorkerAvailabilityStatus {
  availableNow,
  busyUntilAfternoon,
  offline,
}

class ExplainableMatchMatrix {
  final int skillMatchPercent;
  final int proximityPercent;
  final int availabilityPercent;
  final int workloadFairnessPercent;
  final int overallMatchScore;
  final double distanceKm;
  final String reasonSummary;
  final String? reasonSummaryKey;

  const ExplainableMatchMatrix({
    required this.skillMatchPercent,
    required this.proximityPercent,
    required this.availabilityPercent,
    required this.workloadFairnessPercent,
    required this.overallMatchScore,
    required this.distanceKm,
    required this.reasonSummary,
    this.reasonSummaryKey,
  });

  factory ExplainableMatchMatrix.fromJson(Map<String, dynamic> json) {
    return ExplainableMatchMatrix(
      skillMatchPercent: json['skill_match_percent'] as int? ?? 90,
      proximityPercent: json['proximity_percent'] as int? ?? 85,
      availabilityPercent: json['availability_percent'] as int? ?? 100,
      workloadFairnessPercent: json['workload_fairness_percent'] as int? ?? 80,
      overallMatchScore: json['overall_match_score'] as int? ?? 92,
      distanceKm: (json['distance_km'] as num?)?.toDouble() ?? 1.2,
      reasonSummary: json['reason_summary'] as String? ?? 'High skill & proximity match',
      reasonSummaryKey: json['reason_summary_key'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'skill_match_percent': skillMatchPercent,
    'proximity_percent': proximityPercent,
    'availability_percent': availabilityPercent,
    'workload_fairness_percent': workloadFairnessPercent,
    'overall_match_score': overallMatchScore,
    'distance_km': distanceKm,
    'reason_summary': reasonSummary,
    if (reasonSummaryKey != null) 'reason_summary_key': reasonSummaryKey,
  };
}

class WorkerCertificationItem {
  final String title;
  final String issuer;

  const WorkerCertificationItem({required this.title, required this.issuer});

  factory WorkerCertificationItem.fromJson(Map<String, dynamic> json) {
    return WorkerCertificationItem(
      title: json['title'] as String? ?? '',
      issuer: json['issuer'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'title': title, 'issuer': issuer};
}

class WorkerReviewItem {
  final String author;
  final double rating;
  final String comment;
  final String date;
  final String? authorKey;
  final String? commentKey;
  final String? dateKey;

  const WorkerReviewItem({
    required this.author,
    required this.rating,
    required this.comment,
    required this.date,
    this.authorKey,
    this.commentKey,
    this.dateKey,
  });

  String localizedAuthor(BuildContext context) =>
      authorKey != null ? context.tr(authorKey!, fallback: author) : author;

  String localizedComment(BuildContext context) =>
      commentKey != null ? context.tr(commentKey!, fallback: comment) : comment;

  String localizedDate(BuildContext context) =>
      dateKey != null ? context.tr(dateKey!, fallback: date) : date;

  factory WorkerReviewItem.fromJson(Map<String, dynamic> json) {
    return WorkerReviewItem(
      author: json['author'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      comment: json['comment'] as String? ?? '',
      date: json['date'] as String? ?? '',
      authorKey: json['author_key'] as String?,
      commentKey: json['comment_key'] as String?,
      dateKey: json['date_key'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'author': author,
    'rating': rating,
    'comment': comment,
    'date': date,
    if (authorKey != null) 'author_key': authorKey,
    if (commentKey != null) 'comment_key': commentKey,
    if (dateKey != null) 'date_key': dateKey,
  };
}

class WorkerMatchModel {
  final int id;
  final int cooperativeId;
  final String fullName;
  final String? fullNameMr;
  final String? fullNameHi;
  final String? nameKey;
  final String phoneNumber;
  final String avatarUrl;
  final double latitude;
  final double longitude;
  final String addressArea;
  final String areaKey;
  final String primaryTrade;
  final String tradeSubtitle;
  final String tradeKey;
  final int experienceYears;
  final bool isAvailable;
  final String availabilityStatus;
  final String? busyUntilText;
  final double ratingAvg;
  final int reviewCount;
  final int jobsCompletedCount;
  final int jobsCompletedThisMonth;
  final int responseTimeMinutes;
  final int avgCompletionTimeMinutes;
  final int hourlyRateMin;
  final int hourlyRateMax;
  final bool isVerified;
  final String memberId;
  final String? welfareSchemeId;
  final String cooperativeSocietyName;
  final String cooperativeKey;
  final List<String> skills;
  final List<WorkerCertificationItem> certifications;
  final List<String> galleryUrls;
  final List<WorkerReviewItem> reviews;
  final int matchScore;
  final double distanceKm;
  final ExplainableMatchMatrix explainability;

  const WorkerMatchModel({
    required this.id,
    this.cooperativeId = 1,
    required this.fullName,
    this.fullNameMr,
    this.fullNameHi,
    this.nameKey,
    required this.phoneNumber,
    required this.avatarUrl,
    required this.latitude,
    required this.longitude,
    required this.addressArea,
    this.areaKey = 'areaWarjePune',
    required this.primaryTrade,
    required this.tradeSubtitle,
    this.tradeKey = 'tradePipingSpecialist',
    required this.experienceYears,
    required this.isAvailable,
    this.availabilityStatus = 'AVAILABLE_NOW',
    this.busyUntilText,
    required this.ratingAvg,
    required this.reviewCount,
    required this.jobsCompletedCount,
    this.jobsCompletedThisMonth = 12,
    required this.responseTimeMinutes,
    this.avgCompletionTimeMinutes = 35,
    required this.hourlyRateMin,
    required this.hourlyRateMax,
    this.isVerified = true,
    required this.memberId,
    this.welfareSchemeId,
    required this.cooperativeSocietyName,
    this.cooperativeKey = 'coopShivshakti',
    required this.skills,
    required this.certifications,
    required this.galleryUrls,
    required this.reviews,
    required this.matchScore,
    required this.distanceKm,
    required this.explainability,
  });

  String localizedName(String langCode) {
    if (nameKey != null && nameKey!.isNotEmpty) {
      return AppStringsData.translate(nameKey!, languageCode: langCode, fallback: fullName);
    }
    if (langCode == 'mr' && fullNameMr != null && fullNameMr!.isNotEmpty) {
      return fullNameMr!;
    }
    if (langCode == 'hi' && fullNameHi != null && fullNameHi!.isNotEmpty) {
      return fullNameHi!;
    }
    return fullName;
  }

  String localizedTradeSubtitle(BuildContext context) =>
      context.tr(tradeKey, fallback: tradeSubtitle);

  String localizedAddressArea(BuildContext context) =>
      context.tr(areaKey, fallback: addressArea);

  String localizedSociety(BuildContext context) =>
      context.tr(cooperativeKey, fallback: cooperativeSocietyName);

  String localizedStatusText(BuildContext context) {
    if (availabilityStatus == 'AVAILABLE_NOW' || isAvailable) {
      return context.tr('statusAvailableNow');
    }
    if (availabilityStatus == 'BUSY_UNTIL_AFTERNOON') {
      return context.tr('statusBusyUntilAfternoon', params: {'time': '4:00 PM'});
    }
    return context.tr('statusOffline');
  }

  String localizedReasonSummary(BuildContext context) {
    if (explainability.reasonSummaryKey != null) {
      return context.tr(
        explainability.reasonSummaryKey!,
        params: {
          'score': matchScore.toString(),
          'skill': explainability.skillMatchPercent.toString(),
          'dist': distanceKm.toStringAsFixed(1),
          'area': localizedAddressArea(context),
          'exp': experienceYears.toString(),
          'time': '4:00 PM',
          'min': hourlyRateMin.toString(),
          'max': hourlyRateMax.toString(),
        },
        fallback: explainability.reasonSummary,
      );
    }
    return explainability.reasonSummary;
  }

  factory WorkerMatchModel.fromJson(Map<String, dynamic> json) {
    List<String> parsedSkills = [];
    if (json['skills_json'] != null) {
      try {
        final decoded = jsonDecode(json['skills_json'] as String);
        if (decoded is List) parsedSkills = decoded.map((e) => e.toString()).toList();
      } catch (_) {}
    } else if (json['skills'] != null && json['skills'] is List) {
      parsedSkills = (json['skills'] as List).map((e) => e.toString()).toList();
    }

    List<WorkerCertificationItem> parsedCerts = [];
    if (json['certifications_json'] != null) {
      try {
        final decoded = jsonDecode(json['certifications_json'] as String);
        if (decoded is List) {
          parsedCerts = decoded.map((e) => WorkerCertificationItem.fromJson(e as Map<String, dynamic>)).toList();
        }
      } catch (_) {}
    } else if (json['certifications'] != null && json['certifications'] is List) {
      parsedCerts = (json['certifications'] as List).map((e) => WorkerCertificationItem.fromJson(e as Map<String, dynamic>)).toList();
    }

    List<String> parsedGallery = [];
    if (json['gallery_json'] != null) {
      try {
        final decoded = jsonDecode(json['gallery_json'] as String);
        if (decoded is List) parsedGallery = decoded.map((e) => e.toString()).toList();
      } catch (_) {}
    } else if (json['galleryUrls'] != null && json['galleryUrls'] is List) {
      parsedGallery = (json['galleryUrls'] as List).map((e) => e.toString()).toList();
    }

    List<WorkerReviewItem> parsedReviews = [];
    if (json['reviews_json'] != null) {
      try {
        final decoded = jsonDecode(json['reviews_json'] as String);
        if (decoded is List) {
          parsedReviews = decoded.map((e) => WorkerReviewItem.fromJson(e as Map<String, dynamic>)).toList();
        }
      } catch (_) {}
    } else if (json['reviews'] != null && json['reviews'] is List) {
      parsedReviews = (json['reviews'] as List).map((e) => WorkerReviewItem.fromJson(e as Map<String, dynamic>)).toList();
    }

    ExplainableMatchMatrix exp;
    if (json['explainability'] != null && json['explainability'] is Map) {
      exp = ExplainableMatchMatrix.fromJson(json['explainability'] as Map<String, dynamic>);
    } else {
      final score = json['match_score'] as int? ?? 92;
      final dist = (json['distance_km'] as num?)?.toDouble() ?? 1.2;
      exp = ExplainableMatchMatrix(
        skillMatchPercent: 96,
        proximityPercent: (100 - (dist * 3.5)).round().clamp(50, 100),
        availabilityPercent: (json['is_available'] as bool? ?? true) ? 100 : 40,
        workloadFairnessPercent: 84,
        overallMatchScore: score,
        distanceKm: dist,
        reasonSummary: 'High skill match & proximity with verified cooperative certification.',
        reasonSummaryKey: 'matchReasonTopMatch',
      );
    }

    return WorkerMatchModel(
      id: json['id'] as int? ?? 1,
      cooperativeId: json['cooperative_id'] as int? ?? 1,
      fullName: json['full_name'] as String? ?? 'Rahul Sharma',
      fullNameMr: json['full_name_mr'] as String?,
      fullNameHi: json['full_name_hi'] as String?,
      nameKey: json['name_key'] as String? ?? 'defaultWorkerName',
      phoneNumber: json['phone_number'] as String? ?? '+91 98220 12345',
      avatarUrl: json['avatar_url'] as String? ?? 'https://images.unsplash.com/photo-1540569014015-19a7be504e3a',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 18.5074,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 73.8077,
      addressArea: json['address_area'] as String? ?? 'Warje, Pune',
      areaKey: json['area_key'] as String? ?? 'areaWarjePune',
      primaryTrade: json['primary_trade'] as String? ?? 'Plumber',
      tradeSubtitle: json['trade_subtitle'] as String? ?? 'Piping Specialist',
      tradeKey: json['trade_key'] as String? ?? 'tradePipingSpecialist',
      experienceYears: json['experience_years'] as int? ?? 5,
      isAvailable: json['is_available'] as bool? ?? true,
      availabilityStatus: json['availability_status'] as String? ?? 'AVAILABLE_NOW',
      busyUntilText: json['busy_until_text'] as String?,
      ratingAvg: (json['rating_avg'] as num?)?.toDouble() ?? 4.8,
      reviewCount: json['review_count'] as int? ?? 156,
      jobsCompletedCount: json['jobs_completed_count'] as int? ?? 512,
      jobsCompletedThisMonth: json['jobs_completed_this_month'] as int? ?? 14,
      responseTimeMinutes: json['response_time_minutes'] as int? ?? 12,
      avgCompletionTimeMinutes: json['avg_completion_time_minutes'] as int? ?? 35,
      hourlyRateMin: json['hourly_rate_min'] as int? ?? 250,
      hourlyRateMax: json['hourly_rate_max'] as int? ?? 500,
      isVerified: json['is_verified'] as bool? ?? true,
      memberId: json['member_id'] as String? ?? 'SHSC-24567',
      welfareSchemeId: json['welfare_scheme_id'] as String? ?? 'ESHRAM-MH-984210',
      cooperativeSocietyName: json['cooperative_society_name'] as String? ?? 'Shivshakti Cooperative Society Ltd.',
      cooperativeKey: json['cooperative_key'] as String? ?? 'coopShivshakti',
      skills: parsedSkills.isNotEmpty ? parsedSkills : ['Tap Repair', 'Pipe Leakage', 'Bathroom Fitting', 'Flush Repair', 'PVC Pipe Work'],
      certifications: parsedCerts.isNotEmpty ? parsedCerts : [
        const WorkerCertificationItem(title: 'Plumbing Skill (NSDC Certified)', issuer: 'NSDC India'),
        const WorkerCertificationItem(title: 'Water Safety (Govt Certified)', issuer: 'Govt of Maharashtra'),
        const WorkerCertificationItem(title: 'CPR & First Aid Certified', issuer: 'Red Cross Society'),
      ],
      galleryUrls: parsedGallery.isNotEmpty ? parsedGallery : [
        'https://images.unsplash.com/photo-1585704032915-c3400ca199e7',
        'https://images.unsplash.com/photo-1607472586893-edb57bdc0e39',
        'https://images.unsplash.com/photo-1581244277943-fe4a9c777189',
        'https://images.unsplash.com/photo-1504307651254-35680f356dfd',
      ],
      reviews: parsedReviews.isNotEmpty ? parsedReviews : [
        const WorkerReviewItem(
          author: 'Priya Kulkarni',
          authorKey: 'reviewAuthor1',
          rating: 5.0,
          comment: 'Came on time and fixed the tap quickly. Very polite and skilled worker!',
          commentKey: 'reviewComment1',
          date: '2 days ago',
          dateKey: 'reviewDate1',
        ),
        const WorkerReviewItem(
          author: 'Amit Joshi',
          authorKey: 'reviewAuthor2',
          rating: 4.8,
          comment: 'Fixed price and no hidden charges. Cooperative guarantee gives peace of mind.',
          commentKey: 'reviewComment2',
          date: '1 week ago',
          dateKey: 'reviewDate2',
        ),
        const WorkerReviewItem(
          author: 'Sachin Kadam',
          authorKey: 'reviewAuthor3',
          rating: 4.9,
          comment: 'Stopped the pipe leakage completely. Very clean and professional work.',
          commentKey: 'reviewComment3',
          date: '2 weeks ago',
          dateKey: 'reviewDate3',
        ),
      ],
      matchScore: json['match_score'] as int? ?? 92,
      distanceKm: (json['distance_km'] as num?)?.toDouble() ?? 1.2,
      explainability: exp,
    );
  }

  static List<WorkerMatchModel> get fallbackWorkers => [
    const WorkerMatchModel(
      id: 1,
      fullName: 'Rahul Sharma',
      fullNameMr: 'राहुल शर्मा',
      fullNameHi: 'राहुल शर्मा',
      nameKey: 'defaultWorkerName',
      phoneNumber: '+91 98220 12345',
      avatarUrl: 'https://images.unsplash.com/photo-1540569014015-19a7be504e3a',
      latitude: 18.4850,
      longitude: 73.8050,
      addressArea: 'Warje, Pune',
      areaKey: 'areaWarjePune',
      primaryTrade: 'Plumber',
      tradeSubtitle: 'Piping Specialist',
      tradeKey: 'tradePipingSpecialist',
      experienceYears: 6,
      isAvailable: true,
      availabilityStatus: 'AVAILABLE_NOW',
      ratingAvg: 4.8,
      reviewCount: 156,
      jobsCompletedCount: 512,
      responseTimeMinutes: 12,
      hourlyRateMin: 250,
      hourlyRateMax: 500,
      isVerified: true,
      memberId: 'SHSC-24567',
      cooperativeSocietyName: 'Shivshakti Cooperative Society Ltd.',
      cooperativeKey: 'coopShivshakti',
      skills: ['Tap Repair', 'Pipe Leakage', 'Bathroom Fitting', 'Flush Repair', 'PVC Pipe Work'],
      certifications: [
        WorkerCertificationItem(title: 'Plumbing Skill (NSDC Certified)', issuer: 'NSDC India'),
        WorkerCertificationItem(title: 'Water Safety (Govt Certified)', issuer: 'Govt of Maharashtra'),
        WorkerCertificationItem(title: 'CPR & First Aid Certified', issuer: 'Red Cross'),
      ],
      galleryUrls: [
        'https://images.unsplash.com/photo-1585704032915-c3400ca199e7',
        'https://images.unsplash.com/photo-1607472586893-edb57bdc0e39',
        'https://images.unsplash.com/photo-1581244277943-fe4a9c777189',
        'https://images.unsplash.com/photo-1504307651254-35680f356dfd',
      ],
      reviews: [
        WorkerReviewItem(
          author: 'Priya Kulkarni',
          authorKey: 'reviewAuthor1',
          rating: 5.0,
          comment: 'Came on time and fixed the tap quickly. Very polite and skilled worker!',
          commentKey: 'reviewComment1',
          date: '2 days ago',
          dateKey: 'reviewDate1',
        ),
        WorkerReviewItem(
          author: 'Amit Joshi',
          authorKey: 'reviewAuthor2',
          rating: 4.8,
          comment: 'Fixed price and no hidden charges. Cooperative guarantee gives peace of mind.',
          commentKey: 'reviewComment2',
          date: '1 week ago',
          dateKey: 'reviewDate2',
        ),
      ],
      matchScore: 92,
      distanceKm: 1.2,
      explainability: ExplainableMatchMatrix(
        skillMatchPercent: 96,
        proximityPercent: 91,
        availabilityPercent: 100,
        workloadFairnessPercent: 84,
        overallMatchScore: 92,
        distanceKm: 1.2,
        reasonSummary: 'High skill & proximity match with verified cooperative certification.',
        reasonSummaryKey: 'matchReasonTopMatch',
      ),
    ),
    const WorkerMatchModel(
      id: 2,
      fullName: 'Shrikant Patil',
      fullNameMr: 'श्रीकांत पाटील',
      fullNameHi: 'श्रीकांत पाटील',
      phoneNumber: '+91 98220 54321',
      avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d',
      latitude: 18.5020,
      longitude: 73.8120,
      addressArea: 'Kothrud, Pune',
      areaKey: 'areaKothrudPune',
      primaryTrade: 'Plumber',
      tradeSubtitle: 'Tap & Drain Specialist',
      tradeKey: 'tradeTapDrainSpecialist',
      experienceYears: 5,
      isAvailable: true,
      availabilityStatus: 'AVAILABLE_NOW',
      ratingAvg: 4.8,
      reviewCount: 214,
      jobsCompletedCount: 420,
      responseTimeMinutes: 15,
      hourlyRateMin: 250,
      hourlyRateMax: 450,
      isVerified: true,
      memberId: 'SHSC-19842',
      cooperativeSocietyName: 'Shivshakti Cooperative Society Ltd.',
      cooperativeKey: 'coopShivshakti',
      skills: ['Tap Repair', 'Drain Cleaning', 'Sink Installation', 'Leak Detection'],
      certifications: [
        WorkerCertificationItem(title: 'Master Plumber Certification', issuer: 'Govt of Maharashtra'),
      ],
      galleryUrls: [
        'https://images.unsplash.com/photo-1585704032915-c3400ca199e7',
        'https://images.unsplash.com/photo-1607472586893-edb57bdc0e39',
      ],
      reviews: [
        WorkerReviewItem(
          author: 'Sachin Kadam',
          authorKey: 'reviewAuthor3',
          rating: 4.8,
          comment: 'Stopped the pipe leakage completely. Very clean and professional work.',
          commentKey: 'reviewComment3',
          date: '3 days ago',
          dateKey: 'reviewDate1',
        ),
      ],
      matchScore: 89,
      distanceKm: 1.8,
      explainability: ExplainableMatchMatrix(
        skillMatchPercent: 92,
        proximityPercent: 88,
        availabilityPercent: 100,
        workloadFairnessPercent: 78,
        overallMatchScore: 89,
        distanceKm: 1.8,
        reasonSummary: 'Proximity match in Kothrud area within 1.8 km.',
        reasonSummaryKey: 'matchReasonProximityMatch',
      ),
    ),
    const WorkerMatchModel(
      id: 3,
      fullName: 'Sanjay Shinde',
      fullNameMr: 'संजय शिंदे',
      fullNameHi: 'संजय शिंदे',
      phoneNumber: '+91 98220 99887',
      avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e',
      latitude: 18.5200,
      longitude: 73.8300,
      addressArea: 'Shivajinagar, Pune',
      areaKey: 'areaShivajinagarPune',
      primaryTrade: 'Plumber',
      tradeSubtitle: 'Plumbing & Pipe Master',
      tradeKey: 'tradeMasterPlumber',
      experienceYears: 8,
      isAvailable: false,
      availabilityStatus: 'BUSY_UNTIL_AFTERNOON',
      busyUntilText: 'Busy until 4:00 PM',
      ratingAvg: 4.9,
      reviewCount: 310,
      jobsCompletedCount: 680,
      responseTimeMinutes: 20,
      hourlyRateMin: 300,
      hourlyRateMax: 600,
      isVerified: true,
      memberId: 'MSTC-33410',
      cooperativeSocietyName: 'Maharashtra Skilled Technicians Cooperative',
      cooperativeKey: 'coopMaharashtraTech',
      skills: ['Pipe Leakage', 'Water Tank Fitting', 'Bathroom Overhaul'],
      certifications: [
        WorkerCertificationItem(title: 'Senior Plumber Gold Badge', issuer: 'NSDC India'),
      ],
      galleryUrls: [
        'https://images.unsplash.com/photo-1581244277943-fe4a9c777189',
      ],
      reviews: [
        WorkerReviewItem(
          author: 'Amit Joshi',
          authorKey: 'reviewAuthor2',
          rating: 5.0,
          comment: 'Fixed price and no hidden charges. Cooperative guarantee gives peace of mind.',
          commentKey: 'reviewComment2',
          date: '5 days ago',
          dateKey: 'reviewDate2',
        ),
      ],
      matchScore: 86,
      distanceKm: 3.4,
      explainability: ExplainableMatchMatrix(
        skillMatchPercent: 98,
        proximityPercent: 72,
        availabilityPercent: 65,
        workloadFairnessPercent: 88,
        overallMatchScore: 86,
        distanceKm: 3.4,
        reasonSummary: 'Experienced Match - 8 years experience, available after 4:00 PM.',
        reasonSummaryKey: 'matchReasonExperiencedMatch',
      ),
    ),
    const WorkerMatchModel(
      id: 4,
      fullName: 'Prakash More',
      fullNameMr: 'प्रकाश मोरे',
      fullNameHi: 'प्रकाश मोरे',
      phoneNumber: '+91 98220 77665',
      avatarUrl: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e',
      latitude: 18.5100,
      longitude: 73.8600,
      addressArea: 'Hadapsar, Pune',
      areaKey: 'areaHadapsarPune',
      primaryTrade: 'Plumber',
      tradeSubtitle: 'Bathroom & Tap Repair Specialist',
      tradeKey: 'tradeBathroomPlumber',
      experienceYears: 4,
      isAvailable: true,
      availabilityStatus: 'AVAILABLE_NOW',
      ratingAvg: 4.7,
      reviewCount: 98,
      jobsCompletedCount: 260,
      responseTimeMinutes: 25,
      hourlyRateMin: 200,
      hourlyRateMax: 400,
      isVerified: true,
      memberId: 'SSCS-44120',
      cooperativeSocietyName: 'Sahayog Shramjeevi Cooperative Credit Society',
      cooperativeKey: 'coopSahayogShramik',
      skills: ['Tap Repair', 'Geyser Connection', 'Drain Cleaning'],
      certifications: [
        WorkerCertificationItem(title: 'Apprentice Certificate', issuer: 'Maharashtra Skill Board'),
      ],
      galleryUrls: [],
      reviews: [],
      matchScore: 78,
      distanceKm: 4.2,
      explainability: ExplainableMatchMatrix(
        skillMatchPercent: 85,
        proximityPercent: 65,
        availabilityPercent: 100,
        workloadFairnessPercent: 92,
        overallMatchScore: 78,
        distanceKm: 4.2,
        reasonSummary: 'Budget Match - Affordable rate (₹200 - ₹400) and available immediately.',
        reasonSummaryKey: 'matchReasonAffordableMatch',
      ),
    ),
  ];
}

