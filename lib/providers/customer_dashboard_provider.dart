import 'dart:async';
import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../models/customer_dashboard_data.dart';

class CustomerDashboardProvider extends ChangeNotifier {
  CustomerDashboardProvider() {
    _services = List.from(PopularServiceItem.defaults);
    _trustFeatures = List.from(TrustFeatureItem.defaults);
    _activeBooking = BookingItem.sample;
    _promo = PromoBannerItem.sample;
  }

  List<PopularServiceItem> _services = [];
  List<TrustFeatureItem> _trustFeatures = [];
  BookingItem? _activeBooking;
  PromoBannerItem? _promo;

  bool _isListeningVoice = false;
  String _aiProblemText = '';
  bool _promoClaimed = false;

  List<PopularServiceItem> get services => List.unmodifiable(_services);
  List<TrustFeatureItem> get trustFeatures => List.unmodifiable(_trustFeatures);
  BookingItem? get activeBooking => _activeBooking;
  PromoBannerItem? get promo => _promo;
  bool get isListeningVoice => _isListeningVoice;
  String get aiProblemText => _aiProblemText;
  bool get promoClaimed => _promoClaimed;

  void setAiProblemText(String text) {
    _aiProblemText = text;
    notifyListeners();
  }

  void toggleVoiceListening([String? langCode]) {
    _isListeningVoice = !_isListeningVoice;
    notifyListeners();
    if (_isListeningVoice) {
      // Simulate speech detection
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
