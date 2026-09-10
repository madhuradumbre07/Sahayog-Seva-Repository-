import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/worker_job_model.dart';
import 'api_config.dart';

class WorkerJobApiService {
  static const requestTimeout = Duration(seconds: 8);

  final http.Client _client;

  WorkerJobApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<WorkerJobDetailModel>> fetchPendingJobs({String? workerId}) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/worker/jobs/requests/pending').replace(
      queryParameters: workerId != null && workerId.isNotEmpty ? {'worker_id': workerId} : null,
    );
    final response = await _client.get(uri).timeout(requestTimeout);
    _ensureSuccess(response);
    return (jsonDecode(response.body) as List<dynamic>)
        .map((item) => WorkerJobDetailModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<WorkerJobDetailModel> fetchJobDetails(String jobId) async {
    final response = await _client
        .get(Uri.parse('${ApiConfig.baseUrl}/worker/jobs/$jobId'))
        .timeout(requestTimeout);
    _ensureSuccess(response);
    return WorkerJobDetailModel.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<WorkerJobLifecycleState> updateStatus(
    String jobId,
    WorkerJobLifecycleState status,
  ) async {
    final response = await _client
        .patch(
          Uri.parse('${ApiConfig.baseUrl}/worker/jobs/$jobId/status'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'status': status.apiValue}),
        )
        .timeout(requestTimeout);
    _ensureSuccess(response);
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return WorkerJobLifecycleState.fromApi(data['status'] as String);
  }

  Future<WorkerJobLifecycleState> verifyOtp(String jobId, String otp) async {
    final response = await _client
        .post(
          Uri.parse('${ApiConfig.baseUrl}/worker/jobs/$jobId/verify-otp'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'otp': otp}),
        )
        .timeout(requestTimeout);
    _ensureSuccess(response);
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return WorkerJobLifecycleState.fromApi(data['status'] as String);
  }

  Future<bool> acceptJob(String jobId) async {
    final response = await _client
        .post(
          Uri.parse('${ApiConfig.rootUrl}/api/v1/jobs/$jobId/accept'),
          headers: {'Content-Type': 'application/json'},
        )
        .timeout(requestTimeout);
    _ensureSuccess(response);
    return (jsonDecode(response.body) as Map<String, dynamic>)['success'] == true;
  }

  Future<bool> rejectJob(String jobId) async {
    final response = await _client
        .post(
          Uri.parse('${ApiConfig.rootUrl}/api/v1/jobs/$jobId/reject'),
          headers: {'Content-Type': 'application/json'},
        )
        .timeout(requestTimeout);
    _ensureSuccess(response);
    return (jsonDecode(response.body) as Map<String, dynamic>)['success'] == true;
  }

  Future<bool> releaseAcceptedJob(String jobId) async {
    final response = await _client
        .post(
          Uri.parse('${ApiConfig.baseUrl}/worker/jobs/$jobId/release'),
          headers: {'Content-Type': 'application/json'},
        )
        .timeout(requestTimeout);
    _ensureSuccess(response);
    return true;
  }

  Future<bool> decideLater(String jobId) async => true;

  void _ensureSuccess(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError('Worker job API failed (${response.statusCode})');
    }
  }
}
