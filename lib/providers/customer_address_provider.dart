import 'package:flutter/foundation.dart';
import '../models/customer_address_model.dart';
import '../services/customer_api_service.dart';

class CustomerAddressProvider extends ChangeNotifier {
  final CustomerApiService _apiService;

  CustomerAddressProvider({CustomerApiService? apiService})
      : _apiService = apiService ?? CustomerApiService();

  List<CustomerAddressModel> _addresses = [];
  CustomerAddressModel? _selectedAddress;
  bool _isLoading = false;
  String? _errorMessage;

  List<CustomerAddressModel> get addresses => List.unmodifiable(_addresses);
  CustomerAddressModel? get selectedAddress => _selectedAddress;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadAddresses(String customerId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final list = await _apiService.fetchSavedAddresses(customerId);
      _addresses = list;
      if (_addresses.isNotEmpty) {
        // Set selected to default address if none chosen, or preserve chosen
        final defaultAddr = _addresses.firstWhere(
          (a) => a.isDefault,
          orElse: () => _addresses.first,
        );
        _selectedAddress = defaultAddr;
      } else {
        _selectedAddress = null;
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectAddress(CustomerAddressModel address) {
    _selectedAddress = address;
    notifyListeners();
  }

  Future<bool> addAddress(CustomerAddressModel newAddress) async {
    _isLoading = true;
    notifyListeners();

    try {
      final created = await _apiService.createSavedAddress(newAddress);
      if (created != null) {
        if (created.isDefault) {
          _addresses = _addresses.map((a) => a.copyWith(isDefault: false)).toList();
        }
        _addresses.insert(0, created);
        _selectedAddress = created;
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> setDefault(int addressId) async {
    final success = await _apiService.setDefaultAddress(addressId);
    if (success) {
      _addresses = _addresses.map((a) {
        return a.copyWith(isDefault: a.id == addressId);
      }).toList();
      _selectedAddress = _addresses.firstWhere((a) => a.id == addressId, orElse: () => _addresses.first);
      notifyListeners();
    }
    return success;
  }

  Future<bool> deleteAddress(int addressId) async {
    final success = await _apiService.deleteSavedAddress(addressId);
    if (success) {
      _addresses.removeWhere((a) => a.id == addressId);
      if (_selectedAddress?.id == addressId) {
        _selectedAddress = _addresses.isNotEmpty ? _addresses.first : null;
      }
      notifyListeners();
    }
    return success;
  }
}
