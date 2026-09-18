import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../customer/models/order_model.dart';

class SellerOrderCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback? onTap;
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;

  const SellerOrderCard({
    super.key,
    required this.order,
    this.onTap,
    this.onAccept,
    this.onDecline,
  });

  Color _getStatusBgColor() {
    switch (order.sellerStatusString) {
      case 'Placed':
        return Colors.blue.shade100;
      case 'Accepted':
        return AppColors.seller100;
      case 'Out for Delivery':
        return Colors.orange.shade100;
      case 'Delivered':
        return Colors.green.shade100;
      case 'Cancelled':
        return Colors.red.shade100;
      default:
        return AppColors.seller100;
    }
  }

  Color _getStatusTextColor() {
    switch (order.sellerStatusString) {
      case 'Placed':
        return Colors.blue.shade800;
      case 'Accepted':
        return AppColors.seller800;
      case 'Out for Delivery':
        return Colors.orange.shade800;
      case 'Delivered':
        return Colors.green.shade800;
      case 'Cancelled':
        return Colors.red.shade800;
      default:
        return AppColors.seller800;
    }
  }

  Color _getStatusBorderColor() {
    switch (order.sellerStatusString) {
      case 'Placed':
        return Colors.blue.shade200;
      case 'Accepted':
        return AppColors.seller200;
      case 'Out for Delivery':
        return Colors.orange.shade200;
      case 'Delivered':
        return Colors.green.shade200;
      case 'Cancelled':
        return Colors.red.shade200;
      default:
        return AppColors.seller200;
    }
  }

  int _getStatusStep() {
    switch (order.sellerStatusString) {
      case 'Placed': return 0;
      case 'Accepted': return 1;
      case 'Out for Delivery': return 2;
      case 'Delivered': return 3;
      default: return 0;
    }
  }

  Future<void> _makePhoneCall() async {
    final phone = order.customerPhone;
    if (phone == null || phone.isEmpty) return;
    final Uri launchUri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final buyerName = order.customerName?.isNotEmpty == true ? order.customerName! : 'Customer';
    final buyerPhone = order.customerPhone?.isNotEmpty == true ? order.customerPhone! : 'Not provided';
    final isUPI = order.paymentMethod.toLowerCase().contains('upi');
    final isCOD = order.paymentMethod.toLowerCase() == 'cod' || order.paymentMethod.toLowerCase().contains('cash on delivery');
    final showActions = isCOD && order.sellerStatusString == 'Placed';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 1.5), 
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0E4D7),
                      border: Border.all(color: const Color(0xFFD7C2B2)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.receipt_long, size: 14, color: Color(0xFF5C4033)),
                        const SizedBox(width: 4),
                        Text(
                          order.id.startsWith('#') ? order.id : '#${order.id}',
                          style: GoogleFonts.plusJakartaSans(
                            color: const Color(0xFF5C4033),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (order.isFastDelivery) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE11D48),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '⚡ FAST',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    order.formattedDate,
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.grey.shade500,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getStatusBgColor(),
                      border: Border.all(color: _getStatusBorderColor()),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      order.sellerStatusString,
                      style: GoogleFonts.plusJakartaSans(
                        color: _getStatusTextColor(),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  InkWell(
                    onTap: onTap,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.seller100,
                        border: Border.all(color: AppColors.seller200),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.chevron_right, size: 16, color: AppColors.seller700),
                    ),
                  )
                ],
              )
            ],
          ),
          const SizedBox(height: 12),

          // Details Row (Name and Phone)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.person, size: 16, color: AppColors.seller600),
                  const SizedBox(width: 6),
                  Text(buyerName, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
                ],
              ),
              InkWell(
                onTap: _makePhoneCall,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    border: Border.all(color: Colors.green.shade200),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.phone, size: 12, color: Colors.green),
                      const SizedBox(width: 4),
                      Text(buyerPhone, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green.shade800)),
                    ],
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 8),

          // Location
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on, size: 16, color: Colors.redAccent),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  order.deliveryAddress.isNotEmpty ? order.deliveryAddress : 'No address provided',
                  style: GoogleFonts.plusJakartaSans(fontSize: 13, color: Colors.grey.shade700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Order Items Details (Expandable)
          Container(
            decoration: BoxDecoration(
              color: AppColors.seller50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.seller200),
            ),
            child: Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                childrenPadding: const EdgeInsets.only(left: 12, right: 12, bottom: 12),
                iconColor: AppColors.seller800,
                collapsedIconColor: AppColors.seller600,
                title: Row(
                  children: [
                    const Icon(Icons.water_drop, size: 16, color: AppColors.seller500),
                    const SizedBox(width: 8),
                    Text(
                      '${order.totalQuantity}x Water Cans Ordered',
                      style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.black87),
                    ),
                  ],
                ),
                children: [
                  ...order.items.map((item) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8, left: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 5),
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(color: AppColors.seller400, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${item.quantity}x ${item.product.name}',
                                  style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87),
                                ),
                                if (item.returnEmptyCans != null && item.returnEmptyCans! > 0)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2),
                                    child: Text(
                                      '${item.returnEmptyCans} empty cans to return',
                                      style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.amber.shade800),
                                    ),
                                  ),
                                if (item.returnEmptyCans == 0 || item.returnEmptyCans == null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2),
                                    child: Text(
                                      'No empty cans provided',
                                      style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey.shade600),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Text(
                            '₹${(item.product.price * item.quantity).round() - ((item.returnEmptyCans ?? 0) * 10)}',
                            style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.seller800),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(isUPI ? Icons.qr_code : Icons.money, size: 16, color: isUPI ? Colors.purple : Colors.green),
                          const SizedBox(width: 6),
                          Text(
                            isUPI ? 'Paid via UPI' : 'Cash on Delivery',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13, 
                              fontWeight: FontWeight.bold, 
                              color: isUPI ? Colors.purple.shade700 : Colors.green.shade700,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'Total: ₹${order.totalAmount.round()}',
                        style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.black),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          if (showActions) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onDecline,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text('Decline', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onAccept,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text('Accept Order', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
          
          if (!showActions && order.sellerStatusString != 'Cancelled') ...[
            const SizedBox(height: 12),
            // Progress Tracker for non-placed/UPI orders
            Container(
              padding: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.grey.shade100))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Order progress:', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.grey.shade500)),
                  const SizedBox(height: 8),
                  _buildProgressStepper(),
                ],
              ),
            )
          ]
        ],
      ),
    ));
  }

  Widget _buildProgressStepper() {
    int currentStep = _getStatusStep();
    List<String> steps = ['Placed', 'Accepted', 'Out for Delivery', 'Delivered'];

    return Stack(
      children: [
        // Background line
        Positioned(
          top: 7,
          left: 20,
          right: 20,
          child: Container(height: 2, color: Colors.grey.shade200),
        ),
        // Active line
        Positioned(
          top: 7,
          left: 20,
          right: 20,
          child: LayoutBuilder(
            builder: (context, constraints) {
              double widthMultiplier = currentStep / (steps.length - 1);
              return Row(
                children: [
                  Container(height: 2, width: constraints.maxWidth * widthMultiplier, color: AppColors.seller500),
                ],
              );
            },
          ),
        ),
        // Nodes
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(steps.length, (index) {
            bool isActive = index <= currentStep;
            return Column(
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.seller500 : Colors.white,
                    shape: BoxShape.circle,
                    border: isActive ? null : Border.all(color: Colors.grey.shade300, width: 2),
                    boxShadow: isActive ? [
                      BoxShadow(color: AppColors.seller100, spreadRadius: 4)
                    ] : null,
                  ),
                  child: isActive ? Center(child: Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle))) : null,
                ),
                const SizedBox(height: 6),
                Text(
                  steps[index],
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    color: isActive ? AppColors.seller700 : Colors.grey.shade400,
                  ),
                )
              ],
            );
          }),
        )
      ],
    );
  }
}
