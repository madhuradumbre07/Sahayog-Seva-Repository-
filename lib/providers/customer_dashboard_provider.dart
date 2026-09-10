import 'dart:async';
import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../models/customer_dashboard_data.dart';
import '../services/customer_api_service.dart';

class CustomerDashboardProvider extends ChangeNotifier {
  final CustomerApiService _apiService;

  CustomerDashboardProvider({CustomerApiService? apiService})
      : _apiService = apiService ?? CustomerApiService() {
    _services = List.from(PopularServiceItem.defaults);
    _trustFeatures = List.from(TrustFeatureItem.defaults);
    _activeBooking = BookingItem.sample;
    _promo = PromoBannerItem.sample;
  }

  List<PopularServiceItem> _services = [];
  List<TrustFeatureItem> _trustFeatures = [];
  List<BookingItem> _allBookings = [];
  BookingItem? _activeBooking;
  PromoBannerItem? _promo;

  bool _isLoadingBookings = false;
  String? _bookingsError;
  bool _isListeningVoice = false;
  String _aiProblemText = '';
  bool _promoClaimed = false;

  List<PopularServiceItem> get services => List.unmodifiable(_services);
  List<TrustFeatureItem> get trustFeatures => List.unmodifiable(_trustFeatures);
  List<BookingItem> get allBookings => List.unmodifiable(_allBookings);
  List<BookingItem> get activeBookings =>
      _allBookings.where((b) => b.status != BookingStatus.completed && b.status != BookingStatus.cancelled).toList();
  List<BookingItem> get pastBookings =>
      _allBookings.where((b) => b.status == BookingStatus.completed || b.status == BookingStatus.cancelled).toList();

  BookingItem? get activeBooking => _activeBooking;
  PromoBannerItem? get promo => _promo;
  bool get isLoadingBookings => _isLoadingBookings;
  String? get bookingsError => _bookingsError;
  bool get isListeningVoice => _isListeningVoice;
  String get aiProblemText => _aiProblemText;
  bool get promoClaimed => _promoClaimed;

  void setActiveBooking(BookingItem? booking) {
    _activeBooking = booking;
    notifyListeners();
  }

  void setAiProblemText(String text) {
    _aiProblemText = text;
    notifyListeners();
  }

  Future<void> loadCustomerData(String customerId) async {
    _isLoadingBookings = true;
    _bookingsError = null;
    notifyListeners();

    try {
      // Fetch dynamic catalog
      final catalog = await _apiService.fetchServicesCatalog();
      if (catalog.isNotEmpty) {
        _services = catalog;
      }

      // Fetch customer bookings
      final bookings = await _apiService.fetchCustomerBookings(customerId);
      _allBookings = bookings;
      if (bookings.isNotEmpty) {
        final activeList = activeBookings;
        _activeBooking = activeList.isNotEmpty ? activeList.first : null;
      }
    } catch (e) {
      _bookingsError = e.toString();
    } finally {
      _isLoadingBookings = false;
      notifyListeners();
    }
  }

  Future<bool> cancelBooking(String bookingId) async {
    final updated = await _apiService.cancelBooking(bookingId);
    if (updated != null) {
      final index = _allBookings.indexWhere((b) => b.id == bookingId || b.bookingCode == bookingId);
      if (index != -1) {
        _allBookings[index] = updated;
      }
      if (_activeBooking?.id == bookingId || _activeBooking?.bookingCode == bookingId) {
        final activeList = activeBookings;
        _activeBooking = activeList.isNotEmpty ? activeList.first : null;
      }
      notifyListeners();
      return true;
    }
    return false;
  }

  void toggleVoiceListening([String? langCode]) {
    _isListeningVoice = !_isListeningVoice;
    notifyListeners();
    if (_isListeningVoice) {
      // Speech detection simulation for prototype
      Future.delayed(const Duration(seconds: 3), () {
        if (_isListeningVoice) {
          _aiProblemText = AppStringsData.translate('sampleKitchenLeakage', languageCode: langCode ?? 'en');
          _isListeningVoice = false;
          notifyListeners();
        }
      });
    }
  }

  void stopVoiceListening() {
    if (_isListeningVoice) {
      _isListeningVoice = false;
      notifyListeners();
    }
  }

  void claimPromo() {
    _promoClaimed = true;
    notifyListeners();
  }
}
