import 'package:flutter/foundation.dart';
import '../services/worker_profile_api_service.dart';

class WorkerProfileProvider extends ChangeNotifier {
  final WorkerProfileApiService _apiService;

  WorkerProfileProvider({WorkerProfileApiService? apiService})
      : _apiService = apiService ?? WorkerProfileApiService();

  Map<String, dynamic>? _currentProfile;
  List<Map<String, dynamic>> _pendingWorkers = [];
  bool _isLoading = false;
  String? _errorMessage;

  Map<String, dynamic>? get currentProfile => _currentProfile;
  List<Map<String, dynamic>> get pendingWorkers => List.unmodifiable(_pendingWorkers);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  String get verificationStatus {
    return _currentProfile?['verification_status'] as String? ?? 'NOT_REGISTERED';
  }

  /// Loads profile for the given user ID
  Future<void> loadProfile(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final profile = await _apiService.fetchWorkerProfile(userId);
      _currentProfile = profile;
    } catch (e) {
      _errorMessage = 'Failed to load worker profile.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Registers a new worker profile
  Future<bool> registerWorker({
    required String userId,
    required String fullName,
    required String mobile,
    required List<String> skills,
    required int experienceYears,
    int? cooperativeId,
    List<String>? certifications,
    String? email,
    String? location,
    String? idToken,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final profile = await _apiService.registerWorker(
        userId: userId,
        fullName: fullName,
        mobile: mobile,
        skills: skills,
        experienceYears: experienceYears,
        cooperativeId: cooperativeId,
        certifications: certifications,
        email: email,
        location: location,
        idToken: idToken,
      );
      _currentProfile = profile;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Loads pending worker applications queue for admins
  Future<void> loadPendingQueue() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final list = await _apiService.fetchPendingWorkers();
      _pendingWorkers = list;
    } catch (e) {
      _errorMessage = 'Failed to fetch pending workers.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Verifies or rejects a worker application
  Future<bool> verifyWorker({
    required String workerId,
    required String newStatus,
    String? rejectionReason,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updated = await _apiService.verifyWorker(
        workerId: workerId,
        verificationStatus: newStatus,
        rejectionReason: rejectionReason,
        role: 'admin',
      );

      // Update in pending list
      final idx = _pendingWorkers.indexWhere((w) => w['user_id'] == workerId || '${w['id']}' == workerId);
      if (idx != -1) {
        if (newStatus == 'VERIFIED' || newStatus == 'REJECTED') {
          _pendingWorkers.removeAt(idx);
        } else {
          _pendingWorkers[idx] = updated;
        }
      }

      if (_currentProfile != null && (_currentProfile!['user_id'] == workerId || '${_currentProfile!['id']}' == workerId)) {
        _currentProfile = updated;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Updates profile in PostgreSQL
  Future<bool> updateProfile({
    required String workerId,
    String? fullName,
    String? mobile,
    String? email,
    String? location,
    List<String>? skills,
    int? experienceYears,
    int? cooperativeId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updated = await _apiService.updateWorkerProfile(
        workerId: workerId,
        fullName: fullName,
        mobile: mobile,
        email: email,
        location: location,
        skills: skills,
        experienceYears: experienceYears,
        cooperativeId: cooperativeId,
      );
      _currentProfile = updated;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
