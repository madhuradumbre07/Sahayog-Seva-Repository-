import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import '../services/wallet_api_service.dart';

class WalletProvider extends ChangeNotifier {
  final WalletApiService _apiService;

  WalletProvider({WalletApiService? apiService})
      : _apiService = apiService ?? WalletApiService();

  double _balance = 1250.0;
  List<Map<String, dynamic>> _transactions = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _lastTransactionId;

  double get balance => _balance;
  List<Map<String, dynamic>> get transactions => List.unmodifiable(_transactions);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get lastTransactionId => _lastTransactionId;

  /// Loads live balance and transactions from backend
  Future<void> refreshWallet(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final fetchedBalance = await _apiService.fetchWalletBalance(userId);
      final fetchedTxns = await _apiService.fetchTransactions(userId);

      _balance = fetchedBalance;
      _transactions = fetchedTxns;
    } catch (e) {
      _errorMessage = 'Could not sync wallet data with server.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Processes a complete top-up flow via backend sandbox gateway
  Future<bool> processTopUp({
    required String userId,
    required double amount,
    bool simulateFailure = false,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _lastTransactionId = null;
    notifyListeners();

    try {
      // Step 1: Create Order on Backend
      final orderRes = await _apiService.createOrder(userId, amount);
      final orderId = orderRes['order_id'] as String;
      final mockPaymentId = 'pay_sb_${DateTime.now().millisecondsSinceEpoch}';

      // Compute exact HMAC SHA-256 signature for "$orderId|$mockPaymentId"
      const sandboxSecret = 'sahayogseva_sandbox_secret_2026';
      final hmacKey = Hmac(sha256, utf8.encode(sandboxSecret));
      final validSignature = hmacKey.convert(utf8.encode('$orderId|$mockPaymentId')).toString();

      // Step 2: Send payment payload for verification on backend
      final verifyRes = await _apiService.verifyPayment(
        userId: userId,
        orderId: orderId,
        paymentId: mockPaymentId,
        signature: validSignature,
        simulateFailure: simulateFailure,
      );

      final isSuccess = verifyRes['success'] as bool? ?? false;
      _balance = (verifyRes['new_balance'] as num?)?.toDouble() ?? _balance;
      _lastTransactionId = verifyRes['transaction_id'] as String?;

      if (isSuccess) {
        // Refresh dynamic balance & transaction list from server
        final fetchedBalance = await _apiService.fetchWalletBalance(userId);
        final freshTxns = await _apiService.fetchTransactions(userId);
        _balance = fetchedBalance;
        _transactions = freshTxns;
      } else {
        _errorMessage = verifyRes['message'] as String? ?? 'Payment verification failed.';
        // Re-fetch transactions to record the failed transaction entry
        final freshTxns = await _apiService.fetchTransactions(userId);
        _transactions = freshTxns;
      }

      _isLoading = false;
      notifyListeners();
      return isSuccess;
    } catch (e, stack) {
      debugPrint('[WalletProvider] processTopUp error: $e\n$stack');
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
