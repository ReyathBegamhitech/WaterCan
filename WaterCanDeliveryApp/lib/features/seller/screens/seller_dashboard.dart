import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../auth/screens/login_screen.dart';
import '../../customer/controllers/order_controller.dart';
import '../../customer/controllers/user_controller.dart';
import '../../customer/models/order_model.dart';
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
  String _selectedFilter = 'All';
  int _fastOrdersPage = 0;
  int _standardOrdersPage = 0;
  static const int _itemsPerPage = 4;
  int _previousOrderCount = -1;
  bool _showNewOrderBanner = false;
  OrderController? _orderCtrl;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _orderCtrl = Provider.of<OrderController>(context, listen: false);
      _previousOrderCount = _orderCtrl!.activeOrders.length;
      _orderCtrl!.addListener(_onOrderUpdate);
      final userCtrl = Provider.of<UserController>(context, listen: false);
      final sellerId = userCtrl.assignedSellerId.isNotEmpty ? userCtrl.assignedSellerId : 'S-1001';
      _orderCtrl!.startPollingSellerOrders(sellerId);
    });
  }

  void _onOrderUpdate() {
    if (!mounted) return;
    if (_orderCtrl != null) {
      if (_previousOrderCount != -1 && _orderCtrl!.activeOrders.length > _previousOrderCount) {
        setState(() {
          _showNewOrderBanner = true;
        });
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            setState(() {
              _showNewOrderBanner = false;
            });
          }
        });
      }
      _previousOrderCount = _orderCtrl!.activeOrders.length;
    }
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _orderCtrl?.removeListener(_onOrderUpdate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderController>(
      builder: (context, orderCtrl, _) {
        final activeOrders = orderCtrl.activeOrders.where((o) {
          if (_selectedFilter == 'All') return true;
          if (_selectedFilter == 'COD') return o.paymentMethod.toLowerCase() == 'cod' || o.paymentMethod.toLowerCase().contains('cash on delivery');
          if (_selectedFilter == 'UPI') return o.paymentMethod.toLowerCase().contains('upi');
          if (_selectedFilter == 'FAST DELIVERY') return o.isFastDelivery;
          return true;
        }).toList()..sort((a, b) {
          if (a.isFastDelivery && !b.isFastDelivery) return -1;
          if (!a.isFastDelivery && b.isFastDelivery) return 1;
          return b.timestamp.compareTo(a.timestamp); // Newest first
        });

        final fastOrders = activeOrders.where((o) => o.isFastDelivery).toList();
        final standardOrders = activeOrders.where((o) => !o.isFastDelivery).toList();

        final fastStartIndex = _fastOrdersPage * _itemsPerPage;
        final fastEndIndex = (fastStartIndex + _itemsPerPage > fastOrders.length) ? fastOrders.length : fastStartIndex + _itemsPerPage;
        final fastPageOrders = fastOrders.isNotEmpty ? fastOrders.sublist(fastStartIndex, fastEndIndex) : [];

        final standardStartIndex = _standardOrdersPage * _itemsPerPage;
        final standardEndIndex = (standardStartIndex + _itemsPerPage > standardOrders.length) ? standardOrders.length : standardStartIndex + _itemsPerPage;
        final standardPageOrders = standardOrders.isNotEmpty ? standardOrders.sublist(standardStartIndex, standardEndIndex) : [];

        return Scaffold(
          backgroundColor: AppColors.seller50,
          body: SafeArea(
            child: Column(
              children: [
                _buildTopNav(),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: _showNewOrderBanner ? 40 : 0,
                  width: double.infinity,
                  color: AppColors.primary,
                  alignment: Alignment.center,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: _showNewOrderBanner ? 1.0 : 0.0,
                    child: Text(
                      '🔔 New Order Received!', 
                      style: GoogleFonts.plusJakartaSans(color: AppColors.onPrimary, fontWeight: FontWeight.bold, fontSize: 14)
                    ),
                  ),
                ),
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
                      : SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (fastOrders.isNotEmpty) ...[
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
                                  child: Text('Fast Delivery Orders', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.seller800)),
                                ),
                                ...fastPageOrders.map((o) => _buildOrderCard(o, orderCtrl)),
                                _buildPaginationControls(
                                  currentPage: _fastOrdersPage,
                                  totalItems: fastOrders.length,
                                  onPageChanged: (newPage) => setState(() => _fastOrdersPage = newPage),
                                ),
                                const SizedBox(height: 16),
                              ],
                              if (standardOrders.isNotEmpty) ...[
                                if (fastOrders.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                                    child: Row(
                                      children: [
                                        Expanded(child: Divider(color: Colors.grey.shade400, thickness: 1.5)),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                          child: Text('Standard Orders', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade600)),
                                        ),
                                        Expanded(child: Divider(color: Colors.grey.shade400, thickness: 1.5)),
                                      ],
                                    ),
                                  )
                                else
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
                                    child: Text('Standard Orders', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.seller800)),
                                  ),
                                ...standardPageOrders.map((o) => _buildOrderCard(o, orderCtrl)),
                                _buildPaginationControls(
                                  currentPage: _standardOrdersPage,
                                  totalItems: standardOrders.length,
                                  onPageChanged: (newPage) => setState(() => _standardOrdersPage = newPage),
                                ),
                              ],
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showProfileSheet() {
    final userCtrl = Provider.of<UserController>(context, listen: false);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            left: 24,
            right: 24,
            top: 24,
          ),
          decoration: const BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(
                radius: 40,
                backgroundColor: AppColors.seller100,
                child: Icon(Icons.storefront, size: 40, color: AppColors.seller700),
              ),
              const SizedBox(height: 16),
              Text(
                userCtrl.customerName.isNotEmpty ? userCtrl.customerName : 'Water Can Seller',
                style: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.seller800),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              
              Row(
                children: [
                  const Icon(Icons.location_on, color: AppColors.seller500),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      userCtrl.doorNo.isNotEmpty ? userCtrl.doorNo : 'Address not provided',
                      style: GoogleFonts.plusJakartaSans(fontSize: 16, color: AppColors.onSurface),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  const Icon(Icons.phone, color: AppColors.seller500),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      userCtrl.phone,
                      style: GoogleFonts.plusJakartaSans(fontSize: 16, color: AppColors.onSurface),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.logout),
                  label: Text('Logout', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 16)),
                  onPressed: () {
                    // Close the bottom sheet first
                    Navigator.pop(context);
                    // Show confirmation dialog
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Logout'),
                        content: const Text('Are you sure you want to logout?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('No'),
                          ),
                          TextButton(
                            onPressed: () async {
                              await Provider.of<UserController>(context, listen: false).clear();
                              if (!context.mounted) return;
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(builder: (context) => const LoginScreen()),
                                (route) => false,
                              );
                            },
                            child: const Text('Yes', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
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
            onTap: _showProfileSheet,
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
            height: 32,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppColors.seller200),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                const Icon(Icons.filter_list, size: 14, color: AppColors.seller600),
                const SizedBox(width: 8),
                DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedFilter,
                    icon: const Icon(Icons.arrow_drop_down, size: 16, color: AppColors.seller600),
                    style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.seller800),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedFilter = newValue;
                          _fastOrdersPage = 0;
                          _standardOrdersPage = 0;
                        });
                      }
                    },
                    items: <String>['All', 'COD', 'UPI', 'FAST DELIVERY']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
  
  Widget _buildOrderCard(OrderModel order, OrderController orderCtrl) {
    return SellerOrderCard(
      order: order,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SellerOrderStatusScreen(
              order: order,
              onStatusUpdate: (newStatus) {
                orderCtrl.updateOrderStatusByString(order.id, newStatus);
              },
            ),
          ),
        );
      },
      onAccept: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Accept Order'),
            content: const Text('Are you sure you want to accept this COD order?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
              ),
              TextButton(
                onPressed: () {
                  orderCtrl.updateOrderStatusByString(order.id, 'Accepted');
                  Navigator.pop(context);
                },
                child: const Text('Accept', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      },
      onDecline: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Decline Order'),
            content: const Text('Are you sure you want to decline this order? This action cannot be undone.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
              ),
              TextButton(
                onPressed: () {
                  orderCtrl.updateOrderStatusByString(order.id, 'Cancelled');
                  Navigator.pop(context);
                },
                child: const Text('Decline', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPaginationControls({
    required int currentPage,
    required int totalItems,
    required ValueChanged<int> onPageChanged,
  }) {
    if (totalItems <= _itemsPerPage) return const SizedBox.shrink();
    int totalPages = (totalItems / _itemsPerPage).ceil();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: currentPage > 0 ? () => onPageChanged(currentPage - 1) : null,
          ),
          Text(
            'Page ${currentPage + 1} of $totalPages',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.seller800,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: currentPage < totalPages - 1 ? () => onPageChanged(currentPage + 1) : null,
          ),
        ],
      ),
    );
  }
}
