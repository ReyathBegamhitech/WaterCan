import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import 'package:provider/provider.dart';
import '../../customer/controllers/order_controller.dart';
import '../../customer/models/order_model.dart';

class SellerAnalyticsScreen extends StatefulWidget {
  const SellerAnalyticsScreen({super.key});

  @override
  State<SellerAnalyticsScreen> createState() => _SellerAnalyticsScreenState();
}

class _SellerAnalyticsScreenState extends State<SellerAnalyticsScreen> {
  DateTime _selectedDate = DateTime.now();

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.seller600,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderCtrl = Provider.of<OrderController>(context);
    final now = DateTime.now();
    
    final todayOrders = orderCtrl.orders.where((o) => 
      o.timestamp.year == now.year && 
      o.timestamp.month == now.month && 
      o.timestamp.day == now.day
    ).toList();
    
    final todayTotal = todayOrders.length;
    final todayDelivered = todayOrders.where((o) => o.status == OrderStatus.delivered).length;
    final todayPending = todayOrders.where((o) => o.status != OrderStatus.delivered && o.status != OrderStatus.cancelled).length;
    
    final monthlyOrders = orderCtrl.orders.where((o) => 
      o.timestamp.year == now.year && 
      o.timestamp.month == now.month
    ).length;

    final selectedDateOrders = orderCtrl.orders.where((o) => 
      o.timestamp.year == _selectedDate.year && 
      o.timestamp.month == _selectedDate.month && 
      o.timestamp.day == _selectedDate.day
    ).toList();

    double codIncome = 0;
    double upiIncome = 0;
    for (var order in selectedDateOrders) {
      if (order.status != OrderStatus.cancelled) {
        final pm = order.paymentMethod.toLowerCase();
        if (pm.contains('cod') || pm.contains('cash')) codIncome += order.totalAmount;
        if (pm.contains('upi') || pm.contains('online')) upiIncome += order.totalAmount;
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFF7ED),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('Today\'s Orders', 'Live Count'),
                    const SizedBox(height: 12),
                    _buildTodayTotalCard(todayTotal),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _buildCompletedCard(todayDelivered)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildPendingCard(todayPending)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildSectionHeader('Monthly Orders', 'Current Month', badgeColor: AppColors.seller700, badgeBg: AppColors.seller100),
                    const SizedBox(height: 12),
                    _buildMonthlyOrdersCard(monthlyOrders),
                    const SizedBox(height: 24),
                    // Divider
                    Container(
                      height: 4,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.black87, Colors.black54],
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(2)),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildSectionHeader('Income by Date', 'Track Revenue', badgeColor: AppColors.seller700, badgeBg: AppColors.seller100),
                    const SizedBox(height: 12),
                    _buildDateSelector(),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _buildIncomeCard('COD', codIncome, AppColors.seller600, AppColors.seller100, Icons.money)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildIncomeCard('UPI', upiIncome, Colors.blue.shade700, Colors.blue.shade50, Icons.qr_code)),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED).withOpacity(0.95),
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
                  ),
                  child: const Icon(Icons.arrow_back, size: 20, color: Colors.black87),
                ),
              ),
              const SizedBox(width: 12),
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [AppColors.seller700, AppColors.seller400],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(bounds),
                child: Text(
                  'Analytics',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
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
            child: const Icon(Icons.bar_chart, size: 16, color: AppColors.seller600),
          )
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String badgeText, {Color? badgeColor, Color? badgeBg}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title.toUpperCase(),
          style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade600, letterSpacing: 0.5),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: badgeBg ?? Colors.grey.shade100,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            badgeText,
            style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: badgeColor ?? Colors.grey.shade500),
          ),
        ),
      ],
    );
  }

  Widget _buildTodayTotalCard(int total) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.seller400, width: 1.5),
        boxShadow: [BoxShadow(color: AppColors.seller500.withOpacity(0.3), blurRadius: 12, spreadRadius: 1)],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.seller100,
                      border: Border.all(color: AppColors.seller200),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.shopping_bag_outlined, size: 16, color: AppColors.seller600),
                  ),
                  const SizedBox(width: 8),
                  Text('TODAY\'S ORDERS', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade600, letterSpacing: 0.5)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  border: Border.all(color: Colors.green.shade200),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(width: 6, height: 6, decoration: BoxDecoration(color: Colors.green.shade500, shape: BoxShape.circle)),
                    const SizedBox(width: 4),
                    Text('Live', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.green.shade600)),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('$total', style: GoogleFonts.plusJakartaSans(fontSize: 36, fontWeight: FontWeight.w900, color: Colors.grey.shade900, letterSpacing: -1.0, height: 1.0)),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text('Total received today', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey.shade500)),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildCompletedCard(int count) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.green.shade50.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.shade400, width: 1.5),
        boxShadow: [BoxShadow(color: Colors.green.shade400.withOpacity(0.3), blurRadius: 12, spreadRadius: 1)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  border: Border.all(color: Colors.green.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.check, size: 16, color: Colors.green.shade700),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: Colors.green.shade100.withOpacity(0.8), borderRadius: BorderRadius.circular(4)),
                child: Text('DELIVERED', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.green.shade700, letterSpacing: 0.5)),
              )
            ],
          ),
          const SizedBox(height: 16),
          Text('$count', style: GoogleFonts.plusJakartaSans(fontSize: 30, fontWeight: FontWeight.w900, color: Colors.grey.shade900, letterSpacing: -1.0, height: 1.0)),
          const SizedBox(height: 4),
          Text('COMPLETED', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green.shade800, letterSpacing: 0.5)),
          const SizedBox(height: 2),
          Text('Delivered successfully', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.grey.shade500)),
        ],
      ),
    );
  }

  Widget _buildPendingCard(int count) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.amber.shade50.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.shade400, width: 1.5),
        boxShadow: [BoxShadow(color: Colors.amber.shade400.withOpacity(0.3), blurRadius: 12, spreadRadius: 1)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.amber.shade100,
                  border: Border.all(color: Colors.amber.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.access_time, size: 16, color: Colors.amber.shade700),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: Colors.amber.shade100.withOpacity(0.8), borderRadius: BorderRadius.circular(4)),
                child: Text('IN ACTION', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.amber.shade700, letterSpacing: 0.5)),
              )
            ],
          ),
          const SizedBox(height: 16),
          Text('$count', style: GoogleFonts.plusJakartaSans(fontSize: 30, fontWeight: FontWeight.w900, color: Colors.grey.shade900, letterSpacing: -1.0, height: 1.0)),
          const SizedBox(height: 4),
          Text('PENDING', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.amber.shade800, letterSpacing: 0.5)),
          const SizedBox(height: 2),
          Text('In progress & accepted', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.grey.shade500)),
        ],
      ),
    );
  }

  Widget _buildMonthlyOrdersCard(int count) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.seller400, width: 1.5),
        boxShadow: [BoxShadow(color: AppColors.seller500.withOpacity(0.3), blurRadius: 12, spreadRadius: 1)],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.seller600,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.calendar_month, size: 16, color: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('MONTHLY ORDERS', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade800, letterSpacing: 0.5)),
                      Text('Total accumulated orders', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.grey.shade500)),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  border: Border.all(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text('30 Days', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey.shade600)),
              )
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.grey.shade100))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text('$count', style: GoogleFonts.plusJakartaSans(fontSize: 36, fontWeight: FontWeight.w900, color: AppColors.seller600, letterSpacing: -1.0, height: 1.0)),
                    const SizedBox(width: 6),
                    Text('orders total', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade500)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    border: Border.all(color: Colors.green.shade200),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.trending_up, size: 14, color: Colors.green.shade600),
                      const SizedBox(width: 4),
                      Text('Growth', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green.shade600)),
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return InkWell(
      onTap: _pickDate,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.seller200),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_today, size: 18, color: AppColors.seller600),
                const SizedBox(width: 12),
                Text(
                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
            Icon(Icons.arrow_drop_down, color: Colors.grey.shade600),
          ],
        ),
      ),
    );
  }

  Widget _buildIncomeCard(String title, double amount, Color primaryColor, Color bgColor, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryColor.withOpacity(0.5), width: 1.5),
        boxShadow: [BoxShadow(color: primaryColor.withOpacity(0.15), blurRadius: 12, spreadRadius: 1)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.2),
                  border: Border.all(color: primaryColor.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: primaryColor),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: primaryColor.withOpacity(0.15), borderRadius: BorderRadius.circular(4)),
                child: Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: primaryColor, letterSpacing: 0.5)),
              )
            ],
          ),
          const SizedBox(height: 16),
          TweenAnimationBuilder<double>(
            key: ValueKey(amount),
            tween: Tween<double>(begin: 0, end: amount),
            duration: const Duration(milliseconds: 1500),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Text(
                '₹${value.toStringAsFixed(amount.truncateToDouble() == amount ? 0 : 2)}',
                style: GoogleFonts.plusJakartaSans(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.grey.shade900, letterSpacing: -0.5, height: 1.0),
              );
            },
          ),
        ],
      ),
    );
  }
}
