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
  static const String _keyLat = 'user_lat';
  static const String _keyLng = 'user_lng';
  static const String _keyEmail = 'user_email';
  static const String _keyIsLoggedIn = 'user_is_logged_in';
  static const String _keyAssignedSellerId = 'assigned_seller_id';
  static const String _keyShopName = 'shop_name';
  static const String _keyShopAddress = 'shop_address';
  static const String _keyIsSeller = 'user_is_seller';

  static const String defaultFullAddress = '';

  String _customerName = 'User';
  String _phone = '';
  String _doorNo = '';
  String _street = '';
  String _city = '';
  String _pincode = '';
  double? _latitude;
  double? _longitude;
  String _email = '';
  bool _isLoggedIn = false;
  String _assignedSellerId = '';
  String _shopName = '';
  String _shopAddress = '';
  bool _isSeller = false;

  String get customerName => _customerName;
  String get phone => _phone;
  String get doorNo => _doorNo;
  String get street => _street;
  String get city => _city;
  String get pincode => _pincode;
  double? get latitude => _latitude;
  double? get longitude => _longitude;
  String get email => _email;
  bool get isLoggedIn => _isLoggedIn;
  String get assignedSellerId => _assignedSellerId;
  String get shopName => _shopName;
  String get shopAddress => _shopAddress;
  bool get isSeller => _isSeller;

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
      _latitude = prefs.getDouble(_keyLat);
      _longitude = prefs.getDouble(_keyLng);
      _email = prefs.getString(_keyEmail) ?? _email;
      _isLoggedIn = prefs.getBool(_keyIsLoggedIn) ?? false;
      _assignedSellerId = prefs.getString(_keyAssignedSellerId) ?? _assignedSellerId;
      _shopName = prefs.getString(_keyShopName) ?? _shopName;
      _shopAddress = prefs.getString(_keyShopAddress) ?? _shopAddress;
      _isSeller = prefs.getBool(_keyIsSeller) ?? false;
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
    double? latitude,
    double? longitude,
    String email = '',
    String assignedSellerId = '',
    String shopName = '',
    String shopAddress = '',
    bool isSeller = false,
    bool rememberDevice = true,
  }) async {
    _customerName = name.trim().isNotEmpty ? name.trim() : 'User';
    _phone = phone.trim();
    _doorNo = doorNo.trim();
    _street = street.trim();
    _city = city.trim();
    _pincode = pincode.trim();
    _latitude = latitude;
    _longitude = longitude;
    _email = email.trim();
    _assignedSellerId = assignedSellerId.trim();
    _shopName = shopName.trim();
    _shopAddress = shopAddress.trim();
    _isSeller = isSeller;
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
        if (_latitude != null) await prefs.setDouble(_keyLat, _latitude!);
        if (_longitude != null) await prefs.setDouble(_keyLng, _longitude!);
        await prefs.setString(_keyEmail, _email);
        await prefs.setString(_keyAssignedSellerId, _assignedSellerId);
        await prefs.setString(_keyShopName, _shopName);
        await prefs.setString(_keyShopAddress, _shopAddress);
        await prefs.setBool(_keyIsSeller, _isSeller);
        await prefs.setBool(_keyIsLoggedIn, true);
      } else {
        await prefs.remove(_keyName);
        await prefs.remove(_keyPhone);
        await prefs.remove(_keyDoorNo);
        await prefs.remove(_keyStreet);
        await prefs.remove(_keyCity);
        await prefs.remove(_keyPincode);
        await prefs.remove(_keyLat);
        await prefs.remove(_keyLng);
        await prefs.remove(_keyEmail);
        await prefs.remove(_keyAssignedSellerId);
        await prefs.remove(_keyShopName);
        await prefs.remove(_keyShopAddress);
        await prefs.remove(_keyIsSeller);
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
    double? latitude,
    double? longitude,
  }) async {
    _doorNo = doorNo.trim();
    _street = street.trim();
    _city = city.trim();
    _pincode = pincode.trim();
    if (latitude != null) _latitude = latitude;
    if (longitude != null) _longitude = longitude;
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
          if (_latitude != null) 'latitude': _latitude,
          if (_longitude != null) 'longitude': _longitude,
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
      if (_latitude != null) await prefs.setDouble(_keyLat, _latitude!);
      if (_longitude != null) await prefs.setDouble(_keyLng, _longitude!);
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
    _latitude = null;
    _longitude = null;
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
      await prefs.remove(_keyLat);
      await prefs.remove(_keyLng);
      await prefs.remove(_keyEmail);
      await prefs.setBool(_keyIsLoggedIn, false);
    } catch (e) {
      debugPrint('Error clearing user prefs: $e');
    }
  }
}
