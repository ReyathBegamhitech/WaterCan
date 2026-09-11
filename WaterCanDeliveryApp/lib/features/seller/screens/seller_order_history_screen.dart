import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../widgets/seller_history_order_card.dart';

class SellerOrderHistoryScreen extends StatefulWidget {
  const SellerOrderHistoryScreen({super.key});

  @override
  State<SellerOrderHistoryScreen> createState() => _SellerOrderHistoryScreenState();
}

class _SellerOrderHistoryScreenState extends State<SellerOrderHistoryScreen> {
  // 'completed' or 'cancelled'
  String _activeTab = 'completed';

  final List<Map<String, dynamic>> _completedOrders = [
    {
      'orderId': '#1021',
      'time': 'Yesterday, 04:30 PM',
      'status': 'Delivered',
      'buyerName': 'Rajesh Kumar',
      'buyerPhone': '+91 98451 23091',
      'amount': 120,
      'address': 'Flat 402, Green Glen Heights, Bellandur, Bangalore',
    },
    {
      'orderId': '#1019',
      'time': 'Yesterday, 01:15 PM',
      'status': 'Delivered',
      'buyerName': 'Sneha Reddy',
      'buyerPhone': '+91 98840 51923',
      'amount': 160,
      'address': '#12, 4th Cross, Indiranagar, Bangalore',
    },
    {
      'orderId': '#1015',
      'time': '24 Oct, 11:20 AM',
      'status': 'Delivered',
      'buyerName': 'Priya Sharma',
      'buyerPhone': '+91 97123 45678',
      'amount': 80,
      'address': 'Villa 203, Palm Meadows, Whitefield',
    },
  ];

  final List<Map<String, dynamic>> _cancelledOrders = [
    {
      'orderId': '#1017',
      'time': '23 Oct, 03:40 PM',
      'status': 'Cancelled',
      'buyerName': 'Amit Patel',
      'buyerPhone': '+91 99201 88412',
      'amount': 80,
      'address': 'Flat 102, Shanti Nilayam, Koramangala 4th Block',
    },
    {
      'orderId': '#1008',
      'time': '21 Oct, 10:10 AM',
      'status': 'Cancelled',
      'buyerName': 'Vikram Singh',
      'buyerPhone': '+91 98112 34901',
      'amount': 240,
      'address': 'Tower B, Flat 804, Brigade Metropolis, Mahadevapura',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF5F0),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                itemCount: _activeTab == 'completed' ? _completedOrders.length : _cancelledOrders.length,
                itemBuilder: (context, index) {
                  final order = _activeTab == 'completed' ? _completedOrders[index] : _cancelledOrders[index];
                  return SellerHistoryOrderCard(
                    orderId: order['orderId'],
                    time: order['time'],
                    status: order['status'],
                    buyerName: order['buyerName'],
                    buyerPhone: order['buyerPhone'],
                    amount: order['amount'],
                    address: order['address'],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF5F0).withOpacity(0.95),
        border: Border(bottom: BorderSide(color: AppColors.seller200.withOpacity(0.5))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                      ),
                      child: const Icon(Icons.arrow_back, size: 20, color: Colors.black87),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('SELLER MODULE', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.seller600, letterSpacing: 1.0)),
                      Text('ORDER HISTORY', style: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.black87, letterSpacing: -0.5)),
                    ],
                  ),
                ],
              ),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.seller100,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.seller200),
                ),
                child: const Icon(Icons.history, size: 16, color: AppColors.seller600),
              )
            ],
          ),
          const SizedBox(height: 16),
          
          // Custom Tab Bar
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.grey.shade200.withOpacity(0.6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300.withOpacity(0.7)),
            ),
            child: Row(
              children: [
                _buildTabButton(
                  title: 'COMPLETED ORDERS',
                  badgeCount: 3,
                  isActive: _activeTab == 'completed',
                  onTap: () => setState(() => _activeTab = 'completed'),
                ),
                const SizedBox(width: 4),
                _buildTabButton(
                  title: 'CANCELLED ORDERS',
                  badgeCount: 2,
                  isActive: _activeTab == 'cancelled',
                  onTap: () => setState(() => _activeTab = 'cancelled'),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required String title,
    required int badgeCount,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? AppColors.seller600 : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isActive ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 2, offset: const Offset(0, 1))] : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: isActive ? Colors.white : Colors.grey.shade600,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isActive ? Colors.white.withOpacity(0.2) : Colors.grey.shade300.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badgeCount.toString(),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: isActive ? Colors.white : Colors.grey.shade700,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
