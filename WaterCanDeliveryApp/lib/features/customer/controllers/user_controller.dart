import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserController extends ChangeNotifier {
  static const String _keyName = 'user_name';
  static const String _keyPhone = 'user_phone';
  static const String _keyAddress1 = 'user_address_1';
  static const String _keyAddress2 = 'user_address_2';
  static const String _keyEmail = 'user_email';
  static const String _keyIsLoggedIn = 'user_is_logged_in';

  String _customerName = 'User';
  String _phone = '';
  String _addressLine1 = '';
  String _addressLine2 = '';
  String _email = '';
  bool _isLoggedIn = false;

  static const String defaultAddressLine1 = '';
  static const String defaultAddressLine2 = '';
  static const String defaultFullAddress = '';

  String get customerName => _customerName;
  String get phone => _phone;
  String get addressLine1 => _addressLine1;
  String get addressLine2 => _addressLine2;
  String get email => _email;
  bool get isLoggedIn => _isLoggedIn;

  String get fullAddress {
    if (_addressLine1.isEmpty && _addressLine2.isEmpty) {
      return '';
    }
    if (_addressLine2.isEmpty) {
      return _addressLine1;
    }
    if (_addressLine1.isEmpty) {
      return _addressLine2;
    }
    return '$_addressLine1, $_addressLine2';
  }

  /// Returns the effective address for dashboard and order display
  String get displayAddress {
    return fullAddress;
  }

  /// Initialize and load saved state from SharedPreferences
  Future<void> loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _customerName = prefs.getString(_keyName) ?? _customerName;
      _phone = prefs.getString(_keyPhone) ?? _phone;
      _addressLine1 = prefs.getString(_keyAddress1) ?? _addressLine1;
      _addressLine2 = prefs.getString(_keyAddress2) ?? _addressLine2;
      _email = prefs.getString(_keyEmail) ?? _email;
      _isLoggedIn = prefs.getBool(_keyIsLoggedIn) ?? false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading user prefs: $e');
    }
  }

  /// Set user profile upon login, registration, or OTP verification
  Future<void> setUser({
    required String name,
    required String phone,
    String address = '',
    String addressLine2 = '',
    String email = '',
  }) async {
    _customerName = name.trim().isNotEmpty ? name.trim() : 'User';
    _phone = phone.trim();
    if (address.isNotEmpty || _addressLine1.isEmpty) {
      _addressLine1 = address.trim();
    }
    if (addressLine2.isNotEmpty) {
      _addressLine2 = addressLine2.trim();
    }
    if (email.isNotEmpty) {
      _email = email.trim();
    }
    _isLoggedIn = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyName, _customerName);
      await prefs.setString(_keyPhone, _phone);
      await prefs.setString(_keyAddress1, _addressLine1);
      await prefs.setString(_keyAddress2, _addressLine2);
      await prefs.setString(_keyEmail, _email);
      await prefs.setBool(_keyIsLoggedIn, true);
    } catch (e) {
      debugPrint('Error saving user prefs: $e');
    }
  }

  /// Update phone number
  Future<void> updatePhone(String newPhone) async {
    _phone = newPhone.trim();
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyPhone, _phone);
    } catch (e) {
      debugPrint('Error updating phone in prefs: $e');
    }
  }

  /// Update delivery address
  Future<void> updateAddress({
    required String addressLine1,
    String addressLine2 = '',
  }) async {
    _addressLine1 = addressLine1.trim();
    _addressLine2 = addressLine2.trim();
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyAddress1, _addressLine1);
      await prefs.setString(_keyAddress2, _addressLine2);
    } catch (e) {
      debugPrint('Error updating address in prefs: $e');
    }
  }

  /// Update name
  Future<void> updateName(String newName) async {
    _customerName = newName.trim();
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyName, _customerName);
    } catch (e) {
      debugPrint('Error updating name in prefs: $e');
    }
  }

  /// Clear user session on logout
  Future<void> clear() async {
    _customerName = 'User';
    _phone = '';
    _addressLine1 = '';
    _addressLine2 = '';
    _email = '';
    _isLoggedIn = false;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyName);
      await prefs.remove(_keyPhone);
      await prefs.remove(_keyAddress1);
      await prefs.remove(_keyAddress2);
      await prefs.remove(_keyEmail);
      await prefs.setBool(_keyIsLoggedIn, false);
    } catch (e) {
      debugPrint('Error clearing user prefs: $e');
    }
  }
}
