import 'package:flutter/foundation.dart';

class ApiConfig {
  static String _customBaseUrl = const String.fromEnvironment('API_BASE_URL');

  /// Sets a custom backend base URL (useful for physical devices, remote servers, etc.)
  static void setBaseUrl(String url) {
    _customBaseUrl = _normalize(url);
  }

  /// Automatically resolves the correct backend base URL depending on platform
  static String get baseUrl {
    if (_customBaseUrl.isNotEmpty) {
      return _normalize(_customBaseUrl);
    }

    // Android emulator connects to host machine via 10.0.2.2
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000/api/v1';
    }

    // Windows desktop, macOS, Linux, Chrome Web
    return 'http://localhost:8000/api/v1';
  }

  static String _normalize(String url) {
    return url.trim().replaceFirst(RegExp(r'/+$'), '');
  }

  /// Base URL without /api/v1
  static String get rootUrl {
    final base = baseUrl;
    if (base.endsWith('/api/v1')) {
      return base.substring(0, base.length - '/api/v1'.length);
    }
    return base;
  }
}
