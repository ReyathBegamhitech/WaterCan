import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/api_constants.dart';
import '../../customer/controllers/user_controller.dart';
import '../../customer/screens/buyer_dashboard.dart';

class OtpScreen extends StatefulWidget {
  final String phoneNumber;
  final String? customerName;
  final String? address;

  const OtpScreen({
    super.key,
    required this.phoneNumber,
    this.customerName,
    this.address,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController _otp1Controller = TextEditingController();
  final TextEditingController _otp2Controller = TextEditingController();
  final TextEditingController _otp3Controller = TextEditingController();
  final TextEditingController _otp4Controller = TextEditingController();

  final FocusNode _focus1 = FocusNode();
  final FocusNode _focus2 = FocusNode();
  final FocusNode _focus3 = FocusNode();
  final FocusNode _focus4 = FocusNode();

  bool _isVerifying = false;
  bool _isResending = false;
  int _timerSeconds = 45;
  Timer? _timer;
  String? _lastOtp;

  @override
  void initState() {
    super.initState();
    _startTimer();
    _sendOtp();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otp1Controller.dispose();
    _otp2Controller.dispose();
    _otp3Controller.dispose();
    _otp4Controller.dispose();
    _focus1.dispose();
    _focus2.dispose();
    _focus3.dispose();
    _focus4.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _timerSeconds = 45);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerSeconds > 0) {
        setState(() => _timerSeconds--);
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _sendOtp() async {
    setState(() => _isResending = true);
    final phone = widget.phoneNumber.replaceAll(RegExp(r'\D'), '');

    try {
      final response = await http.post(
        Uri.parse(ApiConstants.sendOtp),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phone}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        final otp = data['otp']?.toString() ?? '';
        setState(() {
          _lastOtp = otp;
          _otp1Controller.clear();
          _otp2Controller.clear();
          _otp3Controller.clear();
          _otp4Controller.clear();
        });
        _startTimer();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('OTP sent to +91 $phone: $otp'),
              action: SnackBarAction(
                label: 'AUTO-FILL',
                textColor: Colors.amberAccent,
                onPressed: () {
                  if (otp.length == 4) {
                    _otp1Controller.text = otp[0];
                    _otp2Controller.text = otp[1];
                    _otp3Controller.text = otp[2];
                    _otp4Controller.text = otp[3];
                    _verifyOtp();
                  }
                },
              ),
              behavior: SnackBarBehavior.floating,
              backgroundColor: const Color(0xFF1E293B),
            ),
          );
          _focus1.requestFocus();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Connection error: $e'), behavior: SnackBarBehavior.floating),
        );
      }
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  Future<void> _verifyOtp() async {
    final code = '${_otp1Controller.text}${_otp2Controller.text}${_otp3Controller.text}${_otp4Controller.text}'.trim();
    if (code.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter 4-digit code'), behavior: SnackBarBehavior.floating),
      );
      return;
    }

    setState(() => _isVerifying = true);
    final phone = widget.phoneNumber.replaceAll(RegExp(r'\D'), '');

    try {
      final response = await http.post(
        Uri.parse(ApiConstants.verifyOtp),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phone, 'otp': code}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('OTP verified successfully!'),
              backgroundColor: Color(0xFF16A34A),
              behavior: SnackBarBehavior.floating,
            ),
          );

          final name = widget.customerName ?? 'User';
          final phoneNum = widget.phoneNumber;
          final addr = widget.address ?? '';

          await Provider.of<UserController>(context, listen: false).setUser(
            name: name,
            phone: phoneNum,
            address: addr,
          );

          if (!mounted) return;

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => BuyerDashboardScreen(
                customerName: name,
                phone: phoneNum,
                address: addr,
              ),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'] ?? 'Verification failed'), backgroundColor: Colors.redAccent, behavior: SnackBarBehavior.floating),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Connection error: $e'), behavior: SnackBarBehavior.floating),
        );
      }
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }

  Widget _buildCell({
    required TextEditingController controller,
    required FocusNode focusNode,
    FocusNode? nextFocus,
    FocusNode? prevFocus,
    bool isLast = false,
  }) {
    return Container(
      width: 54,
      height: 60,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: controller.text.isNotEmpty ? AppColors.primary : AppColors.outlineVariant.withOpacity(0.5),
          width: controller.text.isNotEmpty ? 1.8 : 1.0,
        ),
      ),
      alignment: Alignment.center,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
        onChanged: (val) {
          if (val.isNotEmpty) {
            if (nextFocus != null) {
              nextFocus.requestFocus();
            } else if (isLast) {
              focusNode.unfocus();
              _verifyOtp();
            }
          } else if (val.isEmpty && prevFocus != null) {
            prevFocus.requestFocus();
          }
          setState(() {});
        },
        decoration: const InputDecoration(border: InputBorder.none, counterText: ''),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              Container(
                width: 64,
                height: 64,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.mark_email_read_outlined, size: 32, color: AppColors.primary),
              ),
              const SizedBox(height: 24),
              Text(
                'Verification Code',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'We have sent the 4-digit verification code to\n+91 ${widget.phoneNumber}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: AppColors.onSurfaceVariant,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 36),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildCell(controller: _otp1Controller, focusNode: _focus1, nextFocus: _focus2),
                  _buildCell(controller: _otp2Controller, focusNode: _focus2, prevFocus: _focus1, nextFocus: _focus3),
                  _buildCell(controller: _otp3Controller, focusNode: _focus3, prevFocus: _focus2, nextFocus: _focus4),
                  _buildCell(controller: _otp4Controller, focusNode: _focus4, prevFocus: _focus3, isLast: true),
                ],
              ),
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.timer_outlined,
                    size: 16,
                    color: _timerSeconds > 0 ? const Color(0xFF16A34A) : AppColors.outline,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '00:${_timerSeconds.toString().padLeft(2, '0')}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _timerSeconds > 0 ? const Color(0xFF16A34A) : AppColors.outline,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('•', style: TextStyle(color: AppColors.outlineVariant)),
                  const SizedBox(width: 12),
                  InkWell(
                    onTap: (_timerSeconds == 0 && !_isResending) ? _sendOtp : null,
                    child: Text(
                      'Resend Code',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _timerSeconds == 0 ? AppColors.primary : AppColors.outline.withOpacity(0.5),
                      ),
                    ),
                  ),
                ],
              ),
              if (_lastOtp != null) ...[
                const SizedBox(height: 12),
                Center(
                  child: InkWell(
                    onTap: () {
                      if (_lastOtp!.length == 4) {
                        _otp1Controller.text = _lastOtp![0];
                        _otp2Controller.text = _lastOtp![1];
                        _otp3Controller.text = _lastOtp![2];
                        _otp4Controller.text = _lastOtp![3];
                        _verifyOtp();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Auto-fill code: $_lastOtp',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF16A34A),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
              const Spacer(),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _isVerifying ? null : _verifyOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isVerifying
                      ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                      : Text(
                          'VERIFY & CONTINUE',
                          style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                        ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
