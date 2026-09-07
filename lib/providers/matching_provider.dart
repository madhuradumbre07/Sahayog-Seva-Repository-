import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/worker_matching_model.dart';
import '../services/matching_api_service.dart';

enum MatchingStage {
  understandingService,
  matchingSkills,
  findingWorkers,
  selectingBestMatches,
  completed,
  error,
}

class MatchingProvider extends ChangeNotifier {
  final MatchingApiService _apiService;

  MatchingProvider({MatchingApiService? apiService})
      : _apiService = apiService ?? MatchingApiService();

  bool _isLoading = true;
  MatchingStage _stage = MatchingStage.understandingService;
  List<WorkerMatchModel> _workers = [];
  WorkerMatchModel? _selectedWorker;
  String _serviceCategory = 'Plumbing';
  String _serviceSubcategory = 'Tap & Faucet Repair';

  // Metrics
  int _totalSearched = 124;
  int _matchedCount = 36;
  int _topPicksCount = 8;

  // View state
  bool _isMapView = false;

  // Filter state
  double _maxDistanceKm = 20.0;
  double _minRating = 0.0;
  int _minExperience = 0;
  bool _onlyAvailable = false;
  String _sortBy = 'MATCH_SCORE'; // MATCH_SCORE, NEAREST, PRICE_LOW, RATING_HIGH, EXPERIENCE_HIGH

  // Getters
  bool get isLoading => _isLoading;
  MatchingStage get stage => _stage;
  List<WorkerMatchModel> get workers => _workers;
  WorkerMatchModel? get selectedWorker => _selectedWorker;
  String get serviceCategory => _serviceCategory;
  String get serviceSubcategory => _serviceSubcategory;
  int get totalSearched => _totalSearched;
  int get matchedCount => _matchedCount;
  int get topPicksCount => _topPicksCount;
  bool get isMapView => _isMapView;
  double get maxDistanceKm => _maxDistanceKm;
  double get minRating => _minRating;
  int get minExperience => _minExperience;
  bool get onlyAvailable => _onlyAvailable;
  String get sortBy => _sortBy;

  void toggleViewMode() {
    _isMapView = !_isMapView;
    notifyListeners();
  }

  void selectWorker(WorkerMatchModel worker) {
    _selectedWorker = worker;
    notifyListeners();
  }

  void updateFilters({
    double? maxDistanceKm,
    double? minRating,
    int? minExperience,
    bool? onlyAvailable,
  }) {
    if (maxDistanceKm != null) _maxDistanceKm = maxDistanceKm;
    if (minRating != null) _minRating = minRating;
    if (minExperience != null) _minExperience = minExperience;
    if (onlyAvailable != null) _onlyAvailable = onlyAvailable;
    refreshSearch();
  }

  void updateSort(String sortBy) {
    _sortBy = sortBy;
    refreshSearch();
  }

  void resetFilters() {
    _maxDistanceKm = 20.0;
    _minRating = 0.0;
    _minExperience = 0;
    _onlyAvailable = false;
    _sortBy = 'MATCH_SCORE';
    refreshSearch();
  }

  Future<void> startSearch({
    String serviceCategory = 'Plumbing',
    String serviceSubcategory = 'Tap & Faucet Repair',
    double customerLat = 18.4800,
    double customerLon = 73.8000,
  }) async {
    _serviceCategory = serviceCategory;
    _serviceSubcategory = serviceSubcategory;
    _isLoading = true;
    _stage = MatchingStage.understandingService;
    notifyListeners();

    // Stage 1
    await Future.delayed(const Duration(milliseconds: 350));
    _stage = MatchingStage.matchingSkills;
    notifyListeners();

    // Stage 2
    await Future.delayed(const Duration(milliseconds: 400));
    _stage = MatchingStage.findingWorkers;
    notifyListeners();

    // Stage 3 & API Call
    final fetched = await _apiService.findWorkers(
      latitude: customerLat,
      longitude: customerLon,
      serviceCategory: _serviceCategory,
      serviceSubcategory: _serviceSubcategory,
      maxDistanceKm: _maxDistanceKm,
      minRating: _minRating,
      minExperience: _minExperience,
      onlyAvailable: _onlyAvailable,
      sortBy: _sortBy,
    );

    await Future.delayed(const Duration(milliseconds: 350));
    _stage = MatchingStage.selectingBestMatches;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 300));
    _workers = fetched;
    _totalSearched = 124;
    _matchedCount = fetched.length;
    _topPicksCount = fetched.where((w) => w.matchScore >= 85).length;
    _isLoading = false;
    _stage = MatchingStage.completed;
    if (_workers.isNotEmpty && _selectedWorker == null) {
      _selectedWorker = _workers.first;
    }
    notifyListeners();
  }

  Future<void> refreshSearch() async {
    _isLoading = true;
    notifyListeners();

    final fetched = await _apiService.findWorkers(
      serviceCategory: _serviceCategory,
      serviceSubcategory: _serviceSubcategory,
      maxDistanceKm: _maxDistanceKm,
      minRating: _minRating,
      minExperience: _minExperience,
      onlyAvailable: _onlyAvailable,
      sortBy: _sortBy,
    );

    _workers = fetched;
    _matchedCount = fetched.length;
    _topPicksCount = fetched.where((w) => w.matchScore >= 85).length;
    _isLoading = false;
    notifyListeners();
  }
}
