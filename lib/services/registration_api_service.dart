import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/registration_data.dart';

import 'package:flutter/foundation.dart';
import 'api_config.dart';

class RegistrationResult {
  final bool success;
  final String? errorMessage;
  final Map<String, dynamic>? data;

  const RegistrationResult({
    required this.success,
    this.errorMessage,
    this.data,
  });
}

class RegistrationApiService {
  String get baseUrl => ApiConfig.baseUrl;
  static const Duration requestTimeout = Duration(seconds: 6);

  final http.Client _client;

  RegistrationApiService({http.Client? client}) : _client = client ?? http.Client();

  /// Registers user in the backend where password is securely hashed and stored in database.
  Future<RegistrationResult> register(RegistrationData data) async {
    try {
      final uri = Uri.parse('$baseUrl/auth/register');
      final payload = jsonEncode(data.toBackendJson());
      debugPrint('[RegistrationApiService] POST $uri -> $payload');

      final response = await _client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: payload,
      ).timeout(requestTimeout);

      debugPrint('[RegistrationApiService] Response (${response.statusCode}): ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final resData = jsonDecode(response.body) as Map<String, dynamic>;
        return RegistrationResult(success: true, data: resData);
      } else if (response.statusCode == 409) {
        final err = jsonDecode(response.body);
        return RegistrationResult(
          success: false,
          errorMessage: err['detail'] as String? ?? 'An account with this mobile number already exists for this role.',
        );
      } else {
        final err = jsonDecode(response.body);
        return RegistrationResult(
          success: false,
          errorMessage: err['detail'] as String? ?? 'Registration failed. Please try again.',
        );
      }
    } catch (e, stack) {
      debugPrint('[RegistrationApiService] Error during register: $e\n$stack');
      // Do not report success when the backend did not persist the profile.
      return RegistrationResult(
        success: false,
        errorMessage: 'Unable to save your profile. Please check the backend connection and try again.',
      );
    }
  }

  /// Fetches saved user profile from backend
  Future<Map<String, dynamic>?> getProfile(String mobile, [String? role]) async {
    try {
      final queryParam = role != null ? '?role=$role' : '';
      final uri = Uri.parse('$baseUrl/auth/profile/$mobile$queryParam');
      debugPrint('[RegistrationApiService] GET $uri');
      final response = await _client.get(uri).timeout(requestTimeout);
      debugPrint('[RegistrationApiService] Profile response (${response.statusCode}): ${response.body}');
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint('[RegistrationApiService] Failed to getProfile: $e');
    }
    return null;
  }

  /// Fetches all registered roles and user profiles for a mobile number from live DB
  Future<List<Map<String, dynamic>>> getUserByMobile(String mobile) async {
    try {
      final cleanMobile = mobile.replaceAll(RegExp(r'\D'), '');
      final uri = Uri.parse('$baseUrl/auth/user/$cleanMobile');
      debugPrint('[RegistrationApiService] GET $uri');
      final response = await _client.get(uri).timeout(requestTimeout);
      debugPrint('[RegistrationApiService] User by mobile response (${response.statusCode}): ${response.body}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['found'] == true && data['users'] != null) {
          return List<Map<String, dynamic>>.from(data['users'] as List);
        }
      }
    } catch (e) {
      debugPrint('[RegistrationApiService] Failed to getUserByMobile: $e');
    }
    return [];
  }

  /// Updates user profile in backend database
  Future<RegistrationResult> updateProfile(RegistrationData data) async {
    try {
      final uri = Uri.parse('$baseUrl/auth/profile/${data.mobile}?role=${data.role.name}');
      final payload = jsonEncode(data.toBackendUpdateJson());

      final response = await _client.put(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: payload,
      ).timeout(requestTimeout);

      if (response.statusCode == 200) {
        final resData = jsonDecode(response.body) as Map<String, dynamic>;
        return RegistrationResult(success: true, data: resData);
      } else {
        final err = jsonDecode(response.body);
        return RegistrationResult(
          success: false,
          errorMessage: err['detail'] as String? ?? 'Failed to update profile.',
        );
      }
    } catch (e, stack) {
      debugPrint('[RegistrationApiService] Error during updateProfile: $e\n$stack');
      return const RegistrationResult(
        success: false,
        errorMessage: 'Unable to update your profile. Please check the backend connection and try again.',
      );
    }
  }
}
