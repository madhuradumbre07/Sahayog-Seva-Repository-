import 'package:flutter/material.dart';
import '../models/cooperative_dashboard_data.dart';
import '../services/cooperative_api_service.dart';

class CooperativeDashboardProvider extends ChangeNotifier {
  final CooperativeApiService _apiService;

  CooperativeDashboardProvider({CooperativeApiService? apiService})
      : _apiService = apiService ?? CooperativeApiService();

  bool _isLoading = false;
  String? _errorMessage;
  CooperativeDashboardData? _dashboardData;
  CooperativeTab _selectedTab = CooperativeTab.dashboard;
  int _selectedAnalyticsTab = 0; // 0 = Service Demand, 1 = Worker Availability
  String _earningsFilter = 'thisMonth';
  List<Map<String, dynamic>> _availableWorkers = [];
  bool _isLoadingWorkers = false;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  CooperativeDashboardData? get dashboardData => _dashboardData;
  CooperativeTab get selectedTab => _selectedTab;
  int get selectedAnalyticsTab => _selectedAnalyticsTab;
  String get earningsFilter => _earningsFilter;
  List<Map<String, dynamic>> get availableWorkers => _availableWorkers;
  bool get isLoadingWorkers => _isLoadingWorkers;

  void setSelectedTab(CooperativeTab tab) {
    if (_selectedTab != tab) {
      _selectedTab = tab;
      notifyListeners();
    }
  }

  void setSelectedAnalyticsTab(int index) {
    if (_selectedAnalyticsTab != index) {
      _selectedAnalyticsTab = index;
      notifyListeners();
    }
  }

  void setEarningsFilter(String filter) {
    if (_earningsFilter != filter) {
      _earningsFilter = filter;
      notifyListeners();
    }
  }

  /// Loads dashboard data directly from the live FastAPI backend PostgreSQL/SQLite database
  Future<void> loadDashboard({int cooperativeId = 1, bool showLoading = true}) async {
    if (showLoading) {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
    }

    try {
      final data = await _apiService.getDashboard(cooperativeId: cooperativeId);
      _dashboardData = data;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      // If error occurs, create a resilient fallback from models
      _dashboardData ??= const CooperativeDashboardData();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetches available workers for assignment modal
  Future<void> fetchAvailableWorkers({String? trade}) async {
    _isLoadingWorkers = true;
    notifyListeners();
    try {
      final workers = await _apiService.getWorkers(trade: trade);
      _availableWorkers = workers;
    } catch (e) {
      debugPrint('[CooperativeDashboardProvider] error loading workers: $e');
      _availableWorkers = [];
    } finally {
      _isLoadingWorkers = false;
      notifyListeners();
    }
  }

  /// Assigns a worker to a job request with optimistic UI update
  Future<bool> assignWorker({
    required String requestId,
    required int workerId,
    required String workerName,
    String? notes,
  }) async {
    // Optimistically update the item in the list
    if (_dashboardData != null) {
      final updatedRequests = _dashboardData!.jobRequests.map((req) {
        if (req.id == requestId) {
          return CooperativeJobRequestModel(
            id: req.id,
            serviceTitleKey: req.serviceTitleKey,
            serviceCategory: req.serviceCategory,
            area: req.area,
            timeAgoKey: req.timeAgoKey,
            timeAgoMins: req.timeAgoMins,
            priority: req.priority,
            status: 'ASSIGNED',
            iconName: req.iconName,
            estimatedPriceMin: req.estimatedPriceMin,
            estimatedPriceMax: req.estimatedPriceMax,
            customerName: req.customerName,
            customerPhone: req.customerPhone,
          );
        }
        return req;
      }).toList();

      _dashboardData = CooperativeDashboardData(
        societyId: _dashboardData!.societyId,
        societyName: _dashboardData!.societyName,
        societyNameMr: _dashboardData!.societyNameMr,
        location: _dashboardData!.location,
        taglineKey: _dashboardData!.taglineKey,
        communityBadgeKey: _dashboardData!.communityBadgeKey,
        mottoBadgeKey: _dashboardData!.mottoBadgeKey,
        notificationsCount: _dashboardData!.notificationsCount,
        kpiMetrics: _dashboardData!.kpiMetrics,
        jobRequests: updatedRequests,
        serviceDemand: _dashboardData!.serviceDemand,
        workerAvailability: _dashboardData!.workerAvailability,
        earningsOverview: _dashboardData!.earningsOverview,
        recentAssignments: _dashboardData!.recentAssignments,
        cooperativeMembers: _dashboardData!.cooperativeMembers,
        upcomingJobs: _dashboardData!.upcomingJobs,
        quickActions: _dashboardData!.quickActions,
      );
      notifyListeners();
    }

    final success = await _apiService.assignWorker(
      requestId: requestId,
      workerId: workerId,
      notes: notes,
    );

    // Refresh live in background
    loadDashboard(showLoading: false);
    return success;
  }
}
