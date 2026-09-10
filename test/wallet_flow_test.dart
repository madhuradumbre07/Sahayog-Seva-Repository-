import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:sahayogseva/providers/auth_provider.dart';
import 'package:sahayogseva/providers/language_provider.dart';
import 'package:sahayogseva/providers/registration_provider.dart';
import 'package:sahayogseva/providers/wallet_provider.dart';
import 'package:sahayogseva/screens/dashboard/customer/customer_profile_view.dart';
import 'package:sahayogseva/services/wallet_api_service.dart';
import 'package:sahayogseva/widgets/wallet_top_up_modal.dart';
import 'package:sahayogseva/widgets/wallet_transactions_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockWalletApiService extends WalletApiService {
  double mockBalance = 1250.0;
  final List<Map<String, dynamic>> mockTxns = [];

  @override
  Future<double> fetchWalletBalance(String userId) async {
    return mockBalance;
  }

  @override
  Future<List<Map<String, dynamic>>> fetchTransactions(String userId) async {
    return mockTxns;
  }

  @override
  Future<Map<String, dynamic>> createOrder(String userId, double amount) async {
    return {
      'order_id': 'ord_sb_mock_123',
      'amount': amount,
      'currency': 'INR',
      'signature_hash': 'sig_valid_mock_hash',
      'sandbox_key': 'sb_key_test_sahayogseva',
    };
  }

  @override
  Future<Map<String, dynamic>> verifyPayment({
    required String userId,
    required String orderId,
    required String paymentId,
    required String signature,
    bool simulateFailure = false,
  }) async {
    if (simulateFailure) {
      mockTxns.insert(0, {
        'id': mockTxns.length + 1,
        'transaction_id': 'TXN_WAL_FAIL_MOCK',
        'user_id': userId,
        'order_id': orderId,
        'amount': 500.0,
        'transaction_type': 'CREDIT',
        'status': 'FAILED',
        'payment_method': 'SANDBOX_GATEWAY',
        'description': 'Wallet Top-Up Failed (Simulated)',
        'balance_after': mockBalance,
        'created_at': '2026-09-08 10:00 AM',
      });
      return {
        'success': false,
        'new_balance': mockBalance,
        'message': 'Simulated gateway verification failure.',
      };
    }

    mockBalance += 500.0;
    mockTxns.insert(0, {
      'id': mockTxns.length + 1,
      'transaction_id': 'TXN_WAL_SUCCESS_MOCK',
      'user_id': userId,
      'order_id': orderId,
      'amount': 500.0,
      'transaction_type': 'CREDIT',
      'status': 'SUCCESS',
      'payment_method': 'SANDBOX_GATEWAY',
      'description': 'Wallet Top-Up of ₹500.00 via Payment Gateway',
      'balance_after': mockBalance,
      'created_at': '2026-09-08 10:05 AM',
    });

    return {
      'success': true,
      'new_balance': mockBalance,
      'transaction_id': 'TXN_WAL_SUCCESS_MOCK',
      'message': 'Wallet loaded successfully!',
    };
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    LanguageProvider.skipNativeConnectivity = true;
    SharedPreferences.setMockInitialValues({'selected_language': 'en'});
  });

  group('Wallet Flow & Sandbox Gateway Integration Tests', () {
    testWidgets('CustomerProfileView displays dynamic wallet balance and opens top-up modal', (tester) async {
      final mockApi = MockWalletApiService();
      final walletProvider = WalletProvider(apiService: mockApi);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => LanguageProvider()..init()),
            ChangeNotifierProvider(create: (_) => AuthProvider()),
            ChangeNotifierProvider(create: (_) => RegistrationProvider()),
            ChangeNotifierProvider<WalletProvider>.value(value: walletProvider),
          ],
          child: const MaterialApp(
            home: Scaffold(body: CustomerProfileView()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check balance rendered from WalletProvider (defaults to ₹ 1250.00)
      expect(find.textContaining('1250.00'), findsOneWidget);

      // Tap Add Money button
      final addMoneyBtn = find.text('Add Money');
      expect(addMoneyBtn, findsOneWidget);
      await tester.tap(addMoneyBtn);
      await tester.pumpAndSettle();

      // Verify WalletTopUpModal is opened
      expect(find.text('Add Money to Wallet'), findsOneWidget);
      expect(find.text('Sandbox Test Mode'), findsOneWidget);
      expect(find.text('Proceed to Pay ₹500'), findsOneWidget);
    });

    testWidgets('WalletTopUpModal handles successful payment flow and updates balance', (tester) async {
      final mockApi = MockWalletApiService();
      final walletProvider = WalletProvider(apiService: mockApi);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => LanguageProvider()..init()),
            ChangeNotifierProvider(create: (_) => AuthProvider()),
            ChangeNotifierProvider(create: (_) => RegistrationProvider()),
            ChangeNotifierProvider<WalletProvider>.value(value: walletProvider),
          ],
          child: const MaterialApp(
            home: Scaffold(body: WalletTopUpModal()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Proceed to Pay ₹500
      final payBtn = find.text('Proceed to Pay ₹500');
      expect(payBtn, findsOneWidget);
      await tester.tap(payBtn);
      await tester.pump(); // Start async request

      await tester.pumpAndSettle();

      // Verify success status banner
      expect(find.textContaining('added successfully to your wallet'), findsOneWidget);
      expect(walletProvider.balance, 1750.0);

      // Flush 2-second pop timer
      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('WalletTransactionsSheet displays double-entry transaction history ledger', (tester) async {
      final mockApi = MockWalletApiService();
      mockApi.mockTxns.add({
        'id': 1,
        'transaction_id': 'TXN_WAL_998877',
        'user_id': 'CUST-9842',
        'order_id': 'ord_sb_001',
        'amount': 500.0,
        'transaction_type': 'CREDIT',
        'status': 'SUCCESS',
        'payment_method': 'SANDBOX_GATEWAY',
        'description': 'Wallet Top-Up via Payment Gateway',
        'balance_after': 1750.0,
        'created_at': '2026-09-08 10:00 AM',
      });

      final walletProvider = WalletProvider(apiService: mockApi);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => LanguageProvider()..init()),
            ChangeNotifierProvider(create: (_) => AuthProvider()),
            ChangeNotifierProvider(create: (_) => RegistrationProvider()),
            ChangeNotifierProvider<WalletProvider>.value(value: walletProvider),
          ],
          child: const MaterialApp(
            home: Scaffold(body: WalletTransactionsSheet()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Ledger Header & Transaction Item Details
      expect(find.text('Payment & Wallet History'), findsOneWidget);
      expect(find.text('Double-entry transaction ledger'), findsOneWidget);
      expect(find.text('Wallet Top-Up via Payment Gateway'), findsOneWidget);
      expect(find.text('+₹500.00'), findsOneWidget);
      expect(find.text('Balance after: ₹1750.00'), findsOneWidget);
      expect(find.text('SUCCESS'), findsOneWidget);
    });
  });
}
