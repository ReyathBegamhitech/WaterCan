import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../models/order_model.dart';
import '../models/product_model.dart';
import '../controllers/order_controller.dart';
import '../controllers/user_controller.dart';
import '../widgets/upi_payment_sheet.dart';
import 'payment_status_screen.dart';
import 'buyer_dashboard.dart';
import 'payment_method_screen.dart';

class OrderConfigurationScreen extends StatefulWidget {
  final Map<String, String> shop;
  final String? deliveryAddress;

  const OrderConfigurationScreen({
    super.key,
    required this.shop,
    this.deliveryAddress,
  });

  @override
  State<OrderConfigurationScreen> createState() => _OrderConfigurationScreenState();
}

class _OrderConfigurationScreenState extends State<OrderConfigurationScreen> {
  String? _customDeliveryAddress;
  bool _isProcessing = false;

  String _getEffectiveDeliveryAddress(BuildContext context) {
    if (_customDeliveryAddress != null && _customDeliveryAddress!.trim().isNotEmpty) {
      return _customDeliveryAddress!;
    }
    if (widget.deliveryAddress != null && widget.deliveryAddress!.trim().isNotEmpty) {
      return widget.deliveryAddress!;
    }
    final userAddress = Provider.of<UserController>(context, listen: false).fullAddress;
    if (userAddress.isNotEmpty && userAddress != 'No address provided') {
      return userAddress;
    }
    return UserController.defaultFullAddress;
  }

  void _showEditAddressModal(BuildContext context) {
    final currentAddress = _getEffectiveDeliveryAddress(context);
    final ctrl = TextEditingController(text: currentAddress);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
        ),
        decoration: const BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
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
              'Customizing delivery address for this order',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: ctrl,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Delivery Address',
                labelStyle: GoogleFonts.plusJakartaSans(fontSize: 13),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                prefixIcon: const Icon(Icons.location_on_outlined, size: 20),
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
                    onPressed: () {
                      final updated = ctrl.text.trim();
                      if (updated.isNotEmpty) {
                        setState(() {
                          _customDeliveryAddress = updated;
                        });
                        Navigator.pop(sheetContext);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Delivery address updated for this order!')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text(
                      'Update',
                      style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // State variables for each can size
  int qty25L = 1;
  bool hasEmpty25L = true;
  int empty25L = 1;

  int qty15L = 0;
  bool hasEmpty15L = false;
  int empty15L = 0;

  int qty5L = 0;
  bool hasEmpty5L = false;
  int empty5L = 0;

  String _paymentMethod = 'upi';
  bool _isFastDelivery = false;

  // Prices per can
  final int price25L = 50;
  final int price15L = 30;
  final int price5L = 20;

  int _calculateTotal() {
    int total = 0;
    
    // 25L logic
    total += qty25L * price25L;
    if (hasEmpty25L && empty25L > 0) {
      total -= empty25L * 10;
    }

    // 15L logic
    total += qty15L * price15L;
    if (hasEmpty15L && empty15L > 0) {
      total -= empty15L * 10;
    }

    // 5L logic
    total += qty5L * price5L;
    if (hasEmpty5L && empty5L > 0) {
      total -= empty5L * 10;
    }

    if (_isFastDelivery) {
      total += 50;
    }

    return total > 0 ? total : 0;
  }

  // SVG Strings
  final String svg25L = '''
<svg viewBox="0 0 60 80" xmlns="http://www.w3.org/2000/svg">
<rect fill="#1d4ed8" height="6" rx="2" width="16" x="22" y="2"></rect>
<rect fill="#60a5fa" height="6" width="12" x="24" y="8"></rect>
<rect fill="#93c5fd" fill-opacity="0.85" height="62" rx="8" stroke="#3b82f6" stroke-width="1.5" width="40" x="10" y="14"></rect>
<line stroke="#2563eb" stroke-opacity="0.5" stroke-width="1.5" x1="12" x2="48" y1="28" y2="28"></line>
<line stroke="#2563eb" stroke-opacity="0.5" stroke-width="1.5" x1="12" x2="48" y1="42" y2="42"></line>
<line stroke="#2563eb" stroke-opacity="0.5" stroke-width="1.5" x1="12" x2="48" y1="56" y2="56"></line>
<path d="M11 38 Q30 42 49 38 L49 68 Q49 74 43 74 L17 74 Q11 74 11 68 Z" fill="#3b82f6" fill-opacity="0.3"></path>
<path d="M49 26 C55 26 56 36 49 38" stroke="#1d4ed8" stroke-linecap="round" stroke-width="2.5"></path>
</svg>
''';

  final String svg15L = '''
<svg viewBox="0 0 60 80" xmlns="http://www.w3.org/2000/svg">
<rect fill="#1d4ed8" height="6" rx="2" width="14" x="23" y="6"></rect>
<rect fill="#60a5fa" height="5" width="10" x="25" y="12"></rect>
<rect fill="#93c5fd" fill-opacity="0.85" height="56" rx="7" stroke="#3b82f6" stroke-width="1.5" width="34" x="13" y="17"></rect>
<rect fill="#1e3a8a" height="5" width="6" x="27" y="55"></rect>
<path d="M30 60 L30 66" stroke="#1e3a8a" stroke-width="2"></path>
<line stroke="#2563eb" stroke-opacity="0.5" stroke-width="1.5" x1="15" x2="45" y1="30" y2="30"></line>
<line stroke="#2563eb" stroke-opacity="0.5" stroke-width="1.5" x1="15" x2="45" y1="44" y2="44"></line>
<path d="M14 20 C10 20 10 32 14 34" stroke="#1d4ed8" stroke-linecap="round" stroke-width="2.5"></path>
</svg>
''';

  final String svg5L = '''
<svg viewBox="0 0 60 80" xmlns="http://www.w3.org/2000/svg">
<rect fill="#1d4ed8" height="5" rx="1.5" width="12" x="24" y="14"></rect>
<rect fill="#60a5fa" height="4" width="8" x="26" y="19"></rect>
<rect fill="#93c5fd" fill-opacity="0.85" height="48" rx="6" stroke="#3b82f6" stroke-width="1.5" width="28" x="16" y="23"></rect>
<line stroke="#2563eb" stroke-opacity="0.5" stroke-width="1.5" x1="18" x2="42" y1="36" y2="36"></line>
<line stroke="#2563eb" stroke-opacity="0.5" stroke-width="1.5" x1="18" x2="42" y1="48" y2="48"></line>
<path d="M22 23 C22 17 38 17 38 23" stroke="#2563eb" stroke-width="2"></path>
</svg>
''';

  Widget _buildCounter(int value, Function(int) onChanged, {int min = 0}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.surface, // slate-50
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)), // slate-300
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: value > min ? () => onChanged(value - 1) : null,
            child: Container(
              width: 20,
              height: 20,
              alignment: Alignment.center,
              child: Text(
                '−',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: value > min ? AppColors.onSurface : AppColors.onSurfaceVariant.withOpacity(0.5),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 16,
            child: Text(
              value.toString(),
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface,
              ),
            ),
          ),
          InkWell(
            onTap: () => onChanged(value + 1),
            child: Container(
              width: 20,
              height: 20,
              alignment: Alignment.center,
              child: const Text(
                '+',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductSection({
    required String title,
    required String svgData,
    required int qty,
    required bool hasEmpty,
    required int emptyQty,
    required Function(int) onQtyChanged,
    required Function(bool) onHasEmptyChanged,
    required Function(int) onEmptyQtyChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left SVG Icon Box
          Container(
            width: 96,
            height: 120, // To roughly match the layout height
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF).withOpacity(0.6), // blue-50
              border: Border.all(color: const Color(0xFFDBEAFE).withOpacity(0.8)), // blue-100
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 48,
                  height: 64,
                  child: SvgPicture.string(svgData),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          
          // Right Controls
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // QTY NEEDED
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'QTY NEEDED:',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurfaceVariant,
                        letterSpacing: -0.5,
                      ),
                    ),
                    _buildCounter(qty, onQtyChanged),
                  ],
                ),
                const SizedBox(height: 12),

                // HAVE EMPTY CAN?
                Text(
                  'HAVE EMPTY CAN?',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurfaceVariant,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Row(
                      children: [
                        Radio<bool>(
                          value: true,
                          groupValue: hasEmpty,
                          onChanged: (val) => onHasEmptyChanged(val!),
                          activeColor: AppColors.primary,
                          visualDensity: VisualDensity.compact,
                        ),
                        Text(
                          'YES',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Row(
                      children: [
                        Radio<bool>(
                          value: false,
                          groupValue: hasEmpty,
                          onChanged: (val) => onHasEmptyChanged(val!),
                          activeColor: AppColors.primary,
                          visualDensity: VisualDensity.compact,
                        ),
                        Text(
                          'NO',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // IF YES Counter
                Opacity(
                  opacity: hasEmpty ? 1.0 : 0.4,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'IF YES:',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      IgnorePointer(
                        ignoring: !hasEmpty,
                        child: _buildCounter(
                          emptyQty,
                          onEmptyQtyChanged,
                          min: 0,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLow,

      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back Arrow & Title
                Row(
                  children: [
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLowest,
                          border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.arrow_back, size: 20, color: AppColors.onSurface),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Payment Details',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurface,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),



                // 25L CAN Section
                _buildProductSection(
                  title: '25L CAN',
                  svgData: svg25L,
                  qty: qty25L,
                  hasEmpty: hasEmpty25L,
                  emptyQty: empty25L,
                  onQtyChanged: (val) {
                    setState(() {
                      qty25L = val;
                      if (empty25L > qty25L) empty25L = qty25L;
                    });
                  },
                  onHasEmptyChanged: (val) => setState(() => hasEmpty25L = val),
                  onEmptyQtyChanged: (val) => setState(() => empty25L = val > qty25L ? qty25L : val),
                ),

                // 15L CAN Section
                _buildProductSection(
                  title: '15L CAN',
                  svgData: svg15L,
                  qty: qty15L,
                  hasEmpty: hasEmpty15L,
                  emptyQty: empty15L,
                  onQtyChanged: (val) {
                    setState(() {
                      qty15L = val;
                      if (empty15L > qty15L) empty15L = qty15L;
                    });
                  },
                  onHasEmptyChanged: (val) => setState(() => hasEmpty15L = val),
                  onEmptyQtyChanged: (val) => setState(() => empty15L = val > qty15L ? qty15L : val),
                ),

                // 5L CAN Section
                _buildProductSection(
                  title: '5L CAN',
                  svgData: svg5L,
                  qty: qty5L,
                  hasEmpty: hasEmpty5L,
                  emptyQty: empty5L,
                  onQtyChanged: (val) {
                    setState(() {
                      qty5L = val;
                      if (empty5L > qty5L) empty5L = qty5L;
                    });
                  },
                  onHasEmptyChanged: (val) => setState(() => hasEmpty5L = val),
                  onEmptyQtyChanged: (val) => setState(() => empty5L = val > qty5L ? qty5L : val),
                ),



                // DELIVERY OPTIONS Section
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'DELIVERY OPTIONS',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.onSurfaceVariant,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const Icon(Icons.local_shipping, size: 16, color: AppColors.primary),
                        ],
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () => setState(() => _isFastDelivery = false),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: !_isFastDelivery ? const Color(0xFFF0FDF4) : Colors.transparent,
                            border: Border.all(color: !_isFastDelivery ? const Color(0xFF16A34A) : AppColors.outlineVariant.withOpacity(0.5)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Radio<bool>(
                                value: false,
                                groupValue: _isFastDelivery,
                                onChanged: (val) => setState(() => _isFastDelivery = val!),
                                activeColor: AppColors.primary,
                                visualDensity: VisualDensity.compact,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Standard Delivery', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
                                    Text('Delivered by end of day', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.onSurfaceVariant)),
                                  ],
                                ),
                              ),
                              Text('FREE', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w900, color: const Color(0xFF16A34A))),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () => setState(() => _isFastDelivery = true),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: _isFastDelivery ? const Color(0xFFFFF1F2) : Colors.transparent,
                            border: Border.all(color: _isFastDelivery ? const Color(0xFFE11D48) : AppColors.outlineVariant.withOpacity(0.5)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Radio<bool>(
                                value: true,
                                groupValue: _isFastDelivery,
                                onChanged: (val) => setState(() => _isFastDelivery = val!),
                                activeColor: const Color(0xFFE11D48),
                                visualDensity: VisualDensity.compact,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text('Fast Delivery', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFFE11D48))),
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(color: const Color(0xFFE11D48), borderRadius: BorderRadius.circular(4)),
                                          child: Text('⚡ PRIORITY', style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5)),
                                        ),
                                      ],
                                    ),
                                    Text('Delivered in 30-45 mins', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.onSurfaceVariant)),
                                  ],
                                ),
                              ),
                              Text('+₹50', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w900, color: const Color(0xFFE11D48))),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // TOTAL AMOUNT Breakdown Section
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'BILL DETAILS',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onSurfaceVariant,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Builder(
                        builder: (context) {
                          int subtotal = (qty25L * price25L) + (qty15L * price15L) + (qty5L * price5L);
                          int emptyDiscount = 0;
                          if (hasEmpty25L && empty25L > 0) emptyDiscount += empty25L * 10;
                          if (hasEmpty15L && empty15L > 0) emptyDiscount += empty15L * 10;
                          if (hasEmpty5L && empty5L > 0) emptyDiscount += empty5L * 10;
                          int finalTotal = _calculateTotal();
                          return Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Item Subtotal', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.onSurface)),
                                  Text('₹$subtotal', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
                                ],
                              ),
                              if (emptyDiscount > 0) ...[
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.recycling, size: 14, color: Color(0xFF16A34A)),
                                        const SizedBox(width: 4),
                                        Text('Empty Can Discount', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF16A34A))),
                                      ],
                                    ),
                                    Text('-₹$emptyDiscount', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF16A34A))),
                                  ],
                                ),
                              ],
                              if (_isFastDelivery) ...[
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.bolt, size: 14, color: Color(0xFFE11D48)),
                                        const SizedBox(width: 4),
                                        Text('Fast Delivery Fee', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.onSurface)),
                                      ],
                                    ),
                                    Text('+₹50', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
                                  ],
                                ),
                              ],
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                child: Divider(height: 1),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'TO PAY',
                                    style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                                  ),
                                  Text(
                                    '₹$finalTotal',
                                    style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.primary),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                    ],
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
                    width: 280, // Medium-lengthened width
                    height: 52,
                    child: ElevatedButton(
                    onPressed: _isProcessing ? null : () async {
                      if (_calculateTotal() == 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please add at least 1 water can to proceed.'),
                            behavior: SnackBarBehavior.floating,
                            duration: Duration(seconds: 2),
                          ),
                        );
                        return;
                      }

                      setState(() {
                        _isProcessing = true;
                      });
                      
                      final items = <CartItem>[];
                      if (qty25L > 0) {
                        items.add(CartItem(
                          quantity: qty25L,
                          returnEmptyCans: hasEmpty25L ? empty25L : 0,
                          product: ProductModel(
                            id: 'p1',
                            name: '25L Refill Can',
                            price: price25L.toDouble(),
                            imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBtFDY8L4f3JKhamQcGZaXg9fa3RstoZchc3JyiqdlCNdnoRt3Qcx-nqXK6C8KSNnLdAVkSLH0Khz0Gjfs1iqcSazsbdqrIdHyiCWDlN5zWyCoyjQQNDczOhlThRGzp_LzSDQ2Nz09alZY_AGfZsVC0LmgNveXjKZNx4OlCrdScsnSvLD289zYwQg2zj4qj6ZKYCIih2Z3FCEpQ8gCVbVwBXNMvyme2fFUzskpD8cCUrBVLis1pbaR2',
                            shopName: widget.shop['name'] ?? 'Blue Drop Water Co.',
                          ),
                        ));
                      }
                      if (qty15L > 0) {
                        items.add(CartItem(
                          quantity: qty15L,
                          returnEmptyCans: hasEmpty15L ? empty15L : 0,
                          product: ProductModel(
                            id: 'p2',
                            name: '15L Dispenser Can',
                            price: price15L.toDouble(),
                            imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCdgL5IALKwRiltkZqoDMPcUa05FP4rMG9v-qW6t8D4_zGjCmXjT3G-9136bYs4gNs1gwqj4Jhu8tKzSN5lYDggj7q8OWb9wN8ZYR_Zq3MeXiRtfI4B-j4OH1vu_Ytth_s5CS1d66rgOrMPT-yN5sCA4JNi9-gJwvG_UEkRCpHmSmJx6lBK37PXHS0p01SfsVvpKIz5U40POAZZAQnGDXkozBGSxWHHKC5PGnkqtlUcBdulK-w9xpi_',
                            shopName: widget.shop['name'] ?? 'Blue Drop Water Co.',
                          ),
                        ));
                      }
                      if (qty5L > 0) {
                        items.add(CartItem(
                          quantity: qty5L,
                          returnEmptyCans: hasEmpty5L ? empty5L : 0,
                          product: ProductModel(
                            id: 'p3',
                            name: '5L Mini Bottle',
                            price: price5L.toDouble(),
                            imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAet-1rb_NdGWMMjB0XFPCWZs2tPo8xJNywp8bDviNbrW1eTNTvTqz1DncuC9UeqWDgVcJ1bThd1934sHn2W06qu1I66hWvCwXinOF2P3b2k16ZaytIs71YkQtu7D4MJs1ziN9RhomXmlwrD-nEHxfXf1ewFzMWe_VWURXG5vlGv80c5UgH4nHuLubO2b4VRABwgmNL1Z5VrnOJzHgj6sihTjjWy1lWQw_qw8ykVRG5Pw23NdZ83OOh',
                            shopName: widget.shop['name'] ?? 'Blue Drop Water Co.',
                          ),
                        ));
                      }
                      
                      final totalAmount = _calculateTotal().toDouble();
                      final currentShopName = widget.shop['name'] ?? 'Blue Drop Water Co.';
                      final effectiveDeliveryAddress = _getEffectiveDeliveryAddress(context);

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PaymentMethodScreen(
                            items: items,
                            totalAmount: totalAmount,
                            shopName: currentShopName,
                            deliveryAddress: effectiveDeliveryAddress,
                            isFastDelivery: _isFastDelivery,
                            sellerId: widget.shop['id'] ?? '',
                          ),
                        ),
                      ).then((_) {
                        if (mounted) setState(() => _isProcessing = false);
                      });
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
                    child: Text(
                      'PROCEED TO PAYMENT',
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
