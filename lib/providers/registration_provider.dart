import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/registration_data.dart';
import '../models/workspace_role.dart';
import '../services/registration_api_service.dart';

enum PasswordStrength {
  none,
  weak,
  fair,
  good,
  strong,
}

class RegistrationProvider extends ChangeNotifier {
  RegistrationProvider({RegistrationApiService? apiService})
      : _apiService = apiService ?? RegistrationApiService();

  final RegistrationApiService _apiService;

  WorkspaceRoleId _currentRole = WorkspaceRoleId.worker;
  bool _obscurePassword = true;
  bool _agreedToTerms = false;
  bool _isLoading = false;
  String? _errorMessage;

  // Common form fields
  String _fullName = '';
  String _mobile = '';
  String _email = '';
  String _password = '';
  String _location = '';

  // Role-specific fields
  String _workCategory = '';
  String _otherWorkCategory = '';
  String _organizationName = '';
  String _companyName = '';
  String _gstNumber = '';
  String _cooperativeName = '';
  String _representativeName = '';
  String _registrationNumber = '';

  // Getters
  WorkspaceRoleId get currentRole => _currentRole;
  bool get obscurePassword => _obscurePassword;
  bool get agreedToTerms => _agreedToTerms;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  String get fullName => _fullName;
  String get mobile => _mobile;
  String get email => _email;
  String get password => _password;
  String get location => _location;

  String get workCategory => _workCategory;
  String get otherWorkCategory => _otherWorkCategory;
  String get organizationName => _organizationName;
  String get companyName => _companyName;
  String get gstNumber => _gstNumber;
  String get cooperativeName => _cooperativeName;
  String get representativeName => _representativeName;
  String get registrationNumber => _registrationNumber;

  bool get isOtherWorkCategorySelected =>
      _workCategory == 'serviceOther' ||
      _workCategory.toLowerCase() == 'other';

  String get effectiveWorkCategory {
    if (isOtherWorkCategorySelected) {
      return _otherWorkCategory.isNotEmpty ? _otherWorkCategory : 'Other';
    }
    return _workCategory;
  }

  // Password Strength Evaluation
  PasswordStrength get passwordStrength {
    if (_password.isEmpty) return PasswordStrength.none;
    int score = 0;
    if (_password.length >= 8) score++;
    if (_password.length >= 10) score++;
    if (RegExp(r'[A-Z]').hasMatch(_password) && RegExp(r'[a-z]').hasMatch(_password)) score++;
    if (RegExp(r'\d').hasMatch(_password)) score++;
    if (RegExp(r'[@$!%*?&#^~_]').hasMatch(_password)) score++;

    if (score <= 1) return PasswordStrength.weak;
    if (score == 2) return PasswordStrength.fair;
    if (score == 3 || score == 4) return PasswordStrength.good;
    return PasswordStrength.strong;
  }

  String get passwordStrengthLabel {
    switch (passwordStrength) {
      case PasswordStrength.none:
        return '';
      case PasswordStrength.weak:
        return 'Weak';
      case PasswordStrength.fair:
        return 'Fair';
      case PasswordStrength.good:
        return 'Good';
      case PasswordStrength.strong:
        return 'Strong';
    }
  }

  Color get passwordStrengthColor {
    switch (passwordStrength) {
      case PasswordStrength.none:
        return const Color(0xFFCBD5E1);
      case PasswordStrength.weak:
        return const Color(0xFFEF4444);
      case PasswordStrength.fair:
        return const Color(0xFFF59E0B);
      case PasswordStrength.good:
        return const Color(0xFF3B82F6);
      case PasswordStrength.strong:
        return const Color(0xFF10B981);
    }
  }

  double get passwordStrengthFraction {
    switch (passwordStrength) {
      case PasswordStrength.none:
        return 0.0;
      case PasswordStrength.weak:
        return 0.25;
      case PasswordStrength.fair:
        return 0.50;
      case PasswordStrength.good:
        return 0.75;
      case PasswordStrength.strong:
        return 1.0;
    }
  }

  void setRole(WorkspaceRoleId role) {
    if (_currentRole != role) {
      _currentRole = role;
      _errorMessage = null;
      notifyListeners();
    }
  }

  void toggleObscurePassword() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  void setAgreedToTerms(bool value) {
    _agreedToTerms = value;
    notifyListeners();
  }

  void setFullName(String val) {
    _fullName = val.trim();
    _errorMessage = null;
    notifyListeners();
  }

  void setMobile(String val) {
    _mobile = val.replaceAll(RegExp(r'\D'), '');
    if (_mobile.length > 10) _mobile = _mobile.substring(0, 10);
    _errorMessage = null;
    notifyListeners();
  }

  void setEmail(String val) {
    _email = val.trim();
    _errorMessage = null;
    notifyListeners();
  }

  void setPassword(String val) {
    _password = val;
    _errorMessage = null;
    notifyListeners();
  }

  void setLocation(String val) {
    _location = val.trim();
    _errorMessage = null;
    notifyListeners();
  }

  void setWorkCategory(String val) {
    _workCategory = val;
    _errorMessage = null;
    notifyListeners();
  }

  void setOtherWorkCategory(String val) {
    _otherWorkCategory = val.trim();
    _errorMessage = null;
    notifyListeners();
  }

  void setOrganizationName(String val) {
    _organizationName = val.trim();
    _errorMessage = null;
    notifyListeners();
  }

  void setCompanyName(String val) {
    _companyName = val.trim();
    _errorMessage = null;
    notifyListeners();
  }

  void setGstNumber(String val) {
    _gstNumber = val.trim();
    _errorMessage = null;
    notifyListeners();
  }

  void setCooperativeName(String val) {
    _cooperativeName = val.trim();
    _errorMessage = null;
    notifyListeners();
  }

  void setRepresentativeName(String val) {
    _representativeName = val.trim();
    _errorMessage = null;
    notifyListeners();
  }

  void setRegistrationNumber(String val) {
    _registrationNumber = val.trim();
    _errorMessage = null;
    notifyListeners();
  }

  // Validation helpers
  static bool isValidMobile(String digits) =>
      RegExp(r'^[6-9]\d{9}$').hasMatch(digits);

  static bool isValidEmail(String email) =>
      RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(email);

  /// Validates all fields and returns a list of human-friendly error messages if invalid.
  List<String> validateForm() {
    final errors = <String>[];

    // 1. Role name / entity checks
    switch (_currentRole) {
      case WorkspaceRoleId.worker:
        if (_fullName.isEmpty) {
          errors.add('Please enter your Full Name.');
        }
        if (_workCategory.isEmpty) {
          errors.add('Please select your Work Category.');
        } else if (isOtherWorkCategorySelected && _otherWorkCategory.isEmpty) {
          errors.add('Please specify your custom Work Category.');
        }
        if (_email.isNotEmpty && !isValidEmail(_email)) {
          errors.add('Please enter a valid Email Address format.');
        }
        break;

      case WorkspaceRoleId.customer:
        if (_fullName.isEmpty) {
          errors.add('Please enter your Full Name.');
        }
        if (_email.isEmpty) {
          errors.add('Email Address is required.');
        } else if (!isValidEmail(_email)) {
          errors.add('Please enter a valid Email Address format.');
        }
        if (_organizationName.isEmpty) {
          errors.add('Please enter Organization / Individual Name.');
        }
        break;

      case WorkspaceRoleId.contractor:
        if (_fullName.isEmpty) {
          errors.add('Please enter Contractor Contact Person Name.');
        }
        if (_email.isEmpty) {
          errors.add('Email Address is required.');
        } else if (!isValidEmail(_email)) {
          errors.add('Please enter a valid Email Address format.');
        }
        if (_companyName.isEmpty) {
          errors.add('Please enter Company / Agency Name.');
        }
        break;

      case WorkspaceRoleId.cooperative:
        if (_cooperativeName.isEmpty) {
          errors.add('Please enter Co-operative Society Name.');
        }
        if (_representativeName.isEmpty) {
          errors.add('Please enter Representative Name.');
        }
        if (_email.isEmpty) {
          errors.add('Email Address is required.');
        } else if (!isValidEmail(_email)) {
          errors.add('Please enter a valid Email Address format.');
        }
        if (_registrationNumber.isEmpty) {
          errors.add('Please enter Society Registration Number.');
        }
        break;
    }

    // 2. Mobile Number Validation
    if (_mobile.isEmpty) {
      errors.add('Please enter your 10-digit Mobile Number.');
    } else if (!isValidMobile(_mobile)) {
      errors.add('Mobile Number must be 10 digits starting with 6, 7, 8, or 9.');
    }

    // 3. Password Strength Validation
    if (_password.isEmpty) {
      errors.add('Please create a Password.');
    } else if (_password.length < 6) {
      errors.add('Password must be at least 6 characters long.');
    }

    // 4. Location Validation
    if (_location.isEmpty) {
      errors.add('Please enter your Location / City.');
    }

    // 5. Terms & Conditions Checkbox
    if (!_agreedToTerms) {
      errors.add('Please agree to the Terms & Conditions and Privacy Policy.');
    }

    return errors;
  }

  bool get isFormValid => validateForm().isEmpty;

  RegistrationData get currentRegistrationData {
    return RegistrationData(
      role: _currentRole,
      fullName: _fullName,
      mobile: _mobile,
      email: _email,
      password: _password,
      location: _location,
      workCategory: _workCategory,
      otherWorkCategory: _otherWorkCategory,
      organizationName: _organizationName,
      companyName: _companyName,
      gstNumber: _gstNumber,
      cooperativeName: _cooperativeName,
      representativeName: _representativeName,
      registrationNumber: _registrationNumber,
      isRegistered: true,
    );
  }

  /// Submits registration to the backend database (password hashed in backend)
  /// and persists profile locally to mark isRegistered: true.
  Future<bool> register() async {
    final validationErrors = validateForm();
    if (validationErrors.isNotEmpty) {
      _errorMessage = validationErrors.first;
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final regData = currentRegistrationData;
      final result = await _apiService.register(regData);

      if (!result.success) {
        _errorMessage = result.errorMessage ?? 'Registration failed. Please try again.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Persist profile locally marking isRegistered: true
      await _persistProfileLocally(regData);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Updates existing profile locally and pushes changes to backend database
  Future<bool> updateProfile(RegistrationData updatedData) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _apiService.updateProfile(updatedData);
      if (!result.success) {
        _errorMessage = result.errorMessage ?? 'Failed to update profile in database.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Update state and local storage
      populateFromData(updatedData);
      await _persistProfileLocally(updatedData);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> _persistProfileLocally(RegistrationData data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'registered_profile_${data.role.name}';
      final jsonStr = jsonEncode(data.toLocalMap());
      await prefs.setString(key, jsonStr);
      await prefs.setBool('is_registered_${data.role.name}', true);
      await prefs.setBool('is_registered_global', true);
      await prefs.setString('last_registered_role', data.role.name);
      await prefs.setString('auth_phone', data.mobile);

      if (data.role == WorkspaceRoleId.customer && data.fullName.isNotEmpty) {
        await prefs.setString('registered_customer_name', data.fullName);
      } else if (data.role == WorkspaceRoleId.worker && data.fullName.isNotEmpty) {
        await prefs.setString('registered_worker_name', data.fullName);
      }
      if (data.email.isNotEmpty) {
        await prefs.setString('registered_email', data.email);
      }
    } catch (_) {}
  }

  /// Loads profile info from backend database (or local cache if offline) for editing or viewing
  Future<RegistrationData?> loadSavedProfile(WorkspaceRoleId role, {String? phone}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final phoneToUse = phone ?? (_mobile.isNotEmpty ? _mobile : (prefs.getString('auth_phone') ?? ''));

      // 1. First attempt to fetch live profile from backend database
      if (phoneToUse.isNotEmpty) {
        final backendMap = await _apiService.getProfile(phoneToUse, role.name);
        if (backendMap != null) {
          final data = RegistrationData.fromBackendJson(backendMap);
          populateFromData(data);
          await _persistProfileLocally(data);
          return data;
        }
      }

      // 2. Fallback to locally cached profile
      final key = 'registered_profile_${role.name}';
      final jsonStr = prefs.getString(key);
      if (jsonStr != null) {
        final map = jsonDecode(jsonStr) as Map<String, dynamic>;
        final data = RegistrationData.fromLocalMap(map);
        populateFromData(data);
        return data;
      }
    } catch (_) {}
    return null;
  }

  void populateFromData(RegistrationData data) {
    _currentRole = data.role;
    _fullName = data.fullName;
    _mobile = data.mobile;
    _email = data.email;
    _location = data.location;
    _workCategory = data.workCategory;
    _otherWorkCategory = data.otherWorkCategory;
    _organizationName = data.organizationName;
    _companyName = data.companyName;
    _gstNumber = data.gstNumber;
    _cooperativeName = data.cooperativeName;
    _representativeName = data.representativeName;
    _registrationNumber = data.registrationNumber;
    _agreedToTerms = true;
    notifyListeners();
  }

  /// Clears in-memory registration form and cached state on logout
  void reset() {
    _currentRole = WorkspaceRoleId.customer;
    _fullName = '';
    _mobile = '';
    _email = '';
    _password = '';
    _location = '';
    _workCategory = '';
    _otherWorkCategory = '';
    _organizationName = '';
    _companyName = '';
    _gstNumber = '';
    _cooperativeName = '';
    _representativeName = '';
    _registrationNumber = '';
    _agreedToTerms = false;
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }
}
