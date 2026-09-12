import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';

class UpiAppInfo {
  final String id;
  final String name;
  final String subtitle;
  final String? badge;
  final Color brandColor;
  final Widget iconWidget;
  final String deepLinkScheme;

  const UpiAppInfo({
    required this.id,
    required this.name,
    required this.subtitle,
    this.badge,
    required this.brandColor,
    required this.iconWidget,
    required this.deepLinkScheme,
  });
}

class UpiPaymentSheet extends StatefulWidget {
  final double totalAmount;
  final String orderId;
  final String shopName;

  const UpiPaymentSheet({
    super.key,
    required this.totalAmount,
    required this.orderId,
    this.shopName = 'Blue Drop Water Co.',
  });

  static Future<String?> show({
    required BuildContext context,
    required double totalAmount,
    required String orderId,
    String shopName = 'Blue Drop Water Co.',
  }) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => UpiPaymentSheet(
        totalAmount: totalAmount,
        orderId: orderId,
        shopName: shopName,
      ),
    );
  }

  @override
  State<UpiPaymentSheet> createState() => _UpiPaymentSheetState();
}

class _UpiPaymentSheetState extends State<UpiPaymentSheet> {
  bool _showQrCode = false;
  bool _isProcessing = false;
  String? _processingApp;

  final String _upiVpa = 'bluedropwater@okhdfcbank';

  List<UpiAppInfo> get _upiApps => [
        UpiAppInfo(
          id: 'gpay',
          name: 'Google Pay',
          subtitle: 'Instant transfer via GPay',
          badge: 'POPULAR',
          brandColor: const Color(0xFF4285F4),
          deepLinkScheme: 'tez://upi/pay',
          iconWidget: _buildGPayIcon(),
        ),
        UpiAppInfo(
          id: 'phonepe',
          name: 'PhonePe',
          subtitle: 'UPI, Wallet & Cards',
          badge: 'FASTEST',
          brandColor: const Color(0xFF5F259F),
          deepLinkScheme: 'phonepe://pay',
          iconWidget: _buildPhonePeIcon(),
        ),
        UpiAppInfo(
          id: 'paytm',
          name: 'Paytm UPI',
          subtitle: 'Paytm Payments Bank & UPI',
          badge: null,
          brandColor: const Color(0xFF002E6E),
          deepLinkScheme: 'paytmmp://pay',
          iconWidget: _buildPaytmIcon(),
        ),
        UpiAppInfo(
          id: 'bhim',
          name: 'BHIM UPI',
          subtitle: 'NPCI Official App',
          badge: null,
          brandColor: const Color(0xFF007A78),
          deepLinkScheme: 'upi://pay',
          iconWidget: _buildBhimIcon(),
        ),
        UpiAppInfo(
          id: 'other',
          name: 'All Installed UPI Apps',
          subtitle: 'CRED, WhatsApp, Amazon Pay & more',
          badge: 'CHOOSER',
          brandColor: const Color(0xFF0D9488),
          deepLinkScheme: 'upi://pay',
          iconWidget: _buildAllAppsIcon(),
        ),
      ];

  static Widget _buildGPayIcon() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'G',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w900,
                fontSize: 18,
                color: const Color(0xFF4285F4),
              ),
            ),
            Text(
              'Pay',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w800,
                fontSize: 13,
                color: const Color(0xFF5F6368),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildPhonePeIcon() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFF5F259F),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5F259F).withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          'पे',
          style: GoogleFonts.notoSansDevanagari(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 22,
          ),
        ),
      ),
    );
  }

  static Widget _buildPaytmIcon() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Pay',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                  color: const Color(0xFF002E6E),
                ),
              ),
              TextSpan(
                text: 'tm',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                  color: const Color(0xFF00BAF2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildBhimIcon() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFF007A78),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF007A78).withOpacity(0.25),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          'BHIM',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w900,
            fontSize: 12,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  static Widget _buildAllAppsIcon() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D9488), Color(0xFF0284C7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Icon(
          Icons.dashboard_customize_rounded,
          color: Colors.white,
          size: 22,
        ),
      ),
    );
  }

  String _buildUpiUrl({String scheme = 'upi://pay'}) {
    final queryParams = {
      'pa': _upiVpa,
      'pn': widget.shopName,
      'mc': '5411',
      'tr': widget.orderId,
      'tn': 'Order ${widget.orderId}',
      'am': widget.totalAmount.toStringAsFixed(2),
      'cu': 'INR',
    };

    final queryString = queryParams.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');

    return '$scheme?$queryString';
  }

  Future<void> _handleAppSelected(UpiAppInfo app) async {
    setState(() {
      _isProcessing = true;
      _processingApp = app.name;
    });

    final upiUrlString = _buildUpiUrl(scheme: app.deepLinkScheme);
    final fallbackUrlString = _buildUpiUrl(scheme: 'upi://pay');
    final uri = Uri.parse(upiUrlString);

    if (!kIsWeb) {
      // Mobile native app intent attempt
      bool launched = false;
      try {
        if (await canLaunchUrl(uri)) {
          launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          final fallbackUri = Uri.parse(fallbackUrlString);
          if (await canLaunchUrl(fallbackUri)) {
            launched = await launchUrl(fallbackUri, mode: LaunchMode.externalApplication);
          }
        }
      } catch (e) {
        debugPrint('UPI launch failed: $e');
      }

      if (launched) {
        if (mounted) {
          // Allow returning user to confirm
          Navigator.of(context).pop(app.name);
        }
        return;
      }
    }

    // Web / Emulator / Fallback simulation flow
    await _simulateUpiPayment(app.name);
  }

  Future<void> _simulateUpiPayment(String appName) async {
    if (!mounted) return;

    // Show simulated authorization bottom dialog
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return _SimulatedPaymentDialog(
          appName: appName,
          amount: widget.totalAmount,
          orderId: widget.orderId,
          vpa: _upiVpa,
        );
      },
    );

    if (mounted) {
      Navigator.of(context).pop(appName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 12,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.outlineVariant.withOpacity(0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pay using UPI',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.shield_outlined, size: 14, color: Color(0xFF16A34A)),
                      const SizedBox(width: 4),
                      Text(
                        '100% Safe • NPCI Approved',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF16A34A),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                ),
                child: Text(
                  '₹${widget.totalAmount.toStringAsFixed(0)}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Subtitle
          Text(
            'SELECT PAYMENT APP ON YOUR PHONE',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: AppColors.outline,
            ),
          ),
          const SizedBox(height: 12),

          // Apps List
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _upiApps.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final app = _upiApps[index];
              return _buildAppTile(app);
            },
          ),
          const SizedBox(height: 14),

          // QR Code Toggle
          InkWell(
            onTap: () => setState(() => _showQrCode = !_showQrCode),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.outlineVariant.withOpacity(0.4)),
              ),
              child: Row(
                children: [
                  Icon(
                    _showQrCode ? Icons.qr_code_scanner : Icons.qr_code_2_rounded,
                    size: 20,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _showQrCode ? 'Hide QR Code' : 'Scan QR Code or pay via UPI ID',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ),
                  Icon(
                    _showQrCode ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: AppColors.outline,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),

          if (_showQrCode) ...[
            const SizedBox(height: 12),
            _buildQrSection(),
          ],

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildAppTile(UpiAppInfo app) {
    final isSelected = _isProcessing && _processingApp == app.name;

    return InkWell(
      onTap: _isProcessing ? null : () => _handleAppSelected(app),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? app.brandColor
                : AppColors.outlineVariant.withOpacity(0.4),
            width: isSelected ? 1.8 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            app.iconWidget,
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        app.name,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurface,
                        ),
                      ),
                      if (app.badge != null) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: app.brandColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            app.badge!,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: app.brandColor,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    app.subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: app.brandColor,
                ),
              )
            else
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: AppColors.outline,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQrSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Text(
            'Scan using any UPI App',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          // Styled QR Container
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFCBD5E1)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(
                  Icons.qr_code_2_rounded,
                  size: 140,
                  color: AppColors.onSurface.withOpacity(0.85),
                ),
                Text(
                  '₹${widget.totalAmount.toStringAsFixed(0)}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Copy UPI ID row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'UPI ID: $_upiVpa',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: _upiVpa));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('UPI ID copied to clipboard!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(6),
                child: const Padding(
                  padding: EdgeInsets.all(4.0),
                  child: Icon(Icons.copy, size: 16, color: AppColors.primary),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SimulatedPaymentDialog extends StatefulWidget {
  final String appName;
  final double amount;
  final String orderId;
  final String vpa;

  const _SimulatedPaymentDialog({
    required this.appName,
    required this.amount,
    required this.orderId,
    required this.vpa,
  });

  @override
  State<_SimulatedPaymentDialog> createState() => _SimulatedPaymentDialogState();
}

class _SimulatedPaymentDialogState extends State<_SimulatedPaymentDialog> {
  int _step = 0; // 0: connecting, 1: pin entry/authorizing, 2: success

  @override
  void initState() {
    super.initState();
    _runSimulation();
  }

  Future<void> _runSimulation() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    if (mounted) setState(() => _step = 1);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) setState(() => _step = 2);
    await Future.delayed(const Duration(milliseconds: 900));
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_step < 2) ...[
              SizedBox(
                width: 60,
                height: 60,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _step == 0 ? const Color(0xFF4285F4) : const Color(0xFF16A34A),
                      ),
                    ),
                    const Icon(Icons.account_balance_wallet_rounded, size: 26, color: AppColors.primary),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                _step == 0 ? 'Connecting to ${widget.appName}...' : 'Authorizing Payment...',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Paying ₹${widget.amount.toStringAsFixed(0)} to ${widget.vpa}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: AppColors.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Ref: ${widget.orderId}',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 11,
                    color: const Color(0xFF475569),
                  ),
                ),
              ),
            ] else ...[
              Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  color: Color(0xFFDCFCE7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded, color: Color(0xFF16A34A), size: 36),
              ),
              const SizedBox(height: 18),
              Text(
                'Payment Successful!',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF16A34A),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '₹${widget.amount.toStringAsFixed(0)} paid via ${widget.appName}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
