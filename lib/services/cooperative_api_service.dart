import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/cooperative_dashboard_data.dart';
import 'api_config.dart';

class CooperativeApiService {
  final http.Client _client;
  static const Duration requestTimeout = Duration(seconds: 8);

  CooperativeApiService({http.Client? client}) : _client = client ?? http.Client();

  String get baseUrl => ApiConfig.baseUrl;

  /// Fetches live dashboard data directly from FastAPI backend database
  Future<CooperativeDashboardData> getDashboard({int cooperativeId = 1}) async {
    try {
      final uri = Uri.parse('$baseUrl/cooperative/dashboard?cooperative_id=$cooperativeId');
      debugPrint('[CooperativeApiService] GET $uri');
      final response = await _client.get(uri).timeout(requestTimeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        return CooperativeDashboardData.fromJson(json);
      } else {
        debugPrint('[CooperativeApiService] Failed response code: ${response.statusCode}');
        throw Exception('Failed to load dashboard from backend (${response.statusCode})');
      }
    } catch (e) {
      debugPrint('[CooperativeApiService] Error fetching dashboard: $e');
      // Return empty default or rethrow
      rethrow;
    }
  }

  /// Assigns a worker to a job request
  Future<bool> assignWorker({
    required String requestId,
    required int workerId,
    String? notes,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/cooperative/assign');
      final payload = jsonEncode({
        'request_id': requestId,
        'worker_id': workerId,
        'notes': notes,
      });
      debugPrint('[CooperativeApiService] POST $uri -> $payload');

      final response = await _client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: payload,
      ).timeout(requestTimeout);

      if (response.statusCode == 200) {
        return true;
      }
    } catch (e) {
      debugPrint('[CooperativeApiService] Assign error: $e');
    }
    return false;
  }

  /// Fetches available workers for assignment
  Future<List<Map<String, dynamic>>> getWorkers({int cooperativeId = 1, String? trade}) async {
    try {
      final queryParam = trade != null ? '&trade=$trade' : '';
      final uri = Uri.parse('$baseUrl/cooperative/workers?cooperative_id=$cooperativeId$queryParam');
      final response = await _client.get(uri).timeout(requestTimeout);
      if (response.statusCode == 200) {
        final list = jsonDecode(utf8.decode(response.bodyBytes)) as List;
        return list.map((e) => e as Map<String, dynamic>).toList();
      }
    } catch (e) {
      debugPrint('[CooperativeApiService] Get workers error: $e');
    }
    return [];
  }
}
