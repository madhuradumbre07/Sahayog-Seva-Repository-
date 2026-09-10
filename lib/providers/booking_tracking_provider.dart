import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/booking_tracking_model.dart';
import '../services/matching_api_service.dart';

class BookingTrackingProvider extends ChangeNotifier {
  final MatchingApiService _apiService;
  
  BookingTrackingModel? _trackingData;
  Timer? _pollingTimer;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isInjectedMockData = false;
  
  void setMockDataForTest(BookingTrackingModel mockData) {
    _trackingData = mockData;
    _isInjectedMockData = true;
    _isLoading = false;
    notifyListeners();
  }

  /// Start mock simulation (called when user clicks 'simulate');

  final bool _demoMode;

  BookingTrackingProvider({MatchingApiService? apiService, bool demoMode = false})
      : _apiService = apiService ?? MatchingApiService(),
        _demoMode = demoMode;

  BookingTrackingModel? get trackingData => _trackingData;
  bool get hasInjectedMockData => _isInjectedMockData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  bool get isCompleted => _trackingData?.currentStage == TrackingStage.COMPLETED;
  int get currentStageIndex => _trackingData?.currentStage.stageIndex ?? 0;
  int get stagesCompleted => currentStageIndex;
  int get totalStages => TrackingStage.values.length;

  void resetTracking() {
    stopPolling();
    _trackingData = null;
    _isInjectedMockData = false;
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> fetchTrackingData(String bookingId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _apiService.getBookingTracking(bookingId);
      _trackingData = data.isEmpty
          ? BookingTrackingModel.fallback().copyWith(bookingCode: bookingId)
          : BookingTrackingModel.fromJson(data);
        _isInjectedMockData = false;
    } catch (e) {
      // Fallback
      _trackingData = BookingTrackingModel.fallback().copyWith(bookingCode: bookingId);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void startPolling(String bookingId) {
    stopPolling();
    if (!_isInjectedMockData) {
      fetchTrackingData(bookingId);
    }
    _pollingTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_demoMode && _trackingData != null) {
        _simulateStageProgression();
      } else if (!_isInjectedMockData) {
        fetchTrackingData(bookingId);
      }
    });
  }

  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  void _simulateStageProgression() {
    if (_trackingData == null) return;
    
    final currentIdx = _trackingData!.currentStage.stageIndex;
    if (currentIdx < TrackingStage.values.length - 1) {
      final nextStage = TrackingStage.values[currentIdx + 1];
      _trackingData = _trackingData!.copyWith(currentStage: nextStage);
      notifyListeners();
    } else {
      stopPolling();
    }
  }
  
  @override
  void dispose() {
    stopPolling();
    super.dispose();
  }
}
