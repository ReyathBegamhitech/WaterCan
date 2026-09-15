import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../customer/controllers/order_controller.dart';
import '../widgets/seller_history_order_card.dart';

class SellerOrderHistoryScreen extends StatefulWidget {
  const SellerOrderHistoryScreen({super.key});

  @override
  State<SellerOrderHistoryScreen> createState() => _SellerOrderHistoryScreenState();
}

class _SellerOrderHistoryScreenState extends State<SellerOrderHistoryScreen> {
  // 'completed' or 'cancelled'
  String _activeTab = 'completed';

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderController>(
      builder: (context, orderCtrl, _) {
        final completedOrders = orderCtrl.completedOrders.map((o) => o.toSellerHistoryMap()).toList();
        final cancelledOrders = orderCtrl.cancelledOrders.map((o) => o.toSellerHistoryMap()).toList();
        final currentList = _activeTab == 'completed' ? completedOrders : cancelledOrders;

        return Scaffold(
          backgroundColor: const Color(0xFFFAF5F0),
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(completedOrders.length, cancelledOrders.length),
                Expanded(
                  child: currentList.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 72,
                                  height: 72,
                                  decoration: BoxDecoration(
                                    color: AppColors.seller100,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.history, size: 36, color: AppColors.seller600),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _activeTab == 'completed' ? 'No Delivered Orders' : 'No Cancelled Orders',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.seller800,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _activeTab == 'completed'
                                      ? 'Orders delivered to customers will show here.'
                                      : 'Terminated or cancelled orders will show here.',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          itemCount: currentList.length,
                          itemBuilder: (context, index) {
                            final order = currentList[index];
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
      },
    );
  }

  Widget _buildHeader(int completedCount, int cancelledCount) {
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
                  badgeCount: completedCount,
                  isActive: _activeTab == 'completed',
                  onTap: () => setState(() => _activeTab = 'completed'),
                ),
                const SizedBox(width: 4),
                _buildTabButton(
                  title: 'CANCELLED ORDERS',
                  badgeCount: cancelledCount,
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
