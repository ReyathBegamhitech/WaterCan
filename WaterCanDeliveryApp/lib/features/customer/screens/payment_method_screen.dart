import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../models/order_model.dart';
import '../models/product_model.dart';
import '../controllers/order_controller.dart';
import '../controllers/user_controller.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../widgets/upi_payment_sheet.dart';
import 'buyer_dashboard.dart';
import 'map_selection_screen.dart';

class PaymentMethodScreen extends StatefulWidget {
  final List<CartItem> items;
  final double totalAmount;
  final String shopName;
  final String deliveryAddress;
  final bool isFastDelivery;
  final String sellerId;

  const PaymentMethodScreen({
    super.key,
    required this.items,
    required this.totalAmount,
    required this.shopName,
    required this.deliveryAddress,
    required this.isFastDelivery,
    required this.sellerId,
  });

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  String? _paymentMethod;
  bool _isProcessing = false;
  bool _isAddressConfirmed = false;
  late String _currentDeliveryAddress;
  double? _selectedLatitude;
  double? _selectedLongitude;

  @override
  void initState() {
    super.initState();
    _currentDeliveryAddress = widget.deliveryAddress;
    // We try to get initial lat/lng from user profile if it matches the default address
  }

  void _showEditAddressModal(BuildContext context) {
    final userCtrl = Provider.of<UserController>(context, listen: false);
    final defaultFull = userCtrl.fullAddress;

    String currentDoor = userCtrl.doorNo;
    String currentStreet = userCtrl.street;
    String currentCity = userCtrl.city;
    String currentPincode = userCtrl.pincode;
    
    // Set initially to whatever is known
    if (_selectedLatitude == null && _currentDeliveryAddress == defaultFull) {
      _selectedLatitude = userCtrl.latitude;
      _selectedLongitude = userCtrl.longitude;
    }

    if (_currentDeliveryAddress != defaultFull && _currentDeliveryAddress.isNotEmpty) {
      currentDoor = '';
      currentStreet = _currentDeliveryAddress;
      currentCity = '';
      currentPincode = '';
    }

    final doorNoCtrl = TextEditingController(text: currentDoor);
    final streetCtrl = TextEditingController(text: currentStreet);
    final cityCtrl = TextEditingController(text: currentCity);
    final pincodeCtrl = TextEditingController(text: currentPincode);
    bool saveAsDefault = false;
    
    double? tempLat = _selectedLatitude;
    double? tempLng = _selectedLongitude;
    bool _isFetchingLocation = false;

    Future<void> _handleCurrentLocation(StateSetter setModalState) async {
      setModalState(() {
        _isFetchingLocation = true;
      });
      try {
        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Location services are disabled. Please enable GPS.')),
            );
          }
          await Geolocator.openLocationSettings();
          return;
        }

        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
          if (permission == LocationPermission.denied) return;
        }
        if (permission == LocationPermission.deniedForever) return;

        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
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

            setModalState(() {
              doorNoCtrl.text = address['house_number'] ?? '';
              streetCtrl.text = [road, suburb].where((e) => e.isNotEmpty).join(', ');
              if (streetCtrl.text.isEmpty) streetCtrl.text = data['display_name'] ?? '';
              cityCtrl.text = [city, state].where((e) => e.isNotEmpty).join(', ');
              pincodeCtrl.text = postcode;
              tempLat = position.latitude;
              tempLng = position.longitude;
            });
          }
        }
      } catch (e) {
        debugPrint('Error getting location: $e');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error getting location: $e')));
        }
      } finally {
        setModalState(() {
          _isFetchingLocation = false;
        });
      }
    }

    Future<void> _handleMapSelection(StateSetter setModalState, BuildContext sheetContext) async {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MapSelectionScreen(
            initialLat: tempLat,
            initialLng: tempLng,
          ),
        ),
      );

      if (result != null && result is Map<String, dynamic>) {
        setModalState(() {
          tempLat = result['latitude'];
          tempLng = result['longitude'];
          doorNoCtrl.text = result['doorNo'] ?? '';
          streetCtrl.text = result['street'] ?? '';
          cityCtrl.text = result['city'] ?? '';
          pincodeCtrl.text = result['pincode'] ?? '';
        });
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => StatefulBuilder(
        builder: (modalContext, setModalState) {
          return Container(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(modalContext).viewInsets.bottom + 20,
            ),
            decoration: const BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.outlineVariant,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Select Delivery Address',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Location Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isFetchingLocation ? null : () => _handleCurrentLocation(setModalState),
                          icon: _isFetchingLocation 
                              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Icon(Icons.my_location, size: 18),
                          label: Text(
                            _isFetchingLocation ? 'Locating...' : 'Current Location',
                            style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secondaryContainer,
                            foregroundColor: AppColors.secondary,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _handleMapSelection(setModalState, sheetContext),
                          icon: const Icon(Icons.map, size: 18),
                          label: Text(
                            'Pin on Map',
                            style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secondaryContainer,
                            foregroundColor: AppColors.secondary,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text('OR ENTER MANUALLY', style: GoogleFonts.plusJakartaSans(fontSize: 10, color: AppColors.onSurfaceVariant, fontWeight: FontWeight.bold)),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: TextField(
                          controller: doorNoCtrl,
                          decoration: InputDecoration(
                            labelText: 'Door No',
                            labelStyle: GoogleFonts.plusJakartaSans(fontSize: 13),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: streetCtrl,
                          decoration: InputDecoration(
                            labelText: 'Street',
                            labelStyle: GoogleFonts.plusJakartaSans(fontSize: 13),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: cityCtrl,
                          decoration: InputDecoration(
                            labelText: 'City',
                            labelStyle: GoogleFonts.plusJakartaSans(fontSize: 13),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: pincodeCtrl,
                          decoration: InputDecoration(
                            labelText: 'Pincode',
                            labelStyle: GoogleFonts.plusJakartaSans(fontSize: 13),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () {
                      setModalState(() {
                        saveAsDefault = !saveAsDefault;
                      });
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: Row(
                        children: [
                          Checkbox(
                            value: saveAsDefault,
                            activeColor: AppColors.primary,
                            onChanged: (val) {
                              setModalState(() {
                                saveAsDefault = val ?? false;
                              });
                            },
                          ),
                          Expanded(
                            child: Text(
                              'Save as my default profile address',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                color: AppColors.onSurface,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(sheetContext),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: Text(
                            'Cancel',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.bold,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            final doorNo = doorNoCtrl.text.trim();
                            final street = streetCtrl.text.trim();
                            final city = cityCtrl.text.trim();
                            final pincode = pincodeCtrl.text.trim();
                            
                            final fullStr = [doorNo, street, city, pincode].where((p) => p.isNotEmpty).join(', ');

                            if (fullStr.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Please enter an address')),
                              );
                              return;
                            }

                            if (saveAsDefault) {
                              await userCtrl.updateAddress(
                                doorNo: doorNo,
                                street: street,
                                city: city,
                                pincode: pincode,
                                latitude: tempLat,
                                longitude: tempLng,
                              );
                            }
                            
                            setState(() {
                              _currentDeliveryAddress = fullStr;
                              _selectedLatitude = tempLat;
                              _selectedLongitude = tempLng;
                              _isAddressConfirmed = true;
                            });

                            if (sheetContext.mounted) {
                              Navigator.pop(sheetContext);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.onPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: Text(
                            saveAsDefault ? 'Save & Apply' : 'Apply to Order',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLow,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: AppBar(
          backgroundColor: AppColors.surfaceContainerLow,
          elevation: 1,
          shadowColor: Colors.black.withOpacity(0.04),
          titleSpacing: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.onSurface, size: 24),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Payment Method',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
              letterSpacing: -0.5,
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order Summary Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Amount Payable',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₹${widget.totalAmount.toInt()}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ADDRESS CARD
                Text(
                  'DELIVERY ADDRESS',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _isAddressConfirmed ? AppColors.surfaceContainerLowest : const Color(0xFFF0FDF4),
                    border: Border.all(
                      color: _isAddressConfirmed ? AppColors.outlineVariant.withOpacity(0.5) : const Color(0xFF16A34A),
                      width: _isAddressConfirmed ? 1 : 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.location_on, color: _isAddressConfirmed ? AppColors.onSurfaceVariant : const Color(0xFF16A34A), size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Delivering to',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.onSurface,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _currentDeliveryAddress,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                color: AppColors.onSurfaceVariant,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _isAddressConfirmed = false;
                          });
                          _showEditAddressModal(context);
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          _isAddressConfirmed ? 'Change' : 'Edit',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isAddressConfirmed ? null : () {
                      setState(() {
                        _isAddressConfirmed = true;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isAddressConfirmed ? const Color(0xFFDCFCE7) : AppColors.primary,
                      foregroundColor: _isAddressConfirmed ? const Color(0xFF16A34A) : AppColors.onPrimary,
                      elevation: _isAddressConfirmed ? 0 : 4,
                      shadowColor: AppColors.primary.withOpacity(0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_isAddressConfirmed) ...[
                          const Icon(Icons.check_circle, size: 20, color: Color(0xFF16A34A)),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          _isAddressConfirmed ? 'CONFIRMED' : 'CONFIRM ADDRESS',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),
                
                Text(
                  'SELECT PAYMENT METHOD',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),

                // UPI Option
                GestureDetector(
                  onTap: () => setState(() => _paymentMethod = 'upi'),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: _paymentMethod == 'upi' ? const Color(0xFFF0FDF4) : AppColors.surfaceContainerLowest,
                      border: Border.all(
                        color: _paymentMethod == 'upi' ? const Color(0xFF16A34A) : AppColors.outlineVariant.withOpacity(0.5),
                        width: _paymentMethod == 'upi' ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: _paymentMethod == 'upi' ? const Color(0xFFDCFCE7) : AppColors.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(Icons.account_balance_wallet, size: 20, color: _paymentMethod == 'upi' ? const Color(0xFF16A34A) : AppColors.onSurfaceVariant),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'UPI',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.onSurface,
                                  ),
                                ),
                                Text(
                                  'Google Pay, PhonePe, Paytm',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Radio<String>(
                          value: 'upi',
                          groupValue: _paymentMethod,
                          onChanged: (val) => setState(() => _paymentMethod = val!),
                          activeColor: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // COD Option
                GestureDetector(
                  onTap: () => setState(() => _paymentMethod = 'cod'),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: _paymentMethod == 'cod' ? const Color(0xFFF0FDF4) : AppColors.surfaceContainerLowest,
                      border: Border.all(
                        color: _paymentMethod == 'cod' ? const Color(0xFF16A34A) : AppColors.outlineVariant.withOpacity(0.5),
                        width: _paymentMethod == 'cod' ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(Icons.payments, size: 20, color: _paymentMethod == 'cod' ? const Color(0xFF16A34A) : AppColors.onSurfaceVariant),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Cash on Delivery',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.onSurface,
                                  ),
                                ),
                                Text(
                                  'Pay cash or scan QR at doorstep',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Radio<String>(
                          value: 'cod',
                          groupValue: _paymentMethod,
                          onChanged: (val) => setState(() => _paymentMethod = val!),
                          activeColor: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Sticky Bottom Action Area
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 24),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                border: Border(top: BorderSide(color: AppColors.outlineVariant.withOpacity(0.2))),
              ),
              child: SafeArea(
                child: Center(
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: (_isProcessing || _paymentMethod == null || !_isAddressConfirmed) ? null : () async {
                        setState(() {
                          _isProcessing = true;
                        });

                        final orderId = 'ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(5, 10)}';
                        String finalPaymentMethod = 'Cash on Delivery';

                        if (_paymentMethod == 'upi') {
                          // Assign correct UPI ID for Seller ID 1001 (Ragul) or a default one
                          final upiId = widget.sellerId == '1001' ? 'ragulcbs64-1@okaxis' : 'bluedropwater@okhdfcbank';

                          final selectedApp = await UpiPaymentSheet.show(
                            context: context,
                            totalAmount: widget.totalAmount,
                            orderId: orderId,
                            shopName: widget.shopName,
                            upiId: upiId,
                          );

                          if (selectedApp == null) {
                            setState(() {
                              _isProcessing = false;
                            });
                            return;
                          }
                          finalPaymentMethod = 'UPI ($selectedApp)';
                        }

                        final userCtrl = Provider.of<UserController>(context, listen: false);

                        final newOrder = OrderModel(
                          id: orderId,
                          items: widget.items,
                          totalAmount: widget.totalAmount,
                          timestamp: DateTime.now(),
                          paymentMethod: finalPaymentMethod,
                          shopName: widget.shopName,
                          deliveryAddress: _currentDeliveryAddress,
                          latitude: _selectedLatitude,
                          longitude: _selectedLongitude,
                          customerName: userCtrl.customerName,
                          customerPhone: userCtrl.phone,
                          isFastDelivery: widget.isFastDelivery,
                          sellerId: widget.sellerId,
                        );

                        Provider.of<OrderController>(context, listen: false).placeOrder(newOrder);

                        if (context.mounted) {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext dialogCtx) {
                              return AlertDialog(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                backgroundColor: AppColors.surfaceContainerLowest,
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 72,
                                      height: 72,
                                      decoration: BoxDecoration(
                                        color: AppColors.secondaryContainer,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.check_circle,
                                        size: 56,
                                        color: AppColors.secondary,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Order Placed!',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.onSurface,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Your order has been placed successfully.',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 14,
                                        color: AppColors.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                                actions: [
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(dialogCtx); // close dialog
                                        Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => BuyerDashboardScreen(
                                              customerName: userCtrl.customerName,
                                              address: userCtrl.fullAddress,
                                              phone: userCtrl.phone,
                                            ),
                                          ),
                                          (route) => false,
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        foregroundColor: AppColors.onPrimary,
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                      child: Text(
                                        'CONTINUE',
                                        style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ).then((_) {
                            if (mounted) {
                              setState(() {
                                _isProcessing = false;
                              });
                            }
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.onPrimary,
                        elevation: 4,
                        shadowColor: AppColors.primary.withOpacity(0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isProcessing 
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : Text(
                            _paymentMethod == 'upi' 
                                ? 'PAY ₹${widget.totalAmount.toInt()} & PLACE ORDER' 
                                : (_paymentMethod == 'cod' ? 'PLACE ORDER' : 'SELECT PAYMENT METHOD'),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
