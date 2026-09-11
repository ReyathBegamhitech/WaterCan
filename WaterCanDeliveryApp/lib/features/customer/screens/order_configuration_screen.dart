import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/constants/app_colors.dart';
import '../models/order_model.dart';
import '../models/product_model.dart';
import 'payment_status_screen.dart';

class OrderConfigurationScreen extends StatefulWidget {
  final Map<String, String> shop;

  const OrderConfigurationScreen({super.key, required this.shop});

  @override
  State<OrderConfigurationScreen> createState() => _OrderConfigurationScreenState();
}

class _OrderConfigurationScreenState extends State<OrderConfigurationScreen> {
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

  // Prices per can
  final int price25L = 50;
  final int price15L = 35;
  final int price5L = 25;
  final int emptyCanDeposit = 150;

  int _calculateTotal() {
    int total = 0;
    
    // 25L logic
    total += qty25L * price25L;
    if (!hasEmpty25L) {
      total += qty25L * emptyCanDeposit;
    } else {
      int missing25L = qty25L - empty25L;
      if (missing25L > 0) total += missing25L * emptyCanDeposit;
    }

    // 15L logic
    total += qty15L * price15L;
    if (!hasEmpty15L) {
      total += qty15L * emptyCanDeposit;
    } else {
      int missing15L = qty15L - empty15L;
      if (missing15L > 0) total += missing15L * emptyCanDeposit;
    }

    // 5L logic
    total += qty5L * price5L;
    if (!hasEmpty5L) {
      total += qty5L * emptyCanDeposit;
    } else {
      int missing5L = qty5L - empty5L;
      if (missing5L > 0) total += missing5L * emptyCanDeposit;
    }

    return total;
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
      backgroundColor: AppColors.primary.withOpacity(0.1),

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

                // Delivery Address Section
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.3),
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'DELIVERY ADDRESS',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          InkWell(
                            onTap: () {},
                            borderRadius: BorderRadius.circular(6),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1),
                              ),
                              child: Text(
                                'EDIT',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.location_on_outlined, color: AppColors.primary, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Flat 402, Green Glen Heights, Sector 4, Outer Ring Road, Bellandur, Bengaluru - 560103',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.onSurface,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

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

                // PAYMENT METHOD Section
                Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(14),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'PAYMENT METHOD',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          Text(
                            '100% Secure',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColors.outline,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      
                      // UPI Option
                      GestureDetector(
                        onTap: () => setState(() => _paymentMethod = 'upi'),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: _paymentMethod == 'upi' ? const Color(0xFFF0FDF4) : Colors.transparent, // light green background
                            border: Border.all(
                              color: _paymentMethod == 'upi' ? const Color(0xFF16A34A) : AppColors.outlineVariant.withOpacity(0.5),
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceContainerLowest,
                                      border: Border.all(
                                        color: _paymentMethod == 'upi' ? const Color(0xFFDCFCE7) : AppColors.outlineVariant.withOpacity(0.3),
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.02),
                                          blurRadius: 2,
                                          offset: const Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                    child: Icon(Icons.account_balance_wallet, size: 18, color: _paymentMethod == 'upi' ? const Color(0xFF16A34A) : AppColors.onSurfaceVariant),
                                  ),
                                  const SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'UPI',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.onSurface,
                                          height: 1.2,
                                        ),
                                      ),
                                      Text(
                                        'Google Pay, PhonePe, Paytm & more',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 10,
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
                                visualDensity: VisualDensity.compact,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // COD Option
                      GestureDetector(
                        onTap: () => setState(() => _paymentMethod = 'cod'),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: _paymentMethod == 'cod' ? const Color(0xFFF0FDF4) : AppColors.surface, // light green background
                            border: Border.all(
                              color: _paymentMethod == 'cod' ? const Color(0xFF16A34A) : AppColors.outlineVariant.withOpacity(0.5),
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: AppColors.surface,
                                      border: Border.all(
                                        color: AppColors.outlineVariant.withOpacity(0.5),
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.02),
                                          blurRadius: 2,
                                          offset: const Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                    child: Icon(Icons.payments, size: 18, color: _paymentMethod == 'cod' ? const Color(0xFF16A34A) : AppColors.onSurfaceVariant),
                                  ),
                                  const SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Cash on Delivery',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.onSurface,
                                          height: 1.2,
                                        ),
                                      ),
                                      Text(
                                        'Pay cash or scan QR at doorstep',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 10,
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
                                visualDensity: VisualDensity.compact,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // TOTAL AMOUNT Section
                Container(
                  padding: const EdgeInsets.all(14),
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'TOTAL AMOUNT',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                          color: AppColors.onSurface,
                        ),
                      ),
                      Text(
                        '₹${_calculateTotal()}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
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
                    onPressed: () {
                      if (_calculateTotal() == 0) return; // Prevent empty orders
                      
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
                            shopName: 'Blue Drop Water Co.',
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
                            shopName: 'Blue Drop Water Co.',
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
                            shopName: 'Blue Drop Water Co.',
                          ),
                        ));
                      }
                      
                      final newOrder = OrderModel(
                        id: 'ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(5, 10)}',
                        items: items,
                        totalAmount: _calculateTotal().toDouble(),
                        timestamp: DateTime.now(),
                        paymentMethod: _paymentMethod,
                        shopName: 'Blue Drop Water Co.',
                      );

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PaymentStatusScreen(
                            order: newOrder,
                          ),
                        ),
                      );
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
                      _paymentMethod == 'upi' 
                          ? 'PAY ₹${_calculateTotal()} & PLACE ORDER' 
                          : 'PLACE ORDER',
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
