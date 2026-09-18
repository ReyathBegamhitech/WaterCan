import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../models/order_model.dart';
import '../controllers/order_controller.dart';
import '../controllers/user_controller.dart';
import 'track_delivery_screen.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> with TickerProviderStateMixin {
  String _selectedTab = 'active';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userCtrl = Provider.of<UserController>(context, listen: false);
      final phone = userCtrl.phone;
      if (phone.isNotEmpty) {
        Provider.of<OrderController>(context, listen: false).startPollingUserOrders(phone);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface.withOpacity(0.85),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'My Orders',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryContainer.withOpacity(0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.water_drop, color: AppColors.onPrimary, size: 22),
          ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top Segmented Filter Tabs
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: AppColors.surface.withOpacity(0.95),
              child: Consumer<OrderController>(
                builder: (context, controller, _) {
                  return Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        _buildTab('active', 'Active', controller.activeOrders.length.toString()),
                        _buildTab('completed', 'Delivered', controller.completedOrders.length.toString()),
                        _buildTab('cancelled', 'Cancelled', controller.cancelledOrders.length.toString()),
                      ],
                    ),
                  );
                },
              ),
            ),

            Expanded(
              child: Consumer<OrderController>(
                builder: (context, controller, child) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                    child: Column(
                      children: [
                        // Dynamic Status Alert (Only show on Active tab)
                        if (_selectedTab == 'active' && controller.activeOrders.isNotEmpty)
                          Container(
                            margin: const EdgeInsets.only(bottom: 24),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.secondaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.info, color: AppColors.onSecondaryContainer, size: 20),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    '${controller.activeOrders.length} orders are currently in progress',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.onSecondaryContainer,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        
                        // Show respective tab contents
                        if (_selectedTab == 'active')
                          _buildOrdersList(controller.activeOrders, true),
                        if (_selectedTab == 'completed')
                          _buildOrdersList(controller.completedOrders, false),
                        if (_selectedTab == 'cancelled')
                          _buildOrdersList(controller.cancelledOrders, false),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String key, String label, String count) {
    final bool isActive = _selectedTab == key;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = key),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primaryContainer : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isActive ? AppColors.onPrimary : AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.onPrimary.withOpacity(0.2) : AppColors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  count,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: isActive ? AppColors.onPrimary : AppColors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrdersList(List<OrderModel> orders, bool isActiveList) {
    if (orders.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primaryContainer.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.receipt_long_outlined,
                size: 40,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No Orders Yet',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'When you place an order, it will show up here so you can track its delivery.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: AppColors.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.shopping_bag_outlined, size: 18),
              label: Text(
                'Explore Water Cans',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      );
    }
    return Column(
      children: orders.map((order) {
        final isCancelled = order.status == OrderStatus.cancelled;
        
        Color statusColor;
        Color statusTextColor;
        Widget statusIcon;
        
        if (isCancelled) {
          statusColor = const Color(0xFFFFDAD6);
          statusTextColor = const Color(0xFF93000A);
          statusIcon = const Icon(Icons.block, size: 15, color: Color(0xFF93000A));
        } else if (order.status == OrderStatus.delivered) {
          statusColor = AppColors.secondaryContainer;
          statusTextColor = AppColors.onSecondaryContainer;
          statusIcon = const Icon(Icons.check_circle, size: 16, color: AppColors.onSecondaryContainer);

        } else {
          statusColor = AppColors.secondaryContainer;
          statusTextColor = AppColors.onSecondaryContainer;
          statusIcon = const _PulsingDot();
        }

        final actions = <Widget>[];
        if (isCancelled) {
          // no actions
        } else if (order.status == OrderStatus.delivered) {
          actions.add(_buildActionButton('View Receipt', Icons.receipt_long, AppColors.surfaceContainer, AppColors.onSurface, false));
          actions.add(_buildActionButton('Reorder', Icons.replay, AppColors.primaryContainer, AppColors.onPrimary, false));
        } else {
          if (order.status == OrderStatus.placed || order.status == OrderStatus.accepted) {
             actions.add(_buildActionButton(
               'Cancel Order', 
               Icons.cancel, 
               const Color(0xFFFFDAD6), 
               const Color(0xFF93000A), 
               false,
               onPressed: () => Provider.of<OrderController>(context, listen: false).cancelOrder(order.id)
             ));
          }
          actions.add(_buildActionButton(
            'Track Order',
            Icons.near_me,
            AppColors.primaryContainer,
            AppColors.onPrimary,
            actions.isEmpty, // if only one button, make full width (handled in custom builder)
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TrackDeliveryScreen(orderId: order.id))),
          ));
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: _buildOrderCard(
            orderId: order.id,
            date: order.formattedDate,
            statusLabel: order.statusText,
            statusColor: statusColor,
            statusTextColor: statusTextColor,
            statusIcon: statusIcon,
            imageUrl: order.items.isNotEmpty ? order.items.first.product.imageUrl : '',
            shopName: order.shopName,
            productName: order.summaryText,
            qtyDetails: order.items.isNotEmpty ? '${order.items.first.quantity} Cans' : '',
            price: '₹${order.totalAmount.toInt()}',
            isCancelled: isCancelled,
            isFastDelivery: order.isFastDelivery,
            actions: actions,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildOrderCard({
    required String orderId,
    required String date,
    required String statusLabel,
    required Color statusColor,
    required Color statusTextColor,
    required Widget statusIcon,
    required String imageUrl,
    required String? shopName,
    required String productName,
    required String qtyDetails,
    required String price,
    bool isCancelled = false,
    bool isFastDelivery = false,
    required List<Widget> actions,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20), // card-padding-mobile equivalent roughly
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    orderId,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.outlineVariant,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    date,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  if (isFastDelivery) ...[
                    const SizedBox(width: 8),
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
                  ],
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    statusIcon,
                    const SizedBox(width: 4),
                    Text(
                      statusLabel,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: statusTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Product Row
          Opacity(
            opacity: isCancelled ? 0.8 : 1.0,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  ColorFiltered(
                    colorFilter: isCancelled
                        ? const ColorFilter.matrix([
                            0.2126, 0.7152, 0.0722, 0, 0,
                            0.2126, 0.7152, 0.0722, 0, 0,
                            0.2126, 0.7152, 0.0722, 0, 0,
                            0, 0, 0, 1, 0,
                          ])
                        : const ColorFilter.mode(Colors.transparent, BlendMode.multiply),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        imageUrl,
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (shopName != null) ...[
                          Row(
                            children: [
                              const Icon(Icons.storefront, size: 15, color: AppColors.secondary),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  shopName,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                        ],
                        Text(
                          productName,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16, // headline-sm
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainer,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                qtyDetails,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                            ),
                            Text(
                              price,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isCancelled ? AppColors.onSurfaceVariant : AppColors.primary,
                                decoration: isCancelled ? TextDecoration.lineThrough : null,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (isCancelled) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh.withOpacity(0.6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info, size: 18, color: Color(0xFFBA1A1A)), // error color
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Cancelled by buyer • Full refund of $price processed to original payment mode',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          if (actions.isNotEmpty) ...[
            const SizedBox(height: 12),
            if (actions.length == 1)
              actions.first
            else
              Row(
                children: [
                  Expanded(child: actions[0]),
                  const SizedBox(width: 8),
                  Expanded(child: actions[1]),
                ],
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color bg, Color fg, bool isFullWidth, {VoidCallback? onPressed}) {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed ?? () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  const _PulsingDot();

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))..repeat(reverse: true);
    _opacity = Tween<double>(begin: 0.3, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: AppColors.secondary,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class _SpinningIcon extends StatefulWidget {
  final IconData icon;
  const _SpinningIcon({required this.icon});

  @override
  State<_SpinningIcon> createState() => _SpinningIconState();
}

class _SpinningIconState extends State<_SpinningIcon> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: Icon(widget.icon, size: 15, color: AppColors.primary),
    );
  }
}
