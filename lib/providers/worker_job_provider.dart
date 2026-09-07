import 'dart:async';

import 'package:flutter/material.dart';

import '../models/worker_job_model.dart';
import '../services/worker_job_api_service.dart';

class WorkerJobProvider extends ChangeNotifier {
  final WorkerJobApiService _apiService;

  WorkerJobProvider({WorkerJobApiService? apiService})
      : _apiService = apiService ?? WorkerJobApiService() {
    _countdownSeconds = _job.countdownSeconds;
  }

  WorkerJobDetailModel _job = WorkerJobDetailModel.sample;
  bool _isLoading = false;
  Object? _error;
  int _countdownSeconds = 165;
  Timer? _timer;

  WorkerJobDetailModel get job => _job;
  bool get isLoading => _isLoading;
  Object? get error => _error;
  int get countdownSeconds => _countdownSeconds;
  JobRequestState get currentState => _job.state;
  WorkerJobLifecycleState get lifecycleState => _job.lifecycleState;

  String get formattedCountdown {
    final mins = (_countdownSeconds ~/ 60).toString().padLeft(2, '0');
    final secs = (_countdownSeconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  void startCountdownTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdownSeconds > 0) {
        _countdownSeconds -= 1;
        if (_countdownSeconds <= 30 && _job.state == JobRequestState.normal) {
          _job = _job.copyWith(state: JobRequestState.expiring);
        }
        notifyListeners();
      } else {
        _job = _job.copyWith(state: JobRequestState.expired);
        timer.cancel();
        notifyListeners();
      }
    });
  }

  void stopCountdownTimer() => _timer?.cancel();

  Future<void> refreshJob() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _job = await _apiService.fetchJobDetails(_job.id);
      _countdownSeconds = _job.countdownSeconds;
    } catch (error) {
      _error = error;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> transitionTo(WorkerJobLifecycleState next) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final state = await _apiService.updateStatus(_job.id, next);
      _job = _job.copyWith(
        lifecycleState: state,
        state: state == WorkerJobLifecycleState.rejected
            ? JobRequestState.youRejected
            : state == WorkerJobLifecycleState.accepted
                ? JobRequestState.youAccepted
                : _job.state,
      );
      return true;
    } catch (error) {
      _error = error;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> verifyOtp(String otp) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final state = await _apiService.verifyOtp(_job.id, otp);
      _job = _job.copyWith(lifecycleState: state);
      return true;
    } catch (error) {
      _error = error;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setJob(WorkerJobDetailModel newJob) {
    _job = newJob;
    _countdownSeconds = newJob.countdownSeconds;
    notifyListeners();
  }

  void setRequestState(JobRequestState state) {
    _job = _job.copyWith(
      state: state,
      lifecycleState: state == JobRequestState.youAccepted
          ? WorkerJobLifecycleState.accepted
          : state == JobRequestState.youRejected
              ? WorkerJobLifecycleState.rejected
              : _job.lifecycleState,
    );
    if (state == JobRequestState.expired ||
        state == JobRequestState.youAccepted ||
        state == JobRequestState.youRejected ||
        state == JobRequestState.acceptedByOther) {
      stopCountdownTimer();
    }
    notifyListeners();
  }

  Future<bool> acceptJob() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final success = await _apiService.acceptJob(_job.id);
      if (success) {
        stopCountdownTimer();
        _job = _job.copyWith(
          state: JobRequestState.youAccepted,
          lifecycleState: WorkerJobLifecycleState.accepted,
        );
      }
      return success;
    } catch (error) {
      _error = error;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> rejectJob() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final success = await _apiService.rejectJob(_job.id);
      if (success) {
        stopCountdownTimer();
        _job = _job.copyWith(
          state: JobRequestState.youRejected,
          lifecycleState: WorkerJobLifecycleState.rejected,
        );
      }
      return success;
    } catch (error) {
      _error = error;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> releaseAcceptedJob() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final success = await _apiService.releaseAcceptedJob(_job.id);
      if (success) {
        _job = _job.copyWith(
          state: JobRequestState.normal,
          lifecycleState: WorkerJobLifecycleState.newRequest,
        );
      }
      return success;
    } catch (error) {
      _error = error;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> decideLater() async => true;

  void resetToSample() {
    stopCountdownTimer();
    _job = WorkerJobDetailModel.sample;
    _countdownSeconds = _job.countdownSeconds;
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    stopCountdownTimer();
    super.dispose();
  }
}
