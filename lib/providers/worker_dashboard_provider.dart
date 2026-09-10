import 'dart:async';
import 'package:flutter/material.dart';

import '../models/worker_dashboard_data.dart';
import '../models/worker_job_model.dart';
import '../services/worker_job_api_service.dart';
import '../services/worker_profile_api_service.dart';

class WorkerDashboardProvider extends ChangeNotifier {
  WorkerDashboardProvider({
    WorkerJobApiService? jobApi,
    WorkerProfileApiService? profileApi,
  })  : _jobApi = jobApi ?? WorkerJobApiService(),
        _profileApi = profileApi ?? WorkerProfileApiService();

  final WorkerJobApiService _jobApi;
  final WorkerProfileApiService _profileApi;

  WorkerAvailability _availability = WorkerAvailability.offline;
  List<JobRequestItem> _pendingRequests = [];
  List<AppointmentItem> _appointments = [];
  WorkerMetrics _metrics = WorkerMetrics.empty;
  Map<String, dynamic>? _profile;
  String? _workerId;
  bool _isLoading = false;
  String? _errorMessage;

  WorkerAvailability get availability => _availability;
  List<JobRequestItem> get pendingRequests => List.unmodifiable(_pendingRequests);
  int get pendingRequestsCount => _pendingRequests.length;
  List<AppointmentItem> get appointments => List.unmodifiable(_appointments);
  WorkerMetrics get metrics => _metrics;
  Map<String, dynamic>? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  String get formattedCountdown {
    if (_pendingRequests.isEmpty) return '00:00';
    final seconds = _pendingRequests.first.initialCountdownSeconds;
    final mins = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  Future<void> loadDashboard(String workerId) async {
    if (workerId.isEmpty) return;
    _workerId = workerId;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final data = await _profileApi.fetchDashboard(workerId);
      if (data != null) {
        _profile = data['profile'] as Map<String, dynamic>?;
        final metricsJson = data['metrics'] as Map<String, dynamic>? ?? {};
        _metrics = WorkerMetrics(
          todayEarnings: (metricsJson['today_earnings'] as num?)?.toInt() ?? 0,
          completedJobsToday: (metricsJson['completed_jobs_today'] as num?)?.toInt() ?? 0,
          monthlyEarnings: (metricsJson['monthly_earnings'] as num?)?.toInt() ?? 0,
          rating: (metricsJson['rating'] as num?)?.toDouble() ?? 0,
          reviewsCount: (metricsJson['reviews_count'] as num?)?.toInt() ?? 0,
        );
        final pendingJson = (data['pending_jobs'] as List?) ?? [];
        _pendingRequests = pendingJson
            .map((e) => JobRequestItem.fromJob(WorkerJobDetailModel.fromJson(e as Map<String, dynamic>)))
            .toList();
        final aptJson = (data['appointments'] as List?) ?? [];
        _appointments = aptJson
            .map((e) => AppointmentItem.fromJob(WorkerJobDetailModel.fromJson(e as Map<String, dynamic>)))
            .toList();
        final avail = (_profile?['availability_status'] as String? ?? 'OFFLINE').toUpperCase();
        _availability = avail == 'AVAILABLE_NOW' || avail == 'ONLINE'
            ? WorkerAvailability.online
            : avail == 'BUSY'
                ? WorkerAvailability.busy
                : WorkerAvailability.offline;
      } else {
        _pendingRequests = [];
        _appointments = [];
        _metrics = WorkerMetrics.empty;
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setAvailability(WorkerAvailability newStatus) async {
    if (_availability == newStatus) return;
    _availability = newStatus;
    notifyListeners();
    final workerId = _workerId;
    if (workerId == null || workerId.isEmpty) return;
    final apiStatus = switch (newStatus) {
      WorkerAvailability.online => 'AVAILABLE_NOW',
      WorkerAvailability.busy => 'BUSY',
      WorkerAvailability.offline => 'OFFLINE',
    };
    try {
      await _profileApi.updateAvailability(workerId: workerId, availabilityStatus: apiStatus);
    } catch (_) {
      // Keep optimistic local status; next loadDashboard will resync.
    }
  }

  Future<void> toggleOnlineOffline() async {
    await setAvailability(
      _availability == WorkerAvailability.online
          ? WorkerAvailability.offline
          : WorkerAvailability.online,
    );
  }

  Future<bool> acceptJobRequest(String id) async {
    try {
      final success = await _jobApi.acceptJob(id);
      if (success) {
        JobRequestItem? request;
        for (final item in _pendingRequests) {
          if (item.id == id) {
            request = item;
            break;
          }
        }
        _pendingRequests.removeWhere((r) => r.id == id);
        if (request != null) {
          _appointments.insert(0, AppointmentItem.fromRequest(request));
        }
        notifyListeners();
        if (_workerId != null) await loadDashboard(_workerId!);
      }
      return success;
    } catch (_) {
      return false;
    }
  }

  Future<bool> rejectJobRequest(String id) async {
    try {
      final success = await _jobApi.rejectJob(id);
      if (success) {
        _pendingRequests.removeWhere((r) => r.id == id);
        notifyListeners();
      }
      return success;
    } catch (_) {
      return false;
    }
  }

  /// Test helper: injects a request without hitting the network.
  void debugSetPendingRequests(List<JobRequestItem> requests) {
    _pendingRequests = List.from(requests);
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
