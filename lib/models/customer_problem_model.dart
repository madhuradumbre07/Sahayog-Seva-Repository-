import 'package:flutter/material.dart';

enum InputModeType { text, voice, photo, video }

class LanguageDetectionResult {
  final String code;
  final String displayName;
  final bool isTransliterated;
  final String? contextTag;
  final double confidence;

  const LanguageDetectionResult({
    required this.code,
    required this.displayName,
    this.isTransliterated = false,
    this.contextTag,
    this.confidence = 1.0,
  });
}

class SmartLanguageDetector {
  static const Map<String, String> languageDisplayNames = {
    'en': 'English',
    'hi': 'हिंदी (Hindi)',
    'mr': 'मराठी (Marathi)',
    'gu': 'ગુજરાતી (Gujarati)',
    'ta': 'தமிழ் (Tamil)',
    'te': 'తెలుగు (Telugu)',
    'kn': 'ಕನ್ನಡ (Kannada)',
    'bn': 'বাংলা (Bengali)',
  };

  static String getDisplayName(String code) =>
      languageDisplayNames[code] ?? 'English';

  static const Set<String> _marathiKeywords = {
    'आहे', 'आहेत', 'नाही', 'पाहिजे', 'करा', 'करणे', 'गळत', 'पाणी', 'चालत',
    'करायची', 'करायचा', 'करायचे', 'झाला', 'झाली', 'झाले', 'कसा', 'कशी', 'कसे',
    'नळ', 'लाईट', 'गिझर', 'थंड', 'होतं', 'होती', 'होता', 'खराब', 'दुरुस्त',
    'साफ', 'पाहिजेत', 'येत', 'येतो', 'येते', 'माझं', 'माझी', 'माझे', 'आमचं',
    'घरात', 'बाथरूम', 'किचन', 'गळती', 'विद्युत', 'पाइप', 'तोटी', 'चमकत',
  };

  static const Set<String> _hindiKeywords = {
    'है', 'हैं', 'नहीं', 'होता', 'होती', 'होते', 'रहा', 'रही', 'रहे', 'करना',
    'चाहिए', 'पानी', 'टपक', 'खराब', 'चल', 'ठंडा', 'गया', 'गई', 'गए',
    'हुआ', 'हुई', 'हुए', 'नल', 'लाइट', 'गीज़र', 'साफ', 'मरम्मत', 'बिजली',
    'आता', 'आती', 'आते', 'मेरा', 'मेरी', 'मेरे', 'हमारा', 'घर', 'पाइप',
  };

  static const Set<String> _marathiPhonetics = {
    'galat', 'ahe', 'aahe', 'ahet', 'kasa', 'kashi', 'kase',
    'thambla', 'chalu', 'karaycha', 'karaychi', 'karayche', 'kiti',
    'zalay', 'jhala', 'jhali', 'tutla', 'tutli', 'nalatun', 'gijhar',
    'madhe', 'gharat', 'sanga', 'bagha', 'karun', 'ghari', 'lavkar',
  };

  static const Set<String> _hindiPhonetics = {
    'raha', 'rahi', 'rahe', 'hain', 'karna', 'theek', 'chalta', 'chalti',
    'hua', 'hui', 'gaya', 'gayi', 'nahin', 'karega', 'karegi', 'bhai',
    'bahut', 'jaldi', 'chahiye', 'kuch', 'hoga', 'hogi', 'kripya',
  };

  static const Set<String> _gujaratiPhonetics = {
    'che', 'chhe', 'nathi', 'karvu', 'karo', 'pani', 'bagadi', 'gayun', 'thayun', 'aavu',
  };

  static const Set<String> _tamilPhonetics = {
    'illai', 'irukku', 'pannunga', 'thanni', 'vela', 'sari', 'seiyanum', 'varala',
  };

  static const Set<String> _teluguPhonetics = {
    'ledu', 'undi', 'cheyandi', 'neellu', 'pani', 'bagoledu', 'kavali', 'ravatledu',
  };

  static const Set<String> _kannadaPhonetics = {
    'illa', 'ide', 'madi', 'neeru', 'kelasa', 'agide', 'beku', 'barthilla',
  };

  static const Set<String> _bengaliPhonetics = {
    'hoche', 'hobe', 'hocche', 'jol', 'kaaj', 'kore', 'na', 'thik', 'korche',
  };

  static LanguageDetectionResult detect(String rawText, {String? activeLocaleCode}) {
    final text = rawText.trim();
    final fallbackCode = (activeLocaleCode != null && languageDisplayNames.containsKey(activeLocaleCode))
        ? activeLocaleCode
        : 'en';

    if (text.isEmpty) {
      return LanguageDetectionResult(
        code: fallbackCode,
        displayName: getDisplayName(fallbackCode),
        confidence: 1.0,
      );
    }

    int devanagariCount = 0;
    int gujaratiCount = 0;
    int tamilCount = 0;
    int teluguCount = 0;
    int kannadaCount = 0;
    int bengaliCount = 0;
    int latinCount = 0;
    bool hasMarathiLha = false;

    for (int i = 0; i < text.runes.length; i++) {
      final codeUnit = text.runes.elementAt(i);
      if (codeUnit >= 0x0900 && codeUnit <= 0x097F) {
        devanagariCount++;
        if (codeUnit == 0x0934) { // 'ळ'
          hasMarathiLha = true;
        }
      } else if (codeUnit >= 0x0A80 && codeUnit <= 0x0AFF) {
        gujaratiCount++;
      } else if (codeUnit >= 0x0B80 && codeUnit <= 0x0BFF) {
        tamilCount++;
      } else if (codeUnit >= 0x0C00 && codeUnit <= 0x0C7F) {
        teluguCount++;
      } else if (codeUnit >= 0x0C80 && codeUnit <= 0x0CFF) {
        kannadaCount++;
      } else if (codeUnit >= 0x0980 && codeUnit <= 0x09FF) {
        bengaliCount++;
      } else if ((codeUnit >= 0x0041 && codeUnit <= 0x005A) ||
                 (codeUnit >= 0x0061 && codeUnit <= 0x007A)) {
        latinCount++;
      }
    }

    // Stage A: Unicode Script Pattern Matching
    if (gujaratiCount > 0 && gujaratiCount >= latinCount) {
      return LanguageDetectionResult(
        code: 'gu',
        displayName: getDisplayName('gu'),
        confidence: 0.98,
      );
    }
    if (tamilCount > 0 && tamilCount >= latinCount) {
      return LanguageDetectionResult(
        code: 'ta',
        displayName: getDisplayName('ta'),
        confidence: 0.98,
      );
    }
    if (teluguCount > 0 && teluguCount >= latinCount) {
      return LanguageDetectionResult(
        code: 'te',
        displayName: getDisplayName('te'),
        confidence: 0.98,
      );
    }
    if (kannadaCount > 0 && kannadaCount >= latinCount) {
      return LanguageDetectionResult(
        code: 'kn',
        displayName: getDisplayName('kn'),
        confidence: 0.98,
      );
    }
    if (bengaliCount > 0 && bengaliCount >= latinCount) {
      return LanguageDetectionResult(
        code: 'bn',
        displayName: getDisplayName('bn'),
        confidence: 0.98,
      );
    }

    if (devanagariCount > 0 && devanagariCount >= latinCount) {
      if (hasMarathiLha) {
        return LanguageDetectionResult(
          code: 'mr',
          displayName: getDisplayName('mr'),
          confidence: 0.99,
        );
      }

      final words = text.split(RegExp(r'\s+'));
      int marathiScore = 0;
      int hindiScore = 0;

      for (final w in words) {
        final clean = w.replaceAll(RegExp(r'[^\u0900-\u097F]'), '');
        if (_marathiKeywords.contains(clean)) marathiScore += 2;
        if (_hindiKeywords.contains(clean)) hindiScore += 2;
      }

      if (marathiScore > hindiScore) {
        return LanguageDetectionResult(
          code: 'mr',
          displayName: getDisplayName('mr'),
          confidence: 0.95,
        );
      } else if (hindiScore > marathiScore) {
        return LanguageDetectionResult(
          code: 'hi',
          displayName: getDisplayName('hi'),
          confidence: 0.95,
        );
      } else {
        final devCode = (fallbackCode == 'mr') ? 'mr' : 'hi';
        return LanguageDetectionResult(
          code: devCode,
          displayName: getDisplayName(devCode),
          confidence: 0.85,
        );
      }
    }

    // Stage B: Phonetic & Transliteration matching (for Latin / Roman input)
    if (latinCount > 0) {
      final words = text
          .toLowerCase()
          .split(RegExp(r'[^a-zA-Z]+'))
          .where((w) => w.isNotEmpty)
          .toList();

      int mrPhoneticScore = 0;
      int hiPhoneticScore = 0;
      int guPhoneticScore = 0;
      int taPhoneticScore = 0;
      int tePhoneticScore = 0;
      int knPhoneticScore = 0;
      int bnPhoneticScore = 0;

      for (final w in words) {
        if (_marathiPhonetics.contains(w)) mrPhoneticScore++;
        if (_hindiPhonetics.contains(w)) hiPhoneticScore++;
        if (_gujaratiPhonetics.contains(w)) guPhoneticScore++;
        if (_tamilPhonetics.contains(w)) taPhoneticScore++;
        if (_teluguPhonetics.contains(w)) tePhoneticScore++;
        if (_kannadaPhonetics.contains(w)) knPhoneticScore++;
        if (_bengaliPhonetics.contains(w)) bnPhoneticScore++;
      }

      final maxPhonetic = [
        (mrPhoneticScore, 'mr', 'मराठी (Hinglish/Marathlish Context)'),
        (hiPhoneticScore, 'hi', 'हिंदी (Hinglish Context)'),
        (guPhoneticScore, 'gu', 'ગુજરાતી (Gujarati Context)'),
        (taPhoneticScore, 'ta', 'தமிழ் (Tamil Context)'),
        (tePhoneticScore, 'te', 'తెలుగు (Telugu Context)'),
        (knPhoneticScore, 'kn', 'ಕನ್ನಡ (Kannada Context)'),
        (bnPhoneticScore, 'bn', 'বাংলা (Bengali Context)'),
      ]..sort((a, b) => b.$1.compareTo(a.$1));

      if (maxPhonetic.first.$1 > 0) {
        final matched = maxPhonetic.first;
        return LanguageDetectionResult(
          code: matched.$2,
          displayName: getDisplayName(matched.$2),
          isTransliterated: true,
          contextTag: matched.$3,
          confidence: 0.90,
        );
      }

      return LanguageDetectionResult(
        code: 'en',
        displayName: getDisplayName('en'),
        confidence: 0.95,
      );
    }

    // Stage C: Non-alphabetical fallback to active header locale
    return LanguageDetectionResult(
      code: fallbackCode,
      displayName: getDisplayName(fallbackCode),
      confidence: 1.0,
    );
  }
}

class ProblemMediaItem {
  final String id;
  final String path;
  final String fileName;
  final int fileSizeBytes;
  final int durationSeconds;
  final bool isVideo;

  const ProblemMediaItem({
    required this.id,
    required this.path,
    required this.fileName,
    this.fileSizeBytes = 0,
    this.durationSeconds = 0,
    this.isVideo = false,
  });

  String get formattedSize {
    if (fileSizeBytes <= 0) return '3.2 MB';
    final mb = fileSizeBytes / (1024 * 1024);
    return '${mb.toStringAsFixed(1)} MB';
  }

  String get formattedDuration {
    if (durationSeconds <= 0) return '00:15';
    final mins = (durationSeconds ~/ 60).toString().padLeft(2, '0');
    final secs = (durationSeconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }
}

class AlternativeServiceModel {
  final String id;
  final String title;
  final String matchPercentage;
  final String priceRange;
  final IconData icon;

  const AlternativeServiceModel({
    required this.id,
    required this.title,
    required this.matchPercentage,
    required this.priceRange,
    required this.icon,
  });
}

class ProblemInputModel {
  final String text;
  final InputModeType mode;
  final List<ProblemMediaItem> mediaList;
  final String detectedLanguageCode;
  final String detectedLanguageDisplayName;
  final bool isLanguageManuallyOverridden;

  const ProblemInputModel({
    this.text = '',
    this.mode = InputModeType.text,
    this.mediaList = const [],
    this.detectedLanguageCode = 'en',
    this.detectedLanguageDisplayName = 'English',
    this.isLanguageManuallyOverridden = false,
  });

  String get detectedLanguage => detectedLanguageDisplayName;

  bool get isValid => text.trim().length >= 10 || mediaList.isNotEmpty;

  ProblemInputModel copyWith({
    String? text,
    InputModeType? mode,
    List<ProblemMediaItem>? mediaList,
    String? detectedLanguageCode,
    String? detectedLanguageDisplayName,
    bool? isLanguageManuallyOverridden,
  }) {
    return ProblemInputModel(
      text: text ?? this.text,
      mode: mode ?? this.mode,
      mediaList: mediaList ?? this.mediaList,
      detectedLanguageCode: detectedLanguageCode ?? this.detectedLanguageCode,
      detectedLanguageDisplayName:
          detectedLanguageDisplayName ?? this.detectedLanguageDisplayName,
      isLanguageManuallyOverridden:
          isLanguageManuallyOverridden ?? this.isLanguageManuallyOverridden,
    );
  }
}

class AiAnalysisResultModel {
  final String recognizedProblem;
  final String recognizedProblemSub;
  final double confidenceScore;
  final String suggestedCategory;
  final List<String> tags;
  final List<String> requiredSkills;
  final String estimatedTime;
  final String estimatedPrice;
  final String urgencyLevel;
  final String aiReasoning;
  final List<AlternativeServiceModel> alternatives;
  final ProblemMediaItem? attachedMedia;
  final bool isLowConfidence;
  final bool isMultipleServices;
  final String detectedLanguageCode;

  const AiAnalysisResultModel({
    required this.recognizedProblem,
    required this.recognizedProblemSub,
    required this.confidenceScore,
    required this.suggestedCategory,
    required this.tags,
    required this.requiredSkills,
    required this.estimatedTime,
    required this.estimatedPrice,
    required this.urgencyLevel,
    required this.aiReasoning,
    required this.alternatives,
    this.attachedMedia,
    this.isLowConfidence = false,
    this.isMultipleServices = false,
    this.detectedLanguageCode = 'en',
  });

  String get confidenceLabel {
    final pct = (confidenceScore * 100).toInt();
    if (confidenceScore >= 0.85) return 'High ($pct%)';
    if (confidenceScore >= 0.50) return 'Medium ($pct%)';
    return 'Low ($pct%)';
  }

  Color get confidenceColor {
    if (confidenceScore >= 0.85) return const Color(0xFF2E7D32);
    if (confidenceScore >= 0.50) return const Color(0xFFED6C02);
    return const Color(0xFFD32F2F);
  }

  static AiAnalysisResultModel createDefault({
    String input = 'Water is leaking from tap',
    ProblemMediaItem? media,
    String detectedLanguageCode = 'en',
  }) {
    return AiAnalysisResultModel(
      recognizedProblem: 'sampleIdentifiedText',
      recognizedProblemSub: 'sampleIdentifiedSub',
      confidenceScore: 0.92,
      suggestedCategory: 'suggestedPlumbingTitle',
      tags: const ['Plumbing', 'Leak Repair', 'Faucet Replacement'],
      requiredSkills: const [
        'skillListPlumber',
      ],
      estimatedTime: 'sampleEstTime',
      estimatedPrice: 'sampleEstCost',
      urgencyLevel: 'urgencyMediumText',
      aiReasoning: 'aiReasonText',
      attachedMedia: media,
      detectedLanguageCode: detectedLanguageCode,
      alternatives: const [
        AlternativeServiceModel(
          id: 'alt_1',
          title: 'Pipe Leakage Repair',
          matchPercentage: 'altService1Match',
          priceRange: 'altService1Price',
          icon: Icons.plumbing,
        ),
        AlternativeServiceModel(
          id: 'alt_2',
          title: 'Bathroom Plumbing',
          matchPercentage: 'altService2Match',
          priceRange: 'altService2Price',
          icon: Icons.bathtub_outlined,
        ),
      ],
    );
  }
}
