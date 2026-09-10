import 'dart:async';
import 'package:flutter/material.dart';
import '../l10n/l10n.dart';
import '../models/customer_problem_model.dart';
import '../services/customer_api_service.dart';

class CustomerProblemProvider extends ChangeNotifier {
  final CustomerApiService _apiService;

  CustomerProblemProvider({CustomerApiService? apiService})
      : _apiService = apiService ?? CustomerApiService();

  InputModeType _activeMode = InputModeType.text;
  String _draftText = '';
  List<ProblemMediaItem> _mediaList = [];
  ProblemMediaItem? _videoItem;

  // Smart Language Detection State
  String _detectedLanguageCode = 'en';
  String _detectedLanguageDisplayName = 'English';
  bool _isLanguageManuallyOverridden = false;
  LanguageDetectionResult? _detectionResult;

  // Voice recording simulation
  bool _isRecordingVoice = false;
  int _voiceRecordingSeconds = 0;
  Timer? _voiceTimer;

  // AI Analysis simulation
  bool _isAnalyzing = false;
  double _analysisProgress = 0.0;
  int _analysisStepIndex = 0;
  AiAnalysisResultModel? _analysisResult;
  AlternativeServiceModel? _selectedAlternative;
  bool _hasCustomAlternativeSelected = false;

  // Getters
  InputModeType get activeMode => _activeMode;
  String get draftText => _draftText;
  List<ProblemMediaItem> get mediaList => _mediaList;
  ProblemMediaItem? get videoItem => _videoItem;
  String get detectedLanguageCode => _detectedLanguageCode;
  String get detectedLanguageDisplayName => _detectedLanguageDisplayName;
  String get detectedLanguage => _detectedLanguageDisplayName;
  bool get isLanguageManuallyOverridden => _isLanguageManuallyOverridden;
  LanguageDetectionResult? get detectionResult => _detectionResult;
  bool get isRecordingVoice => _isRecordingVoice;
  int get voiceRecordingSeconds => _voiceRecordingSeconds;
  bool get isAnalyzing => _isAnalyzing;
  double get analysisProgress => _analysisProgress;
  int get analysisStepIndex => _analysisStepIndex;
  AiAnalysisResultModel? get analysisResult => _analysisResult;
  AlternativeServiceModel? get selectedAlternative => _selectedAlternative;
  bool get hasCustomAlternativeSelected => _hasCustomAlternativeSelected;

  bool get canAnalyze =>
      _draftText.trim().length >= 10 ||
      _mediaList.isNotEmpty ||
      _videoItem != null;

  void setMode(InputModeType mode) {
    _activeMode = mode;
    notifyListeners();
  }

  void detectLanguage(String text, {String? activeLocaleCode}) {
    if (_isLanguageManuallyOverridden) return;

    final res = SmartLanguageDetector.detect(
      text,
      activeLocaleCode: activeLocaleCode,
    );
    _detectedLanguageCode = res.code;
    _detectedLanguageDisplayName = res.displayName;
    _detectionResult = res;
    notifyListeners();
  }

  void setManualLanguageOverride(String langCode) {
    _isLanguageManuallyOverridden = true;
    _detectedLanguageCode = langCode;
    _detectedLanguageDisplayName =
        SmartLanguageDetector.getDisplayName(langCode);
    _detectionResult = LanguageDetectionResult(
      code: langCode,
      displayName: _detectedLanguageDisplayName,
      confidence: 1.0,
    );
    notifyListeners();
  }

  void resetLanguageOverride({String? activeLocaleCode}) {
    _isLanguageManuallyOverridden = false;
    detectLanguage(_draftText, activeLocaleCode: activeLocaleCode);
  }

  void setText(String text, {String? activeLocaleCode}) {
    _draftText = text;
    if (!_isLanguageManuallyOverridden) {
      detectLanguage(text, activeLocaleCode: activeLocaleCode);
    } else {
      notifyListeners();
    }
  }

  void applyExampleChip(String chipText, {String? activeLocaleCode}) {
    _draftText = chipText;
    _activeMode = InputModeType.text;
    if (!_isLanguageManuallyOverridden) {
      detectLanguage(chipText, activeLocaleCode: activeLocaleCode);
    } else {
      notifyListeners();
    }
  }

  void startVoiceRecording() {
    _isRecordingVoice = true;
    _voiceRecordingSeconds = 0;
    _voiceTimer?.cancel();
    _voiceTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _voiceRecordingSeconds++;
      if (_voiceRecordingSeconds >= 30) {
        stopVoiceRecording();
      }
      notifyListeners();
    });
    notifyListeners();
  }

  void stopVoiceRecording({String? activeLocaleCode}) {
    _voiceTimer?.cancel();
    _isRecordingVoice = false;
    _draftText = AppStringsData.translate('sampleKitchenLeakage', languageCode: activeLocaleCode ?? 'en');
    if (!_isLanguageManuallyOverridden) {
      detectLanguage(_draftText, activeLocaleCode: activeLocaleCode ?? 'en');
    } else {
      notifyListeners();
    }
  }

  void addSamplePhoto([String? customName]) {
    final count = _mediaList.length + 1;
    final item = ProblemMediaItem(
      id: 'photo_${DateTime.now().millisecondsSinceEpoch}',
      path: 'assets/sample_leak.jpg',
      fileName: customName ?? 'leak_photo_$count.jpg',
      fileSizeBytes: 2 * 1024 * 1024,
    );
    _mediaList = [..._mediaList, item];
    notifyListeners();
  }

  void removePhoto(String id) {
    _mediaList = _mediaList.where((m) => m.id != id).toList();
    notifyListeners();
  }

  void addSampleVideo() {
    _videoItem = const ProblemMediaItem(
      id: 'video_sample_1',
      path: 'assets/sample_video.mp4',
      fileName: 'video_2025_05_12.mp4',
      fileSizeBytes: 3355443, // 3.2 MB
      durationSeconds: 15,
      isVideo: true,
    );
    notifyListeners();
  }

  void removeVideo() {
    _videoItem = null;
    notifyListeners();
  }

  Future<void> runAiAnalysis({bool fast = false}) async {
    _isAnalyzing = true;
    _analysisProgress = 0.0;
    _analysisStepIndex = 0;
    notifyListeners();

    // Trigger backend AI parsing concurrently
    final parseFuture = _apiService.parseProblem(
      text: _draftText.isNotEmpty ? _draftText : 'Water is leaking from tap',
      languageCode: _detectedLanguageCode,
      mediaAttached: _mediaList.isNotEmpty || _videoItem != null,
    );

    final stepDuration = fast ? 100 : 350;

    for (int i = 0; i <= 3; i++) {
      _analysisStepIndex = i;
      _analysisProgress = (i + 1) / 4.0;
      notifyListeners();
      await Future.delayed(Duration(milliseconds: stepDuration));
    }

    Map<String, dynamic>? parsed;
    try {
      parsed = await parseFuture;
    } catch (_) {}

    if (parsed != null) {
      final category = (parsed['service_category'] ?? 'Plumbing').toString();
      final subcategory = (parsed['subcategory'] ?? 'Tap & Faucet Repair').toString();
      final explanation = (parsed['explanation'] ?? 'AI diagnosed issue based on description.').toString();
      final skills = (parsed['suggested_skills'] as List?)?.map((s) => s.toString()).toList() ?? ['skillListPlumber'];
      final minCost = parsed['estimated_cost_min'] ?? 200;
      final maxCost = parsed['estimated_cost_max'] ?? 450;
      final minTime = parsed['estimated_time_min'] ?? 30;
      final maxTime = parsed['estimated_time_max'] ?? 60;
      final score = (parsed['confidence_score'] as num?)?.toDouble() ?? 0.92;

      _analysisResult = AiAnalysisResultModel(
        recognizedProblem: subcategory,
        recognizedProblemSub: explanation,
        confidenceScore: score,
        suggestedCategory: category == 'Plumbing' ? 'suggestedPlumbingTitle' : category,
        tags: [category, subcategory, ...skills],
        requiredSkills: skills,
        estimatedTime: '$minTime-$maxTime mins',
        estimatedPrice: '₹$minCost - ₹$maxCost',
        urgencyLevel: parsed['urgency'] == 'HIGH' || parsed['urgency'] == 'EMERGENCY'
            ? 'urgencyHighText'
            : 'urgencyMediumText',
        aiReasoning: explanation,
        attachedMedia: _mediaList.isNotEmpty ? _mediaList.first : _videoItem,
        detectedLanguageCode: _detectedLanguageCode,
        alternatives: [
          AlternativeServiceModel(
            id: 'alt_1',
            title: '$subcategory Inspection & Repair',
            matchPercentage: '95%',
            priceRange: '₹$minCost - ₹$maxCost',
            icon: Icons.plumbing,
          ),
          AlternativeServiceModel(
            id: 'alt_2',
            title: '$category Comprehensive Maintenance',
            matchPercentage: '85%',
            priceRange: '₹${(minCost as num).toInt() + 100} - ₹${(maxCost as num).toInt() + 200}',
            icon: Icons.handyman,
          ),
        ],
      );
    } else {
      _analysisResult = AiAnalysisResultModel.createDefault(
        input: _draftText.isNotEmpty ? _draftText : 'Water is leaking from tap',
        media: _mediaList.isNotEmpty ? _mediaList.first : _videoItem,
        detectedLanguageCode: _detectedLanguageCode,
      );
    }

    _isAnalyzing = false;
    notifyListeners();
  }

  void selectAlternative(AlternativeServiceModel alt) {
    _selectedAlternative = alt;
    _hasCustomAlternativeSelected = true;
    notifyListeners();
  }

  void resetAlternativeSelection() {
    _selectedAlternative = null;
    _hasCustomAlternativeSelected = false;
    notifyListeners();
  }

  void clearAll({String? activeLocaleCode}) {
    _draftText = '';
    _mediaList = [];
    _videoItem = null;
    _isRecordingVoice = false;
    _analysisResult = null;
    _selectedAlternative = null;
    _hasCustomAlternativeSelected = false;
    _isLanguageManuallyOverridden = false;
    _voiceTimer?.cancel();
    final fallbackCode = (activeLocaleCode != null &&
            SmartLanguageDetector.languageDisplayNames
                .containsKey(activeLocaleCode))
        ? activeLocaleCode
        : 'en';
    _detectedLanguageCode = fallbackCode;
    _detectedLanguageDisplayName =
        SmartLanguageDetector.getDisplayName(fallbackCode);
    _detectionResult = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _voiceTimer?.cancel();
    super.dispose();
  }
}
