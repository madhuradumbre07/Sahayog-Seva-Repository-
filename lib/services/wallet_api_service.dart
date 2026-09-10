import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class WalletApiService {
  final http.Client _client;

  WalletApiService({http.Client? client}) : _client = client ?? http.Client();

  /// Fetches the user's current wallet balance
  Future<double> fetchWalletBalance(String userId) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/wallet/balance/$userId');
      final res = await _client.get(url).timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        return (data['balance'] as num).toDouble();
      } else {
        debugPrint('[WalletApiService] fetchWalletBalance HTTP ${res.statusCode}: ${res.body}');
      }
    } catch (e, stack) {
      debugPrint('[WalletApiService] Error fetching wallet balance: $e\n$stack');
    }
    return 1250.0; // Default fallback balance if offline
  }

  /// Fetches transaction ledger history
  Future<List<Map<String, dynamic>>> fetchTransactions(String userId) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/wallet/transactions/$userId');
      final res = await _client.get(url).timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final List list = json.decode(res.body);
        return list.cast<Map<String, dynamic>>();
      } else {
        debugPrint('[WalletApiService] fetchTransactions HTTP ${res.statusCode}: ${res.body}');
      }
    } catch (e, stack) {
      debugPrint('[WalletApiService] Error fetching wallet transactions: $e\n$stack');
    }
    return [];
  }

  /// Creates a sandbox payment order on backend
  Future<Map<String, dynamic>> createOrder(String userId, double amount) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/wallet/create-order');
      debugPrint('[WalletApiService] POST $url for user_id=$userId, amount=$amount');
      final res = await _client
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'user_id': userId, 'amount': amount}),
          )
          .timeout(const Duration(seconds: 10));

      debugPrint('[WalletApiService] createOrder HTTP ${res.statusCode}: ${res.body}');

      if (res.statusCode == 201 || res.statusCode == 200) {
        return json.decode(res.body);
      } else {
        throw Exception('Server returned HTTP ${res.statusCode}: ${res.body}');
      }
    } catch (e, stack) {
      debugPrint('[WalletApiService] Error creating wallet order: $e\n$stack');
      rethrow;
    }
  }

  /// Verifies payment on backend and updates ledger
  Future<Map<String, dynamic>> verifyPayment({
    required String userId,
    required String orderId,
    required String paymentId,
    required String signature,
    bool simulateFailure = false,
  }) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/wallet/verify-payment');
      debugPrint('[WalletApiService] POST $url orderId=$orderId paymentId=$paymentId');
      final res = await _client
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'user_id': userId,
              'order_id': orderId,
              'gateway_payment_id': paymentId,
              'gateway_signature': signature,
              'simulate_failure': simulateFailure,
            }),
          )
          .timeout(const Duration(seconds: 10));

      debugPrint('[WalletApiService] verifyPayment HTTP ${res.statusCode}: ${res.body}');

      if (res.statusCode == 200) {
        return json.decode(res.body);
      } else {
        return {
          'success': false,
          'message': 'HTTP ${res.statusCode} verification error: ${res.body}',
        };
      }
    } catch (e, stack) {
      debugPrint('[WalletApiService] Error verifying wallet payment: $e\n$stack');
      return {
        'success': false,
        'new_balance': 1250.0,
        'message': 'Network or server error during payment verification: $e'
      };
    }
  }
}
