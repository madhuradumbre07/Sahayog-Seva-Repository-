import 'dart:async';
import 'package:flutter/material.dart';

import '../models/worker_dashboard_data.dart';

class WorkerDashboardProvider extends ChangeNotifier {
  WorkerDashboardProvider() {
    _availability = WorkerAvailability.online;
    _pendingRequests = [JobRequestItem.sample];
    _appointments = List.from(AppointmentItem.defaults);
    _metrics = WorkerMetrics.sample;
    _quickActions = List.from(QuickActionItem.defaults);
    _startCountdownTimer();
  }

  WorkerAvailability _availability = WorkerAvailability.online;
  List<JobRequestItem> _pendingRequests = [];
  List<AppointmentItem> _appointments = [];
  WorkerMetrics _metrics = WorkerMetrics.sample;
  List<QuickActionItem> _quickActions = [];

  int _countdownSeconds = 165; // 02:45
  Timer? _timer;

  WorkerAvailability get availability => _availability;
  List<JobRequestItem> get pendingRequests => List.unmodifiable(_pendingRequests);
  int get pendingRequestsCount => _pendingRequests.length;
  List<AppointmentItem> get appointments => List.unmodifiable(_appointments);
  WorkerMetrics get metrics => _metrics;
  List<QuickActionItem> get quickActions => List.unmodifiable(_quickActions);
  int get countdownSeconds => _countdownSeconds;

  String get formattedCountdown {
    final mins = (_countdownSeconds ~/ 60).toString().padLeft(2, '0');
    final secs = (_countdownSeconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  void _startCountdownTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_countdownSeconds > 0) {
        _countdownSeconds -= 1;
        notifyListeners();
      } else {
        t.cancel();
      }
    });
  }

  void setAvailability(WorkerAvailability newStatus) {
    if (_availability != newStatus) {
      _availability = newStatus;
      notifyListeners();
    }
  }

  void toggleOnlineOffline() {
    if (_availability == WorkerAvailability.online) {
      _availability = WorkerAvailability.offline;
    } else {
      _availability = WorkerAvailability.online;
    }
    notifyListeners();
  }

  void acceptJobRequest(String id) {
    final request = _pendingRequests.firstWhere(
      (r) => r.id == id,
      orElse: () => JobRequestItem.sample,
    );
    _pendingRequests.removeWhere((r) => r.id == id);
    _appointments.insert(
      0,
      AppointmentItem(
        id: 'apt_${DateTime.now().millisecondsSinceEpoch}',
        timeText: '01:00 PM',
        titleKey: request.titleKey,
        location: request.location,
        statusKey: 'statusUpcoming',
        statusColor: const Color(0xFFE65100),
        statusBgColor: const Color(0xFFFFF3E0),
        customerName: request.customerName,
      ),
    );
    _metrics = WorkerMetrics(
      todayEarnings: _metrics.todayEarnings + 350,
      completedJobsToday: _metrics.completedJobsToday,
      monthlyEarnings: _metrics.monthlyEarnings + 350,
      rating: _metrics.rating,
      reviewsCount: _metrics.reviewsCount,
    );
    notifyListeners();
  }

  void rejectJobRequest(String id) {
    _pendingRequests.removeWhere((r) => r.id == id);
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
