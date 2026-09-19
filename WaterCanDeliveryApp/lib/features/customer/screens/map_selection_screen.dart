import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import 'dart:async';
import '../../../core/constants/app_colors.dart';

class MapSelectionScreen extends StatefulWidget {
  final double? initialLat;
  final double? initialLng;

  const MapSelectionScreen({
    super.key,
    this.initialLat,
    this.initialLng,
  });

  @override
  State<MapSelectionScreen> createState() => _MapSelectionScreenState();
}

class _MapSelectionScreenState extends State<MapSelectionScreen> {
  final MapController _mapController = MapController();
  LatLng _currentPosition = const LatLng(20.5937, 78.9629); // Default to India
  String _currentAddress = 'Fetching address...';
  bool _isLoadingAddress = false;
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.initialLat != null && widget.initialLng != null) {
      _currentPosition = LatLng(widget.initialLat!, widget.initialLng!);
      _getAddressFromLatLng(_currentPosition);
    } else {
      _fetchInitialLocation();
    }
  }

  Future<void> _fetchInitialLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      if (permission == LocationPermission.deniedForever) return;
      
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      if (mounted) {
        setState(() {
          _currentPosition = LatLng(position.latitude, position.longitude);
          _mapController.move(_currentPosition, 15);
        });
        _getAddressFromLatLng(_currentPosition);
      }
    } catch (e) {
      debugPrint('Initial location fetch failed: $e');
    }
  }

  Future<void> _getAddressFromLatLng(LatLng position) async {
    setState(() {
      _isLoadingAddress = true;
    });
    try {
      final url = Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=${position.latitude}&lon=${position.longitude}');
      final response = await http.get(url, headers: {
        'User-Agent': 'WaterCanDeliveryApp/1.0',
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['address'] != null || data['display_name'] != null) {
          final address = data['address'] ?? {};
          
          final road = address['road'] ?? address['street'] ?? '';
          final suburb = address['suburb'] ?? address['neighbourhood'] ?? '';
          final city = address['city'] ?? address['town'] ?? address['village'] ?? '';
          final state = address['state'] ?? '';
          final postcode = address['postcode'] ?? '';

          final formattedAddress = data['display_name'] ?? '';

          setState(() {
            _currentAddress = formattedAddress;
            _parsedDoorNo = address['house_number'] ?? '';
            _parsedStreet = [road, suburb].where((e) => e.isNotEmpty).join(', ');
            if (_parsedStreet.isEmpty) _parsedStreet = formattedAddress; // fallback
            _parsedCity = [city, state].where((e) => e.isNotEmpty).join(', ');
            _parsedPincode = postcode;
          });
        } else {
          setState(() {
            _currentAddress = 'Address not found';
          });
        }
      } else {
        setState(() {
          _currentAddress = 'Failed to fetch address';
        });
      }
    } catch (e) {
      debugPrint('Geocoding Error: $e');
      setState(() {
        _currentAddress = 'Error: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoadingAddress = false;
      });
    }
  }

  String _parsedDoorNo = '';
  String _parsedStreet = '';
  String _parsedCity = '';
  String _parsedPincode = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Select Location',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        backgroundColor: AppColors.surfaceContainerLow,
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 120.0), // Above the bottom sheet
        child: FloatingActionButton(
          onPressed: _fetchInitialLocation,
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.my_location, color: Colors.white),
        ),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentPosition,
              initialZoom: 15,
              onPositionChanged: (camera, hasGesture) {
                _currentPosition = camera.center;
                if (hasGesture) {
                  if (_debounce?.isActive ?? false) _debounce!.cancel();
                  _debounce = Timer(const Duration(milliseconds: 1000), () {
                    _getAddressFromLatLng(_currentPosition);
                  });
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.watercan.delivery',
              ),
            ],
          ),
          // Center Pin Marker
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 40.0), // Adjust for pin bottom pointing to center
              child: Icon(
                Icons.location_on,
                size: 50,
                color: AppColors.primary,
              ),
            ),
          ),
          
          // Bottom Address Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selected Address',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_city, color: AppColors.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _isLoadingAddress
                            ? const LinearProgressIndicator()
                            : Text(
                                _currentAddress,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _isLoadingAddress || _currentAddress == 'Error fetching address' || _currentAddress == 'Address not found'
                          ? null
                          : () {
                              Navigator.pop(context, {
                                'latitude': _currentPosition.latitude,
                                'longitude': _currentPosition.longitude,
                                'fullAddress': _currentAddress,
                                'doorNo': _parsedDoorNo,
                                'street': _parsedStreet,
                                'city': _parsedCity,
                                'pincode': _parsedPincode,
                              });
                            },
                      child: Text(
                        'Confirm Location',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
