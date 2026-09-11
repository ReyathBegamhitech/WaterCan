import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';

class SellerHistoryOrderCard extends StatelessWidget {
  final String orderId;
  final String time;
  final String status; // 'Delivered' or 'Cancelled'
  final String buyerName;
  final String buyerPhone;
  final int amount;
  final String address;

  const SellerHistoryOrderCard({
    super.key,
    required this.orderId,
    required this.time,
    required this.status,
    required this.buyerName,
    required this.buyerPhone,
    required this.amount,
    required this.address,
  });

  bool get isDelivered => status == 'Delivered';

  Color get _statusBgColor => isDelivered ? Colors.green.shade50 : Colors.red.shade50;
  Color get _statusTextColor => isDelivered ? Colors.green.shade700 : Colors.red.shade700;
  Color get _statusBorderColor => isDelivered ? Colors.green.shade200 : Colors.red.shade200;
  Color get _statusDotColor => isDelivered ? Colors.green.shade500 : Colors.red.shade500;

  Future<void> _makePhoneCall() async {
    final Uri launchUri = Uri(scheme: 'tel', path: buyerPhone);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade900, width: 2), // border-neutral-900 equivalent
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Container(
            padding: const EdgeInsets.only(bottom: 12),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade100))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5EBE0),
                        border: Border.all(color: const Color(0xFFE6CCB2)),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'ORDER $orderId',
                        style: GoogleFonts.plusJakartaSans(color: const Color(0xFF78350F), fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      time,
                      style: GoogleFonts.plusJakartaSans(color: Colors.grey.shade500, fontSize: 11, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                  decoration: BoxDecoration(
                    color: _statusBgColor,
                    border: Border.all(color: _statusBorderColor),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Container(width: 6, height: 6, decoration: BoxDecoration(color: _statusDotColor, shape: BoxShape.circle)),
                      const SizedBox(width: 6),
                      Text(
                        status,
                        style: GoogleFonts.plusJakartaSans(color: _statusTextColor, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Details List
          _buildDetailRow('Customer:', buyerName, isBold: true),
          const SizedBox(height: 8),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Contact:', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
              InkWell(
                onTap: _makePhoneCall,
                child: Row(
                  children: [
                    Icon(Icons.phone, size: 14, color: Colors.grey.shade400),
                    const SizedBox(width: 4),
                    Text(buyerPhone, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade800)),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Amount:', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
              Text('₹ $amount', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w900, color: isDelivered ? AppColors.seller600 : Colors.grey.shade700)),
            ],
          ),
          
          // Address Section
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.grey.shade200, style: BorderStyle.solid))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Address:', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
                Expanded(
                  child: Text(
                    address,
                    textAlign: TextAlign.right,
                    style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey.shade700, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          
          // Status Summary Section
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Status:', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
                Text(status, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: _statusTextColor)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
        Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: isBold ? FontWeight.bold : FontWeight.w600, color: Colors.grey.shade900)),
      ],
    );
  }
}
