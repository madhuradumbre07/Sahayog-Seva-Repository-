import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class WorkerProfileApiService {
  final http.Client _client;

  WorkerProfileApiService({http.Client? client}) : _client = client ?? http.Client();

  String _detailFromBody(http.Response res) {
    try {
      final err = json.decode(res.body);
      if (err is Map && err['detail'] != null) return err['detail'].toString();
    } catch (_) {}
    if (res.statusCode == 405) {
      return 'Method Not Allowed for ${res.request?.method} ${res.request?.url}. Use POST /api/v1/workers/register.';
    }
    return 'Request failed with HTTP ${res.statusCode}';
  }

  /// Registers a new worker profile on backend via POST /api/v1/workers/register
  Future<Map<String, dynamic>> registerWorker({
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
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/workers/register');
      final payload = <String, dynamic>{
        'user_id': userId,
        'full_name': fullName,
        'mobile': mobile,
        'email': email,
        'location': location,
        'skills': skills,
        'experience_years': experienceYears,
        'cooperative_id': cooperativeId,
        'certifications': certifications,
      }..removeWhere((key, value) => value == null);

      final headers = <String, String>{
        'Content-Type': 'application/json',
        'X-User-Id': userId,
      };
      if (idToken != null && idToken.isNotEmpty) {
        headers['Authorization'] = 'Bearer $idToken';
      }

      debugPrint('[WorkerProfileApiService] POST $url');
      final res = await _client.post(
        url,
        headers: headers,
        body: json.encode(payload),
      ).timeout(const Duration(seconds: 10));

      if (res.statusCode == 201 || res.statusCode == 200) {
        return json.decode(res.body) as Map<String, dynamic>;
      }
      throw Exception(_detailFromBody(res));
    } catch (e) {
      debugPrint('[WorkerProfileApiService] registerWorker error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> fetchDashboard(String workerOrUserId) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/workers/$workerOrUserId/dashboard');
      final res = await _client.get(url).timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        return json.decode(res.body) as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint('[WorkerProfileApiService] fetchDashboard error: $e');
    }
    return null;
  }

  Future<Map<String, dynamic>> updateAvailability({
    required String workerId,
    required String availabilityStatus,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/workers/$workerId/availability');
    final res = await _client.patch(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'availability_status': availabilityStatus}),
    ).timeout(const Duration(seconds: 10));
    if (res.statusCode == 200) {
      return json.decode(res.body) as Map<String, dynamic>;
    }
    throw Exception(_detailFromBody(res));
  }

  /// Fetches worker profile by ID or authenticated user_id
  Future<Map<String, dynamic>?> fetchWorkerProfile(String workerOrUserId) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/workers/$workerOrUserId');
      final res = await _client.get(url).timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        return json.decode(res.body);
      }
    } catch (e) {
      debugPrint('[WorkerProfileApiService] fetchWorkerProfile error: $e');
    }
    return null;
  }

  /// Fetches pending/under-review workers for admin verification
  Future<List<Map<String, dynamic>>> fetchPendingWorkers() async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/workers/pending');
      final res = await _client.get(url).timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final List list = json.decode(res.body);
        return list.cast<Map<String, dynamic>>();
      }
    } catch (e) {
      debugPrint('[WorkerProfileApiService] fetchPendingWorkers error: $e');
    }
    return [];
  }

  /// Updates payment verification status (Admin / Cooperative action)
  Future<Map<String, dynamic>> verifyWorker({
    required String workerId,
    required String verificationStatus,
    String? rejectionReason,
    String role = 'admin',
  }) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/workers/$workerId/verify');
      final payload = <String, dynamic>{
        'verification_status': verificationStatus,
        'rejection_reason': rejectionReason,
      }..removeWhere((key, value) => value == null);

      final res = await _client.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'X-User-Role': role,
        },
        body: json.encode(payload),
      ).timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        return json.decode(res.body);
      }
      throw Exception(_detailFromBody(res));
    } catch (e) {
      debugPrint('[WorkerProfileApiService] verifyWorker error: $e');
      rethrow;
    }
  }

  /// Updates an existing worker profile in PostgreSQL
  Future<Map<String, dynamic>> updateWorkerProfile({
    required String workerId,
    String? fullName,
    String? mobile,
    String? email,
    String? location,
    List<String>? skills,
    int? experienceYears,
    int? cooperativeId,
  }) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/workers/$workerId');
      final payload = <String, dynamic>{
        'full_name': fullName,
        'mobile': mobile,
        'email': email,
        'location': location,
        'skills': skills,
        'experience_years': experienceYears,
        'cooperative_id': cooperativeId,
      }..removeWhere((key, value) => value == null);

      final res = await _client.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payload),
      ).timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        return json.decode(res.body);
      }
      throw Exception(_detailFromBody(res));
    } catch (e) {
      debugPrint('[WorkerProfileApiService] updateWorkerProfile error: $e');
      rethrow;
    }
  }
}
