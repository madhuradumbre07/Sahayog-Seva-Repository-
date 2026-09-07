import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/l10n.dart';
import '../models/workspace_role.dart';

import '../services/registration_api_service.dart';

enum OtpVerifyResult { success, invalid, expired, locked }

class AuthProvider extends ChangeNotifier {
  AuthProvider({this._preferences, RegistrationApiService? apiService})
    : _apiService = apiService ?? RegistrationApiService();

  static const phoneKey = 'auth_phone';
  static const rolesKey = 'selected_roles';
  static const activeRoleKey = 'active_workspace_role';
  static const languageKey = 'selected_language';
  static const isRegisteredGlobalKey = 'is_registered_global';
  static const demoOtp = '123456';
  static const otpLength = 6;
  static const resendSeconds = 45;
  static const maxAttempts = 5;
  static const lockDuration = Duration(minutes: 15);

  SharedPreferences? _preferences;
  final RegistrationApiService _apiService;

  String _phoneDigits = '';
  Locale _currentLocale = const Locale('en');
  DateTime? _otpExpiresAt;
  DateTime? _lockedUntil;
  int _sendAttempts = 0;
  int _verifyAttempts = 0;
  final Set<WorkspaceRoleId> _selectedRoles = {};
  WorkspaceRoleId _activeRole = WorkspaceRoleId.customer;
  bool _googleLoading = false;
  String? _expectedOtp;
  String _registeredCustomerName = '';
  String _registeredWorkerName = '';
  String _registeredCooperativeName = '';
  String _registeredRepresentativeName = '';
  String _registeredEmail = '';
  final Map<WorkspaceRoleId, bool> _registeredRoles = {};
  String? _profileSyncInProgressFor;

  String get phoneDigits => _phoneDigits;
  String get formattedPhone {
    if (_phoneDigits.length != 10) return '+91 $_phoneDigits';
    return '+91 ${_phoneDigits.substring(0, 5)} ${_phoneDigits.substring(5)}';
  }

  Locale get currentLocale => _currentLocale;
  Locale get activeLocale => _currentLocale;
  String get languageCode => _currentLocale.languageCode;

  WorkspaceRoleId get activeRole => _activeRole;
  String get customerName => _registeredCustomerName.isNotEmpty
      ? _registeredCustomerName
      : AppStringsData.translate(
          'defaultCustomerName',
          languageCode: _currentLocale.languageCode,
        );
  String get workerName => _registeredWorkerName.isNotEmpty
      ? _registeredWorkerName
      : AppStringsData.translate(
          'defaultWorkerName',
          languageCode: _currentLocale.languageCode,
        );
  String get cooperativeName => _registeredCooperativeName.isNotEmpty
      ? _registeredCooperativeName
      : 'Shivneri Seva';
  String get representativeName => _registeredRepresentativeName.isNotEmpty
      ? _registeredRepresentativeName
      : '';
  String get registeredEmail => _registeredEmail;
  String get workerTradeSubtitle => AppStringsData.translate(
    'defaultWorkerTradeSubtitle',
    languageCode: _currentLocale.languageCode,
  );
  double get workerRating => 4.8;
  int get workerReviewCount => 156;
  bool get isWorkerVerified => true;

  bool isRoleRegistered(WorkspaceRoleId role) =>
      _registeredRoles[role] ?? false;
  bool get isCurrentRoleRegistered => isRoleRegistered(_activeRole);
  bool get isAnyRoleRegistered => _registeredRoles.values.any((v) => v);

  String localizedCustomerName(BuildContext context) =>
      _registeredCustomerName.isNotEmpty
      ? _registeredCustomerName
      : context.tr('defaultCustomerName');
  String localizedWorkerName(BuildContext context) =>
      _registeredWorkerName.isNotEmpty
      ? _registeredWorkerName
      : context.tr('defaultWorkerName');
  String localizedCooperativeName(BuildContext context) =>
      _registeredCooperativeName.isNotEmpty
      ? _registeredCooperativeName
      : 'Shivneri Seva';
  String localizedWorkerTradeSubtitle(BuildContext context) =>
      context.tr('defaultWorkerTradeSubtitle');

  /// Dynamic display name for current active role
  String greetingName(BuildContext context) {
    if (_activeRole == WorkspaceRoleId.cooperative) {
      if (_registeredCooperativeName.isNotEmpty)
        return _registeredCooperativeName;
      if (_registeredCustomerName.isNotEmpty) return _registeredCustomerName;
      return 'Shivneri Seva';
    } else if (_activeRole == WorkspaceRoleId.worker) {
      return localizedWorkerName(context);
    }
    return localizedCustomerName(context);
  }

  void setLocale(Locale loc) {
    if (_currentLocale != loc) {
      _currentLocale = loc;
      notifyListeners();
      persistLanguage();
    }
  }

  void setLanguage(String code) {
    setLocale(Locale(code));
  }

  Future<void> persistLanguage() async {
    try {
      _preferences ??= await SharedPreferences.getInstance();
      await _preferences!.setString(languageKey, _currentLocale.languageCode);
    } catch (_) {}
  }

  List<WorkspaceRoleId> get eligibleRoles {
    if (_selectedRoles.isEmpty) {
      return const [WorkspaceRoleId.customer, WorkspaceRoleId.worker];
    }
    return _selectedRoles.toList();
  }

  bool get isLocked {
    final until = _lockedUntil;
    return until != null && DateTime.now().isBefore(until);
  }

  Duration get lockRemaining {
    final until = _lockedUntil;
    if (until == null) return Duration.zero;
    final remaining = until.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  bool get googleLoading => _googleLoading;
  Set<WorkspaceRoleId> get selectedRoles => Set.unmodifiable(_selectedRoles);
  bool isRoleSelected(WorkspaceRoleId id) => _selectedRoles.contains(id);
  bool get hasSelectedRole => _selectedRoles.isNotEmpty;
  bool get otpExpired {
    final expires = _otpExpiresAt;
    if (expires == null) return true;
    return DateTime.now().isAfter(expires);
  }

  DateTime? get otpExpiresAt => _otpExpiresAt;

  static bool isValidMobile(String digits) {
    return RegExp(r'^[6-9]\d{9}$').hasMatch(digits);
  }

  void setPhoneDigits(String digits) {
    final clean = digits.replaceAll(RegExp(r'\D'), '');
    _phoneDigits = clean.length > 10 ? clean.substring(0, 10) : clean;
    notifyListeners();
  }

  Future<void> loadPersisted() async {
    try {
      _preferences ??= await SharedPreferences.getInstance();
      _phoneDigits = _preferences!.getString(phoneKey) ?? '';
      final savedLang = _preferences!.getString(languageKey);
      if (savedLang != null && savedLang.isNotEmpty) {
        _currentLocale = Locale(savedLang);
      }
      final roles = _preferences!.getStringList(rolesKey) ?? [];
      _selectedRoles
        ..clear()
        ..addAll(
          roles.map(
            (value) => WorkspaceRoleId.values.firstWhere(
              (id) => id.name == value,
              orElse: () => WorkspaceRoleId.customer,
            ),
          ),
        );
      final activeRoleStr = _preferences!.getString(activeRoleKey);
      if (activeRoleStr != null) {
        _activeRole = WorkspaceRoleId.values.firstWhere(
          (id) => id.name == activeRoleStr,
          orElse: () => _selectedRoles.isNotEmpty
              ? _selectedRoles.first
              : WorkspaceRoleId.customer,
        );
      } else if (_selectedRoles.isNotEmpty) {
        _activeRole = _selectedRoles.first;
      }

      // Load registered statuses for all roles
      for (final r in WorkspaceRoleId.values) {
        _registeredRoles[r] =
            _preferences!.getBool('is_registered_${r.name}') ?? false;
      }
      _registeredCustomerName =
          _preferences!.getString('registered_customer_name') ?? '';
      _registeredWorkerName =
          _preferences!.getString('registered_worker_name') ?? '';
      _registeredCooperativeName =
          _preferences!.getString('registered_cooperative_name') ?? '';
      _registeredRepresentativeName =
          _preferences!.getString('registered_representative_name') ?? '';
      _registeredEmail = _preferences!.getString('registered_email') ?? '';
    } catch (_) {}
    notifyListeners();
  }

  /// Queries the live backend database for this mobile number and synchronizes live profiles
  Future<bool> syncUserProfileFromBackend({
    String? mobile,
    WorkspaceRoleId? role,
  }) async {
    final phoneToSync = mobile ?? _phoneDigits;
    if (phoneToSync.isEmpty || phoneToSync.length != 10) return false;
    if (_profileSyncInProgressFor == phoneToSync) return false;

    _profileSyncInProgressFor = phoneToSync;

    try {
      final usersList = await _apiService.getUserByMobile(phoneToSync);
      _preferences ??= await SharedPreferences.getInstance();

      if (usersList.isNotEmpty) {
        // Clear previous user's cached session data completely
        _registeredRoles.clear();
        _selectedRoles.clear();
        _registeredCustomerName = '';
        _registeredWorkerName = '';
        _registeredCooperativeName = '';
        _registeredRepresentativeName = '';
        _registeredEmail = '';

        for (final r in WorkspaceRoleId.values) {
          _registeredRoles[r] = false;
          await _preferences!.remove('is_registered_${r.name}');
          await _preferences!.remove('registered_profile_${r.name}');
        }
        await _preferences!.remove('registered_customer_name');
        await _preferences!.remove('registered_worker_name');
        await _preferences!.remove('registered_cooperative_name');
        await _preferences!.remove('registered_representative_name');
        await _preferences!.remove('registered_email');

        for (final userJson in usersList) {
          final roleName = userJson['role'] as String? ?? 'customer';
          final parsedRole = WorkspaceRoleId.values.firstWhere(
            (r) => r.name == roleName,
            orElse: () => WorkspaceRoleId.customer,
          );

          _registeredRoles[parsedRole] = true;
          _selectedRoles.add(parsedRole);

          final fullName = userJson['full_name'] as String? ?? '';
          final email = userJson['email'] as String? ?? '';
          final coopName = userJson['cooperative_name'] as String? ?? '';
          final repName = userJson['representative_name'] as String? ?? '';

          if (parsedRole == WorkspaceRoleId.customer && fullName.isNotEmpty) {
            _registeredCustomerName = fullName;
            await _preferences!.setString('registered_customer_name', fullName);
          } else if (parsedRole == WorkspaceRoleId.worker &&
              fullName.isNotEmpty) {
            _registeredWorkerName = fullName;
            await _preferences!.setString('registered_worker_name', fullName);
          } else if (parsedRole == WorkspaceRoleId.contractor &&
              fullName.isNotEmpty) {
            _registeredCustomerName = fullName;
          } else if (parsedRole == WorkspaceRoleId.cooperative) {
            if (coopName.isNotEmpty) {
              _registeredCooperativeName = coopName;
              await _preferences!.setString(
                'registered_cooperative_name',
                coopName,
              );
            } else if (fullName.isNotEmpty) {
              _registeredCooperativeName = fullName;
              await _preferences!.setString(
                'registered_cooperative_name',
                fullName,
              );
            }
            if (repName.isNotEmpty) {
              _registeredRepresentativeName = repName;
              await _preferences!.setString(
                'registered_representative_name',
                repName,
              );
            }
          }

          if (email.isNotEmpty) {
            _registeredEmail = email;
            await _preferences!.setString('registered_email', email);
          }

          await _preferences!.setBool('is_registered_${parsedRole.name}', true);
          await _preferences!.setString(
            'registered_profile_${parsedRole.name}',
            jsonEncode({
              'role': parsedRole.name,
              'fullName': fullName,
              'mobile': phoneToSync,
              'email': email,
              'location': userJson['location'] as String? ?? '',
              'workCategory': userJson['work_category'] as String? ?? '',
              'organizationName':
                  userJson['organization_name'] as String? ?? '',
              'companyName': userJson['company_name'] as String? ?? '',
              'gstNumber': userJson['gst_number'] as String? ?? '',
              'cooperativeName': coopName,
              'representativeName': repName,
              'registrationNumber':
                  userJson['registration_number'] as String? ?? '',
              'isRegistered': true,
            }),
          );
        }

        await _preferences!.setBool(isRegisteredGlobalKey, true);
        await _preferences!.setString(phoneKey, phoneToSync);
        await _preferences!.setStringList(
          rolesKey,
          _selectedRoles.map((r) => r.name).toList(),
        );

        if (role != null && _selectedRoles.contains(role)) {
          _activeRole = role;
        } else if (_selectedRoles.isNotEmpty) {
          _activeRole = _selectedRoles.first;
        }

        await _preferences!.setString(activeRoleKey, _activeRole.name);
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('[AuthProvider] syncUserProfileFromBackend error: $e');
    } finally {
      if (_profileSyncInProgressFor == phoneToSync) {
        _profileSyncInProgressFor = null;
      }
    }
    return false;
  }

  /// Logs out current user, clearing memory state and persisted profile tokens
  Future<void> logout() async {
    _phoneDigits = '';
    _selectedRoles.clear();
    _registeredRoles.clear();
    _activeRole = WorkspaceRoleId.customer;
    _registeredCustomerName = '';
    _registeredWorkerName = '';
    _registeredCooperativeName = '';
    _registeredRepresentativeName = '';
    _registeredEmail = '';
    _expectedOtp = null;
    _otpExpiresAt = null;

    try {
      _preferences ??= await SharedPreferences.getInstance();
      await _preferences!.remove(phoneKey);
      await _preferences!.remove(rolesKey);
      await _preferences!.remove(activeRoleKey);
      await _preferences!.remove(isRegisteredGlobalKey);
      for (final r in WorkspaceRoleId.values) {
        await _preferences!.remove('is_registered_${r.name}');
        await _preferences!.remove('registered_profile_${r.name}');
      }
      await _preferences!.remove('registered_customer_name');
      await _preferences!.remove('registered_worker_name');
      await _preferences!.remove('registered_cooperative_name');
      await _preferences!.remove('registered_representative_name');
      await _preferences!.remove('registered_email');
    } catch (_) {}

    notifyListeners();
  }

  Future<void> markRoleRegistered(
    WorkspaceRoleId role, {
    String? fullName,
    String? email,
    String? cooperativeName,
    String? representativeName,
  }) async {
    _registeredRoles[role] = true;
    if (role == WorkspaceRoleId.customer &&
        fullName != null &&
        fullName.isNotEmpty) {
      _registeredCustomerName = fullName;
    } else if (role == WorkspaceRoleId.worker &&
        fullName != null &&
        fullName.isNotEmpty) {
      _registeredWorkerName = fullName;
    } else if (role == WorkspaceRoleId.cooperative) {
      if (cooperativeName != null && cooperativeName.isNotEmpty) {
        _registeredCooperativeName = cooperativeName;
      } else if (fullName != null && fullName.isNotEmpty) {
        _registeredCooperativeName = fullName;
      }
      if (representativeName != null && representativeName.isNotEmpty) {
        _registeredRepresentativeName = representativeName;
      }
    }
    if (email != null && email.isNotEmpty) {
      _registeredEmail = email;
    }

    try {
      _preferences ??= await SharedPreferences.getInstance();
      await _preferences!.setBool('is_registered_${role.name}', true);
      await _preferences!.setBool(isRegisteredGlobalKey, true);
      if (_registeredCustomerName.isNotEmpty) {
        await _preferences!.setString(
          'registered_customer_name',
          _registeredCustomerName,
        );
      }
      if (_registeredWorkerName.isNotEmpty) {
        await _preferences!.setString(
          'registered_worker_name',
          _registeredWorkerName,
        );
      }
      if (_registeredCooperativeName.isNotEmpty) {
        await _preferences!.setString(
          'registered_cooperative_name',
          _registeredCooperativeName,
        );
      }
      if (_registeredRepresentativeName.isNotEmpty) {
        await _preferences!.setString(
          'registered_representative_name',
          _registeredRepresentativeName,
        );
      }
      if (_registeredEmail.isNotEmpty) {
        await _preferences!.setString('registered_email', _registeredEmail);
      }
    } catch (_) {}
    notifyListeners();
  }

  void updateProfileData({
    String? customerName,
    String? workerName,
    String? cooperativeName,
    String? representativeName,
    String? email,
  }) {
    if (customerName != null) _registeredCustomerName = customerName;
    if (workerName != null) _registeredWorkerName = workerName;
    if (cooperativeName != null) _registeredCooperativeName = cooperativeName;
    if (representativeName != null)
      _registeredRepresentativeName = representativeName;
    if (email != null) _registeredEmail = email;
    notifyListeners();
  }

  Future<bool> sendOtp() async {
    if (isLocked) return false;
    _sendAttempts += 1;
    if (_sendAttempts > maxAttempts) {
      _lockedUntil = DateTime.now().add(lockDuration);
      notifyListeners();
      return false;
    }
    _phoneDigits = _phoneDigits;
    _expectedOtp = demoOtp;
    _otpExpiresAt = DateTime.now().add(const Duration(seconds: resendSeconds));
    _verifyAttempts = 0;
    try {
      _preferences ??= await SharedPreferences.getInstance();
      await _preferences!.setString(phoneKey, _phoneDigits);
    } catch (_) {}
    notifyListeners();
    return true;
  }

  OtpVerifyResult verifyOtp(String code) {
    if (isLocked) return OtpVerifyResult.locked;
    if (otpExpired) return OtpVerifyResult.expired;
    if (code.length != otpLength || !RegExp(r'^\d{6}$').hasMatch(code)) {
      return OtpVerifyResult.invalid;
    }
    if (code == _expectedOtp) {
      _verifyAttempts = 0;
      notifyListeners();
      return OtpVerifyResult.success;
    }
    _verifyAttempts += 1;
    if (_verifyAttempts >= maxAttempts) {
      _lockedUntil = DateTime.now().add(lockDuration);
    }
    notifyListeners();
    return isLocked ? OtpVerifyResult.locked : OtpVerifyResult.invalid;
  }

  Future<void> signInWithGoogle() async {
    _googleLoading = true;
    notifyListeners();
    await Future<void>.delayed(const Duration(milliseconds: 900));
    _googleLoading = false;
    notifyListeners();
  }

  void toggleRole(WorkspaceRoleId id) {
    if (_selectedRoles.contains(id)) {
      _selectedRoles.remove(id);
    } else {
      _selectedRoles.add(id);
    }
    notifyListeners();
  }

  void setActiveRole(WorkspaceRoleId role) {
    if (_activeRole != role) {
      _activeRole = role;
      notifyListeners();
      persistActiveRole();
    }
  }

  Future<void> persistActiveRole() async {
    try {
      _preferences ??= await SharedPreferences.getInstance();
      await _preferences!.setString(activeRoleKey, _activeRole.name);
    } catch (_) {}
  }

  Future<void> persistRoles() async {
    try {
      _preferences ??= await SharedPreferences.getInstance();
      await _preferences!.setStringList(
        rolesKey,
        _selectedRoles.map((id) => id.name).toList(),
      );
      if (_selectedRoles.isNotEmpty && !_selectedRoles.contains(_activeRole)) {
        _activeRole = _selectedRoles.first;
        await _preferences!.setString(activeRoleKey, _activeRole.name);
      }
    } catch (_) {}
  }

  String formatCountdown(Duration duration) {
    final seconds = duration.inSeconds.clamp(0, 24 * 3600);
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final rest = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$rest';
  }
}
