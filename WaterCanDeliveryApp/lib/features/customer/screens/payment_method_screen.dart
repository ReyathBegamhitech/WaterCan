import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../models/order_model.dart';
import '../models/product_model.dart';
import '../controllers/order_controller.dart';
import '../controllers/user_controller.dart';
import '../widgets/upi_payment_sheet.dart';
import 'buyer_dashboard.dart';

class PaymentMethodScreen extends StatefulWidget {
  final List<CartItem> items;
  final double totalAmount;
  final String shopName;
  final String deliveryAddress;
  final bool isFastDelivery;

  const PaymentMethodScreen({
    super.key,
    required this.items,
    required this.totalAmount,
    required this.shopName,
    required this.deliveryAddress,
    required this.isFastDelivery,
  });

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  String? _paymentMethod;
  bool _isProcessing = false;
  bool _isAddressConfirmed = false;
  late String _currentDeliveryAddress;

  @override
  void initState() {
    super.initState();
    _currentDeliveryAddress = widget.deliveryAddress;
  }

  void _showEditAddressModal(BuildContext context) {
    final userCtrl = Provider.of<UserController>(context, listen: false);
    final defaultFull = userCtrl.fullAddress;

    String currentDoor = userCtrl.doorNo;
    String currentStreet = userCtrl.street;
    String currentCity = userCtrl.city;
    String currentPincode = userCtrl.pincode;

    if (_currentDeliveryAddress != defaultFull && _currentDeliveryAddress.isNotEmpty) {
      // If the address was customized, just put it all in street for now
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
                    'Edit Delivery Address',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Update delivery destination for your water cans',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: AppColors.onSurfaceVariant,
                    ),
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
                              );
                            }
                            
                            setState(() {
                              _currentDeliveryAddress = fullStr;
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
                          final selectedApp = await UpiPaymentSheet.show(
                            context: context,
                            totalAmount: widget.totalAmount,
                            orderId: orderId,
                            shopName: widget.shopName,
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
                          customerName: userCtrl.customerName,
                          customerPhone: userCtrl.phone,
                          isFastDelivery: widget.isFastDelivery,
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
