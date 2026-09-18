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
                      onPressed: (_isProcessing || _paymentMethod == null) ? null : () async {
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
                          deliveryAddress: widget.deliveryAddress,
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
                                              address: userCtrl.addressLine1,
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
