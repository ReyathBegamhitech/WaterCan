import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../widgets/seller_order_card.dart';
import '../../customer/models/order_model.dart';

class SellerOrderStatusScreen extends StatefulWidget {
  final OrderModel order;
  final Function(String newStatus) onStatusUpdate;

  const SellerOrderStatusScreen({
    super.key,
    required this.order,
    required this.onStatusUpdate,
  });

  @override
  State<SellerOrderStatusScreen> createState() => _SellerOrderStatusScreenState();
}

class _SellerOrderStatusScreenState extends State<SellerOrderStatusScreen> {
  late String _selectedStatus;

  final List<Map<String, String>> _statusOptions = [
    {
      'title': 'Placed', // Mapped from 'Order Placed' to match SellerOrderCard
      'desc': 'Order received from buyer',
    },
    {
      'title': 'Accepted',
      'desc': 'Order accepted by seller',
    },
    {
      'title': 'Out for Delivery',
      'desc': 'Dispatched with delivery agent',
    },
    {
      'title': 'Delivered',
      'desc': 'Handed over to buyer',
    },
    {
      'title': 'Cancelled',
      'desc': 'Order terminated',
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.order.sellerStatusString;
  }

  void _handleUpdateStatus() {
    widget.onStatusUpdate(_selectedStatus);
    
    // Show toast
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text('Order ${widget.order.id} updated to $_selectedStatus', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
          ],
        ),
        backgroundColor: Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );

    // Go back to dashboard
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    // Create a temporary order to preview the new status
    final tempOrder = OrderModel(
      id: widget.order.id,
      items: widget.order.items,
      totalAmount: widget.order.totalAmount,
      timestamp: widget.order.timestamp,
      paymentMethod: widget.order.paymentMethod,
      customerName: widget.order.customerName,
      customerPhone: widget.order.customerPhone,
      deliveryAddress: widget.order.deliveryAddress,
      shopName: widget.order.shopName,
    );
    
    // Convert string back to enum for preview
    switch (_selectedStatus) {
      case 'Placed': tempOrder.status = OrderStatus.placed; break;
      case 'Accepted': tempOrder.status = OrderStatus.accepted; break;
      case 'Out for Delivery': tempOrder.status = OrderStatus.outForDelivery; break;
      case 'Delivered': tempOrder.status = OrderStatus.delivered; break;
      case 'Cancelled': tempOrder.status = OrderStatus.cancelled; break;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F2),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Order Summary Card
                    SellerOrderCard(
                      order: tempOrder, // Shows preview of new status!
                      onTap: null, // Disabled in this view
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Update Status Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('UPDATE ORDER STATUS', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.grey.shade700)),
                        Text('Select status', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.grey.shade500)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    // Radio List
                    ..._statusOptions.map((option) => _buildStatusOption(option)),
                  ],
                ),
              ),
            ),
            
            // Bottom Update Button
            Padding(
              padding: const EdgeInsets.all(20),
              child: InkWell(
                onTap: _handleUpdateStatus,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [AppColors.seller500, AppColors.seller600]),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: AppColors.seller500.withOpacity(0.25), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'UPDATE STATUS',
                      style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 1),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.seller200.withOpacity(0.5))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              InkWell(
                onTap: () => Navigator.pop(context),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 2)],
                  ),
                  child: const Icon(Icons.arrow_back, size: 20, color: Colors.black87),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('SELLER MODULE', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.seller600, letterSpacing: 0.5)),
                  Text('ORDER STATUS', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.black87, letterSpacing: -0.5)),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.seller100,
              border: Border.all(color: AppColors.seller200),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text('Live Sync', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.seller800)),
          )
        ],
      ),
    );
  }

  Widget _buildStatusOption(Map<String, String> option) {
    bool isSelected = _selectedStatus == option['title'];
    bool isCancelled = option['title'] == 'Cancelled';

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedStatus = option['title']!;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? (isCancelled ? Colors.red.shade50 : AppColors.seller50) : Colors.white,
          border: Border.all(
            color: isSelected 
              ? (isCancelled ? Colors.red.shade300 : AppColors.seller500) 
              : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4)],
        ),
        child: Row(
          children: [
            // Radio Circle
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isSelected 
                    ? (isCancelled ? Colors.red.shade600 : AppColors.seller600) 
                    : Colors.grey.shade300,
                  width: 2,
                ),
                color: isSelected ? (isCancelled ? Colors.red.shade600 : AppColors.seller600) : Colors.transparent,
              ),
              child: isSelected 
                ? const Icon(Icons.check, size: 14, color: Colors.white) 
                : null,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  option['title']!,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? (isCancelled ? Colors.red.shade900 : AppColors.seller900) : Colors.grey.shade800,
                  ),
                ),
                Text(
                  option['desc']!,
                  style: GoogleFonts.plusJakartaSans(fontSize: 11, color: Colors.grey.shade500),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
