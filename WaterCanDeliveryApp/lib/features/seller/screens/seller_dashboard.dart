import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../auth/screens/login_screen.dart';
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

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  // Mock Data from HTML
  final List<Map<String, dynamic>> _mockOrders = [
    {
      'orderId': '#1024',
      'time': '10:30 AM',
      'status': 'Accepted',
      'buyerName': 'Rajesh Kumar',
      'buyerPhone': '+91 98451 23091',
      'quantity': 3,
      'pricePerCan': 80,
    },
    {
      'orderId': '#1025',
      'time': '09:15 AM',
      'status': 'Preparing',
      'buyerName': 'Priya Sharma',
      'buyerPhone': '+91 97123 45678',
      'quantity': 2,
      'pricePerCan': 80,
    },
    {
      'orderId': '#1026',
      'time': '08:45 AM',
      'status': 'Preparing',
      'buyerName': 'Amit Patel',
      'buyerPhone': '+91 99201 88412',
      'quantity': 5,
      'pricePerCan': 80,
    },
    {
      'orderId': '#1027',
      'time': '08:10 AM',
      'status': 'Accepted',
      'buyerName': 'Sneha Reddy',
      'buyerPhone': '+91 98840 51923',
      'quantity': 1,
      'pricePerCan': 80,
    },
    {
      'orderId': '#1028',
      'time': '07:30 AM',
      'status': 'Delivered',
      'buyerName': 'Vikram Singh',
      'buyerPhone': '+91 98112 34901',
      'quantity': 4,
      'pricePerCan': 80,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.seller50,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopNav(),
            _buildHeader(),
            _buildFilterRow(),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: _mockOrders.length,
                itemBuilder: (context, index) {
                  final order = _mockOrders[index];
                  return SellerOrderCard(
                    orderId: order['orderId'],
                    time: order['time'],
                    status: order['status'],
                    buyerName: order['buyerName'],
                    buyerPhone: order['buyerPhone'],
                    quantity: order['quantity'],
                    pricePerCan: order['pricePerCan'],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SellerOrderStatusScreen(
                            order: order,
                            onStatusUpdate: (newStatus) {
                              setState(() {
                                _mockOrders[index]['status'] = newStatus;
                              });
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

  Widget _buildFilterRow() {
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
                  child: Text('5', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
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
