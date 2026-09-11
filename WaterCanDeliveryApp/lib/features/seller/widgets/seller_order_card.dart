import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';

class SellerOrderCard extends StatelessWidget {
  final String orderId;
  final String time;
  final String status; // 'Placed', 'Accepted', 'Preparing', 'Delivered'
  final String buyerName;
  final String buyerPhone;
  final int quantity;
  final int pricePerCan;
  final VoidCallback? onTap;

  const SellerOrderCard({
    super.key,
    required this.orderId,
    required this.time,
    required this.status,
    required this.buyerName,
    required this.buyerPhone,
    required this.quantity,
    required this.pricePerCan,
    this.onTap,
  });

  Color _getStatusBgColor() {
    switch (status) {
      case 'Placed':
        return Colors.blue.shade100;
      case 'Accepted':
        return AppColors.seller100;
      case 'Preparing':
        return Colors.amber.shade100;
      case 'Delivered':
        return Colors.green.shade100;
      default:
        return AppColors.seller100;
    }
  }

  Color _getStatusTextColor() {
    switch (status) {
      case 'Placed':
        return Colors.blue.shade800;
      case 'Accepted':
        return AppColors.seller800;
      case 'Preparing':
        return Colors.amber.shade800;
      case 'Delivered':
        return Colors.green.shade800;
      default:
        return AppColors.seller800;
    }
  }

  Color _getStatusBorderColor() {
    switch (status) {
      case 'Placed':
        return Colors.blue.shade200;
      case 'Accepted':
        return AppColors.seller200;
      case 'Preparing':
        return Colors.amber.shade200;
      case 'Delivered':
        return Colors.green.shade200;
      default:
        return AppColors.seller200;
    }
  }

  int _getStatusStep() {
    switch (status) {
      case 'Placed': return 0;
      case 'Accepted': return 1;
      case 'Preparing': return 2;
      case 'Delivered': return 3;
      default: return 0;
    }
  }

  Future<void> _makePhoneCall() async {
    final Uri launchUri = Uri(scheme: 'tel', path: buyerPhone);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade800, width: 2), // border-neutral-700 equivalent
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
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
                          orderId,
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
                  Text(
                    time,
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
                      status,
                      style: GoogleFonts.plusJakartaSans(
                        color: _getStatusTextColor(),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  InkWell(
                    onTap: () {},
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

          // Details Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text('Buyer:', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
                  const SizedBox(width: 6),
                  Text(buyerName, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87)),
                ],
              ),
              InkWell(
                onTap: _makePhoneCall,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.phone, size: 12, color: AppColors.seller600),
                      const SizedBox(width: 4),
                      Text(buyerPhone, style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.grey.shade700)),
                    ],
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 4),
          
          // Qty & Price Row
          Container(
            padding: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.grey.shade100))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text('Qty:', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(4)),
                      child: Text('$quantity Cans (20L)', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black87)),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text('₹$pricePerCan/can', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: Colors.grey.shade400)),
                    const SizedBox(width: 6),
                    Text('₹${quantity * pricePerCan}', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.seller700)),
                  ],
                )
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Progress Tracker
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
        ],
      ),
    ));
  }

  Widget _buildProgressStepper() {
    int currentStep = _getStatusStep();
    List<String> steps = ['Placed', 'Accepted', 'Preparing', 'Delivered'];

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
