import 'package:flutter/foundation.dart';
import '../models/service_completion_model.dart';
import '../services/matching_api_service.dart';

class ServiceCompletionProvider extends ChangeNotifier {
  final MatchingApiService _apiService;

  ServiceCompletionModel? _completionData;
  bool _isLoading = false;
  bool _isProcessingPayment = false;
  bool _isSubmittingRating = false;
  bool _isDownloadingInvoice = false;
  String? _errorMessage;
  String? _successMessage;

  ServiceCompletionProvider({MatchingApiService? apiService})
      : _apiService = apiService ?? MatchingApiService();

  ServiceCompletionModel? get completionData => _completionData;
  bool get isLoading => _isLoading;
  bool get isProcessingPayment => _isProcessingPayment;
  bool get isSubmittingRating => _isSubmittingRating;
  bool get isDownloadingInvoice => _isDownloadingInvoice;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  void setMockDataForTest(ServiceCompletionModel mockData) {
    _completionData = mockData;
    _isLoading = false;
    _isProcessingPayment = false;
    _isSubmittingRating = false;
    _isDownloadingInvoice = false;
    notifyListeners();
  }

  void initFromBookingId(String bookingId, {PaymentStatus status = PaymentStatus.paymentPending}) {
    _completionData = ServiceCompletionModel.mock(
      bookingCode: bookingId,
      paymentStatus: status,
    );
    notifyListeners();
  }

  Future<bool> processPayment({
    required String paymentMethod,
    double? amount,
  }) async {
    if (_completionData == null) return false;

    _isProcessingPayment = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final payAmount = amount ?? _completionData!.totalPrice.toDouble();
      final res = await _apiService.processPayment(
        bookingId: _completionData!.bookingCode,
        paymentMethod: paymentMethod,
        amount: payAmount,
      );

      final txnId = res['txn_id'] as String? ?? 'UPIS1987451236';
      final invNo = res['invoice_number'] as String? ?? 'INV-250531-1123';
      final timestamp = res['timestamp'] as String? ?? '31 May 2025, 11:46 AM';

      _completionData = _completionData!.copyWith(
        paymentStatus: PaymentStatus.paymentSuccess,
        paymentMethod: paymentMethod,
        txnId: txnId,
        invoiceNumber: invNo,
        completionTime: timestamp,
      );
      _isProcessingPayment = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isProcessingPayment = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> submitRating({
    required double rating,
    required String reviewText,
  }) async {
    if (_completionData == null) return false;

    _isSubmittingRating = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _apiService.submitRating(
        bookingId: _completionData!.bookingCode,
        workerId: _completionData!.workerId,
        rating: rating,
        reviewText: reviewText,
      );

      _completionData = _completionData!.copyWith(
        paymentStatus: PaymentStatus.rated,
        rating: rating,
        reviewComment: reviewText,
      );
      _isSubmittingRating = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isSubmittingRating = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> downloadInvoice() async {
    if (_completionData == null) return false;

    _isDownloadingInvoice = true;
    notifyListeners();

    try {
      await _apiService.getInvoicePdf(_completionData!.bookingCode);
      await Future.delayed(const Duration(milliseconds: 600)); // Simulated download time
      _isDownloadingInvoice = false;
      notifyListeners();
      return true;
    } catch (_) {
      _isDownloadingInvoice = false;
      notifyListeners();
      return true;
    }
  }
}
