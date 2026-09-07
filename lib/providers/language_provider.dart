import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/l10n.dart';
import '../models/app_language.dart';

class LanguageProvider extends ChangeNotifier {
  LanguageProvider({
    this._preferences,
    Connectivity? connectivity,
  }) : _connectivity = connectivity ?? Connectivity();

  static bool skipNativeConnectivity = false;
  static const selectedLanguageKey = 'selected_language';

  SharedPreferences? _preferences;
  final Connectivity _connectivity;

  String? _languageCode;
  bool _isOnline = true;
  bool _isSettingLanguage = false;
  bool _initialized = false;

  String? get languageCode => _languageCode;
  bool get hasLanguage => _languageCode != null;
  bool get isOnline => _isOnline;
  bool get isSettingLanguage => _isSettingLanguage;
  bool get isInitialized => _initialized;
  Locale get locale => Locale(_languageCode ?? 'en');
  AppStrings get strings => AppStrings(_languageCode ?? 'en');

  Future<void> init() async {
    await loadSavedLanguage();
    await checkConnectivity();
    _initialized = true;
    notifyListeners();
  }

  Future<void> loadSavedLanguage() async {
    try {
      _preferences ??= await SharedPreferences.getInstance();
      final saved = _preferences!.getString(selectedLanguageKey);
      if (saved != null && AppLanguage.supportedCodes.contains(saved)) {
        _languageCode = saved;
      }
    } catch (_) {
      // Prefs unavailable (e.g. tests without a mock) — keep in-memory state.
    }
    notifyListeners();
  }

  Future<void> setLanguage(String langCode) async {
    if (!AppLanguage.supportedCodes.contains(langCode)) return;
    _languageCode = langCode;
    notifyListeners();
    await saveLanguage();
  }

  Future<void> saveLanguage() async {
    if (_languageCode == null) return;
    try {
      _preferences ??= await SharedPreferences.getInstance();
      await _preferences!.setString(selectedLanguageKey, _languageCode!);
    } catch (_) {
      // Persistence is best-effort; UI locale still updates in memory.
    }
  }

  Future<void> applyLanguageWithLoading(String langCode) async {
    _isSettingLanguage = true;
    notifyListeners();
    await setLanguage(langCode);
    await Future<void>.delayed(const Duration(milliseconds: 700));
    _isSettingLanguage = false;
    notifyListeners();
  }

  /// Returns `true` when a usable network interface is available.
  Future<bool> checkConnectivity() async {
    if (skipNativeConnectivity) {
      _isOnline = true;
      notifyListeners();
      return _isOnline;
    }
    try {
      final results = await _connectivity.checkConnectivity();
      _isOnline = results.any((result) => result != ConnectivityResult.none);
    } catch (_) {
      _isOnline = true;
    }
    notifyListeners();
    return _isOnline;
  }
}
