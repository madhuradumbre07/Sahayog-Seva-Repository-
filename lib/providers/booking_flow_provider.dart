import 'package:flutter/foundation.dart';
import '../models/worker_matching_model.dart';
import '../models/booking_request_model.dart';
import '../services/matching_api_service.dart';

class BookingFlowProvider extends ChangeNotifier {
  final MatchingApiService _apiService;

  BookingFlowProvider({MatchingApiService? apiService})
      : _apiService = apiService ?? MatchingApiService();

  BookingDraftModel _draft = BookingDraftModel();
  bool _isSubmitting = false;
  String? _lastCreatedBookingCode;
  String? _errorMessage;

  BookingDraftModel get draft => _draft;
  bool get isSubmitting => _isSubmitting;
  String? get lastCreatedBookingCode => _lastCreatedBookingCode;
  String? get errorMessage => _errorMessage;

  void initializeForWorker(
    WorkerMatchModel worker, {
    String? category,
    String? subcategory,
    String? problemDescription,
  }) {
    _draft = _draft.copyWith(
      worker: worker,
      serviceCategory: category ?? 'Plumbing',
      serviceSubcategory: subcategory ?? 'Tap & Faucet Repair',
      problemDescription: problemDescription ?? _draft.problemDescription,
      basePrice: worker.hourlyRateMin > 0 ? worker.hourlyRateMin : 350,
      totalPrice: worker.hourlyRateMin > 0 ? worker.hourlyRateMin : 350,
    );
    notifyListeners();
  }

  void updateAddress(AddressItem address) {
    _draft = _draft.copyWith(selectedAddress: address);
    notifyListeners();
  }

  void updateDate(DateTime date) {
    _draft = _draft.copyWith(scheduledDate: date);
    notifyListeners();
  }

  void updateTimeSlot(String slot) {
    _draft = _draft.copyWith(timeSlot: slot);
    notifyListeners();
  }

  void updateInstructions(String instructions) {
    _draft = _draft.copyWith(specialInstructions: instructions);
    notifyListeners();
  }

  void updateWorker(WorkerMatchModel worker) {
    _draft = _draft.copyWith(
      worker: worker,
      basePrice: worker.hourlyRateMin,
      totalPrice: worker.hourlyRateMin,
    );
    notifyListeners();
  }

  Future<bool> submitBooking() async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final code = await _apiService.createBooking(_draft);
      _lastCreatedBookingCode = code;
      _draft = _draft.copyWith(bookingCode: code);
      _isSubmitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Booking creation failed. Please try again.';
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }
}
