import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../auth/screens/login_screen.dart';
import '../../customer/controllers/order_controller.dart';
import '../widgets/seller_order_card.dart';
import 'seller_analytics_screen.dart';
import 'seller_editor_screen.dart';
import 'seller_order_history_screen.dart';
import 'seller_order_status_screen.dart';

class SellerDashboardScreen extends StatefulWidget {
  const SellerDashboardScreen({super.key});

  @override
  State<SellerDashboardScreen> createState() => _SellerDashboardScreenState();
}

class _SellerDashboardScreenState extends State<SellerDashboardScreen> with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<OrderController>(context, listen: false).startPollingSellerOrders();
    });
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderController>(
      builder: (context, orderCtrl, _) {
        final activeOrders = orderCtrl.activeOrders.where((o) {
          if (_searchQuery.trim().isEmpty) return true;
          final q = _searchQuery.toLowerCase().trim();
          return (o.customerName?.toLowerCase().contains(q) ?? false) ||
                 o.id.toLowerCase().contains(q) ||
                 (o.customerPhone?.contains(q) ?? false) ||
                 o.sellerStatusString.toLowerCase().contains(q);
        }).toList();

        return Scaffold(
          backgroundColor: AppColors.seller50,
          body: SafeArea(
            child: Column(
              children: [
                _buildTopNav(),
                _buildHeader(),
                _buildFilterRow(activeOrders.length),
                Expanded(
                  child: activeOrders.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: AppColors.seller100,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: AppColors.seller300, width: 2),
                                  ),
                                  child: const Icon(Icons.inventory_2_outlined, size: 40, color: AppColors.seller600),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No Awaiting Orders',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.seller800,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Customer orders placed in the app will appear here in real time.',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    color: Colors.grey.shade600,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          itemCount: activeOrders.length,
                          itemBuilder: (context, index) {
                            final order = activeOrders[index];
                            final orderMap = order.toSellerOrderMap();
                            return SellerOrderCard(
                              orderId: orderMap['orderId'],
                              time: orderMap['time'],
                              status: orderMap['status'],
                              buyerName: orderMap['buyerName'],
                              buyerPhone: orderMap['buyerPhone'],
                              quantity: orderMap['quantity'],
                              pricePerCan: orderMap['pricePerCan'],
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SellerOrderStatusScreen(
                                      order: orderMap,
                                      onStatusUpdate: (newStatus) {
                                        orderCtrl.updateOrderStatusByString(order.id, newStatus);
                                      },
                                    ),
                                  ),
                                );
                              },
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

  Widget _buildTopNav() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.seller50,
        border: Border(bottom: BorderSide(color: AppColors.seller200.withOpacity(0.6))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                _navButton(Icons.bar_chart, 'Analytics', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SellerAnalyticsScreen()),
                  );
                }),
                const SizedBox(width: 6),
                _navButton(Icons.history, 'History', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SellerOrderHistoryScreen()),
                  );
                }),
                const SizedBox(width: 6),
                _navButton(Icons.inventory, 'Products', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SellerEditorScreen()),
                  );
                }),
              ],
            ),
          ),
          InkWell(
            onTap: () {
              // Logout logic for now
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.seller100,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.seller400, width: 2),
              ),
              child: const Icon(Icons.person, size: 18, color: AppColors.seller700),
            ),
          )
        ],
      ),
    );
  }

  Widget _navButton(IconData icon, String label, VoidCallback? onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.seller200),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 2, offset: const Offset(0, 1))
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: AppColors.seller600),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87),
              overflow: TextOverflow.ellipsis,
            )
          ],
        ),
      ),
    ));
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      width: double.infinity,
      color: AppColors.seller50,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedBuilder(
            animation: _shimmerController,
            builder: (context, child) {
              return ShaderMask(
                shaderCallback: (bounds) {
                  return LinearGradient(
                    colors: [
                      const Color(0xFF171717),
                      AppColors.seller600,
                      AppColors.seller500,
                      AppColors.seller600,
                      const Color(0xFF171717),
                    ],
                    stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
                    begin: Alignment(-2.0 + (_shimmerController.value * 4.0), 0.0),
                    end: Alignment(0.0 + (_shimmerController.value * 4.0), 0.0),
                  ).createShader(bounds);
                },
                child: child,
              );
            },
            child: Text(
              'SELLER DASHBOARD',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
                color: Colors.white, // Needs to be white for ShaderMask to work correctly
              ),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            height: 2,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              gradient: const LinearGradient(
                colors: [AppColors.seller500, Colors.amber, Colors.transparent],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildFilterRow(int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.seller100,
              border: Border.all(color: AppColors.seller200),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 2)],
            ),
            child: Row(
              children: [
                Text('CURRENT ORDERS', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.seller800)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: AppColors.seller500, borderRadius: BorderRadius.circular(12)),
                  child: Text('$count', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                )
              ],
            ),
          ),
          Container(
            width: 140,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppColors.seller200),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                const SizedBox(width: 8),
                Icon(Icons.search, size: 14, color: AppColors.seller600),
                const SizedBox(width: 4),
                Expanded(
                  child: TextField(
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Filter / Search...',
                      hintStyle: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.grey.shade400, fontWeight: FontWeight.w500),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: GoogleFonts.plusJakartaSans(fontSize: 12),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
