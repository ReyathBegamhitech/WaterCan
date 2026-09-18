import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_constants.dart';

class UserController extends ChangeNotifier {
  static const String _keyName = 'user_name';
  static const String _keyPhone = 'user_phone';
  static const String _keyDoorNo = 'user_door_no';
  static const String _keyStreet = 'user_street';
  static const String _keyCity = 'user_city';
  static const String _keyPincode = 'user_pincode';
  static const String _keyEmail = 'user_email';
  static const String _keyIsLoggedIn = 'user_is_logged_in';

  static const String defaultFullAddress = '';

  String _customerName = 'User';
  String _phone = '';
  String _doorNo = '';
  String _street = '';
  String _city = '';
  String _pincode = '';
  String _email = '';
  bool _isLoggedIn = false;

  String get customerName => _customerName;
  String get phone => _phone;
  String get doorNo => _doorNo;
  String get street => _street;
  String get city => _city;
  String get pincode => _pincode;
  String get email => _email;
  bool get isLoggedIn => _isLoggedIn;

  String get fullAddress {
    final parts = [_doorNo, _street, _city, _pincode].where((p) => p.isNotEmpty).toList();
    return parts.join(', ');
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
      _doorNo = prefs.getString(_keyDoorNo) ?? _doorNo;
      _street = prefs.getString(_keyStreet) ?? _street;
      _city = prefs.getString(_keyCity) ?? _city;
      _pincode = prefs.getString(_keyPincode) ?? _pincode;
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
    String doorNo = '',
    String street = '',
    String city = '',
    String pincode = '',
    String email = '',
    bool rememberDevice = true,
  }) async {
    _customerName = name.trim().isNotEmpty ? name.trim() : 'User';
    _phone = phone.trim();
    _doorNo = doorNo.trim();
    _street = street.trim();
    _city = city.trim();
    _pincode = pincode.trim();
    _email = email.trim();
    _isLoggedIn = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      if (rememberDevice) {
        await prefs.setString(_keyName, _customerName);
        await prefs.setString(_keyPhone, _phone);
        await prefs.setString(_keyDoorNo, _doorNo);
        await prefs.setString(_keyStreet, _street);
        await prefs.setString(_keyCity, _city);
        await prefs.setString(_keyPincode, _pincode);
        await prefs.setString(_keyEmail, _email);
        await prefs.setBool(_keyIsLoggedIn, true);
      } else {
        await prefs.remove(_keyName);
        await prefs.remove(_keyPhone);
        await prefs.remove(_keyDoorNo);
        await prefs.remove(_keyStreet);
        await prefs.remove(_keyCity);
        await prefs.remove(_keyPincode);
        await prefs.remove(_keyEmail);
        await prefs.remove(_keyIsLoggedIn);
      }
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
    required String doorNo,
    required String street,
    required String city,
    required String pincode,
  }) async {
    _doorNo = doorNo.trim();
    _street = street.trim();
    _city = city.trim();
    _pincode = pincode.trim();
    notifyListeners();

    try {
      // API call to update address in DB
      final response = await http.put(
        Uri.parse(ApiConstants.updateAddress),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone': _phone,
          'doorNo': _doorNo,
          'street': _street,
          'city': _city,
          'pincode': _pincode,
        }),
      );

      if (response.statusCode != 200) {
        debugPrint('Failed to update address in DB: ${response.body}');
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyDoorNo, _doorNo);
      await prefs.setString(_keyStreet, _street);
      await prefs.setString(_keyCity, _city);
      await prefs.setString(_keyPincode, _pincode);
    } catch (e) {
      debugPrint('Error updating address in prefs/DB: $e');
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
    _doorNo = '';
    _street = '';
    _city = '';
    _pincode = '';
    _email = '';
    _isLoggedIn = false;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyName);
      await prefs.remove(_keyPhone);
      await prefs.remove(_keyDoorNo);
      await prefs.remove(_keyStreet);
      await prefs.remove(_keyCity);
      await prefs.remove(_keyPincode);
      await prefs.remove(_keyEmail);
      await prefs.setBool(_keyIsLoggedIn, false);
    } catch (e) {
      debugPrint('Error clearing user prefs: $e');
    }
  }
}
