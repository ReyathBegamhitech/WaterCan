import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/api_constants.dart';
import '../widgets/primary_button.dart';
import '../widgets/custom_text_field.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../../customer/controllers/user_controller.dart';
import '../../customer/screens/buyer_dashboard.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _sameAsPhone = false;
  bool _isLoading = false;

  // Real-time OTP State
  bool _isPhoneVerified = false;
  bool _otpSent = false;
  bool _isSendingOtp = false;
  bool _isVerifyingOtp = false;
  int _timerSeconds = 45;
  Timer? _countdownTimer;
  String? _lastReceivedOtp;

  final TextEditingController _sellerIdController = TextEditingController();
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _doorNoController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController(text: '');
  final TextEditingController _whatsappController = TextEditingController(text: '');

  // 4-digit OTP Controllers & Focus Nodes
  final TextEditingController _otp1Controller = TextEditingController();
  final TextEditingController _otp2Controller = TextEditingController();
  final TextEditingController _otp3Controller = TextEditingController();
  final TextEditingController _otp4Controller = TextEditingController();

  final FocusNode _focus1 = FocusNode();
  final FocusNode _focus2 = FocusNode();
  final FocusNode _focus3 = FocusNode();
  final FocusNode _focus4 = FocusNode();

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(() {
      setState(() {});
    });

    _phoneController.addListener(() {
      // If phone number is modified after OTP was sent or verified, reset verification
      if (_isPhoneVerified || _otpSent) {
        setState(() {
          _isPhoneVerified = false;
          _otpSent = false;
          _timerSeconds = 45;
          _countdownTimer?.cancel();
          _otp1Controller.clear();
          _otp2Controller.clear();
          _otp3Controller.clear();
          _otp4Controller.clear();
          _lastReceivedOtp = null;
        });
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _sellerIdController.dispose();
    _customerNameController.dispose();
    _emailController.dispose();
    _doorNoController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _pincodeController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _whatsappController.dispose();
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

  void _startCountdown() {
    _countdownTimer?.cancel();
    setState(() {
      _timerSeconds = 45;
    });
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerSeconds > 0) {
        setState(() {
          _timerSeconds--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _sendOtp() async {
    final phone = _phoneController.text.trim().replaceAll(RegExp(r'\D'), '');
    if (phone.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid 10-digit phone number first.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isSendingOtp = true;
    });

    try {
      final response = await http.post(
        Uri.parse(ApiConstants.sendOtp),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone': phone,
          'isRegistering': true,
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        final otp = data['otp']?.toString() ?? '';
        setState(() {
          _otpSent = true;
          _lastReceivedOtp = otp;
          _otp1Controller.clear();
          _otp2Controller.clear();
          _otp3Controller.clear();
          _otp4Controller.clear();
        });
        _startCountdown();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.mark_email_read_outlined, color: Colors.greenAccent, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      data['message'] ?? 'SMS sent successfully!',
                      style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 5),
              backgroundColor: const Color(0xFF16A34A),
            ),
          );

          _focus1.requestFocus();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data['message'] ?? 'Failed to send OTP.'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error connecting to backend: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSendingOtp = false;
        });
      }
    }
  }

  void _autoFillOtp(String otp) {
    if (otp.length == 4) {
      _otp1Controller.text = otp[0];
      _otp2Controller.text = otp[1];
      _otp3Controller.text = otp[2];
      _otp4Controller.text = otp[3];
      _verifyOtp();
    }
  }

  Future<void> _verifyOtp() async {
    final enteredOtp = '${_otp1Controller.text}${_otp2Controller.text}${_otp3Controller.text}${_otp4Controller.text}'.trim();
    if (enteredOtp.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the 4-digit OTP code.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final phone = _phoneController.text.trim().replaceAll(RegExp(r'\D'), '');

    setState(() {
      _isVerifyingOtp = true;
    });

    try {
      final response = await http.post(
        Uri.parse(ApiConstants.verifyOtp),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone': phone,
          'otp': enteredOtp,
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        _countdownTimer?.cancel();
        setState(() {
          _isPhoneVerified = true;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.greenAccent, size: 20),
                  SizedBox(width: 8),
                  Text('Phone number verified successfully!'),
                ],
              ),
              backgroundColor: Color(0xFF16A34A),
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 3),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data['message'] ?? 'Invalid OTP code. Try again.'),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error connecting to backend: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isVerifyingOtp = false;
        });
      }
    }
  }

  Future<void> _register() async {
    if (_sellerIdController.text.isEmpty ||
        _customerNameController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _doorNoController.text.isEmpty ||
        _streetController.text.isEmpty ||
        _cityController.text.isEmpty ||
        _pincodeController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all required fields.')));
      return;
    }
    if (!_isPhoneVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please verify your phone number via OTP before registering.'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Passwords do not match.')));
      return;
    }

    final String password = _passwordController.text;
    final bool hasMinLength = password.length >= 8;
    final bool hasUppercase = password.contains(RegExp(r'[A-Z]'));
    final bool hasLowercase = password.contains(RegExp(r'[a-z]'));
    final bool hasNumber = password.contains(RegExp(r'[0-9]'));
    final bool hasSpecial = password.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'));
    
    if (!(hasMinLength && hasUppercase && hasLowercase && hasNumber && hasSpecial)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please meet all password criteria.')));
      return;
    }

    setState(() { _isLoading = true; });

    try {
      final response = await http.post(
        Uri.parse(ApiConstants.register),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'seller_id': _sellerIdController.text,
          'customerName': _customerNameController.text,
          'phone': _phoneController.text,
          'whatsapp': _whatsappController.text,
          'email': _emailController.text.isEmpty ? null : _emailController.text,
          'doorNo': _doorNoController.text,
          'street': _streetController.text,
          'city': _cityController.text,
          'pincode': _pincodeController.text,
          'password': _passwordController.text,
        }),
      );

      final data = jsonDecode(response.body);
      if (!mounted) return;

      if (response.statusCode == 201) {
        final name = _customerNameController.text.trim();
        final phone = _phoneController.text.trim();
        final doorNo = _doorNoController.text.trim();
        final street = _streetController.text.trim();
        final city = _cityController.text.trim();
        final pincode = _pincodeController.text.trim();
        final email = _emailController.text.trim();

        await Provider.of<UserController>(context, listen: false).setUser(
          name: name,
          phone: phone,
          doorNo: doorNo,
          street: street,
          city: city,
          pincode: pincode,
          email: email,
          assignedSellerId: data['assigned_seller_id'] ?? '',
          shopName: data['shop_name'] ?? '',
        );

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registration successful!')));
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => BuyerDashboardScreen(
          customerName: name,
          phone: phone,
        )));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['message'] ?? 'Registration failed.')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error connecting to server.')));
      }
    } finally {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }

  Widget _buildChecklistItem(String text, bool isMet) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(isMet ? Icons.check_circle : Icons.radio_button_unchecked, size: 15, color: isMet ? AppColors.secondary : Colors.grey.shade400),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12, // body-sm
              color: isMet ? AppColors.secondary : Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtpCell({
    required TextEditingController controller,
    required FocusNode focusNode,
    FocusNode? nextFocus,
    FocusNode? prevFocus,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Container(
      width: 48,
      height: 56,
      decoration: BoxDecoration(
        color: _isPhoneVerified
            ? const Color(0xFFF0FDF4)
            : AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _isPhoneVerified
              ? const Color(0xFF16A34A)
              : (controller.text.isNotEmpty ? AppColors.primary : AppColors.outlineVariant.withOpacity(0.4)),
          width: _isPhoneVerified || controller.text.isNotEmpty ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        enabled: !_isPhoneVerified,
        onChanged: (value) {
          if (value.isNotEmpty) {
            if (nextFocus != null) {
              nextFocus.requestFocus();
            } else if (isLast) {
              focusNode.unfocus();
              if (_otp1Controller.text.isNotEmpty &&
                  _otp2Controller.text.isNotEmpty &&
                  _otp3Controller.text.isNotEmpty &&
                  _otp4Controller.text.isNotEmpty) {
                _verifyOtp();
              }
            }
          } else if (value.isEmpty && prevFocus != null) {
            prevFocus.requestFocus();
          }
          setState(() {});
        },
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: _isPhoneVerified ? const Color(0xFF16A34A) : AppColors.primary,
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          counterText: '',
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }

  Widget _buildPhonePrefix() {
    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("🇮🇳", style: TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          Text(
            "+91",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 1,
            height: 24,
            color: AppColors.surfaceContainerHighest,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String password = _passwordController.text;
    final bool hasMinLength = password.length >= 8;
    final bool hasUppercase = password.contains(RegExp(r'[A-Z]'));
    final bool hasLowercase = password.contains(RegExp(r'[a-z]'));
    final bool hasNumber = password.contains(RegExp(r'[0-9]'));
    final bool hasSpecial = password.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'));
    
    int criteriaMetCount = 0;
    if (hasMinLength) criteriaMetCount++;
    if (hasUppercase) criteriaMetCount++;
    if (hasLowercase) criteriaMetCount++;
    if (hasNumber) criteriaMetCount++;
    if (hasSpecial) criteriaMetCount++;

    return Scaffold(
      backgroundColor: AppColors.surfaceContainerHigh,
      appBar: AppBar(
        backgroundColor: AppColors.surface.withOpacity(0.8),
        elevation: 0,
        scrolledUnderElevation: 4,
        centerTitle: true,
        title: Text(
          'Register',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
            letterSpacing: -0.5,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor: AppColors.primary,
              radius: 16,
              child: const Icon(Icons.person, size: 18, color: AppColors.onPrimary),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Seller ID (Mandatory)
              CustomTextField(
                label: 'Seller ID *',
                hintText: 'Enter Seller ID (e.g. S-1001)',
                controller: _sellerIdController,
              ),
              const SizedBox(height: 20),

              // 2. Customer Name
              CustomTextField(
                label: 'Customer Name *',
                hintText: 'Enter Customer Name',
                controller: _customerNameController,
              ),
              const SizedBox(height: 20),

              // 3. Phone Number
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextField(
                    label: 'Phone Number *',
                    hintText: 'Enter 10-digit number',
                    prefixWidget: _buildPhonePrefix(),
                    suffixWidget: _isPhoneVerified
                        ? const Padding(
                            padding: EdgeInsets.only(right: 12.0),
                            child: Icon(Icons.check_circle, color: Color(0xFF16A34A)),
                          )
                        : null,
                    controller: _phoneController,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const SizedBox(width: 4),
                      Icon(
                        _isPhoneVerified
                            ? Icons.check_circle_outline
                            : (_otpSent ? Icons.sms_outlined : Icons.phonelink_ring_outlined),
                        size: 14,
                        color: _isPhoneVerified
                            ? const Color(0xFF16A34A)
                            : (_otpSent ? AppColors.primary : AppColors.outline),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _isPhoneVerified
                            ? 'Phone number verified successfully.'
                            : (_otpSent
                                ? 'OTP sent to this number. Please enter code below.'
                                : 'Verification required via SMS OTP.'),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: _isPhoneVerified ? FontWeight.w600 : FontWeight.normal,
                          color: _isPhoneVerified
                              ? const Color(0xFF16A34A)
                              : (_otpSent ? AppColors.primary : AppColors.outline),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 4. OTP Verification Block
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _isPhoneVerified ? const Color(0xFFF0FDF4) : AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _isPhoneVerified ? const Color(0xFF16A34A).withOpacity(0.3) : Colors.transparent,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              'OTP Verification',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: _isPhoneVerified ? const Color(0xFF16A34A) : AppColors.onSurface,
                              ),
                            ),
                            if (_isPhoneVerified) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDCFCE7),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'VERIFIED',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF16A34A),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (!_isPhoneVerified)
                          Row(
                            children: [
                              Icon(
                                Icons.timer_outlined,
                                size: 16,
                                color: _otpSent && _timerSeconds > 0 ? const Color(0xFF16A34A) : AppColors.outline,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '00:${_timerSeconds.toString().padLeft(2, '0')}',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: _otpSent && _timerSeconds > 0 ? const Color(0xFF16A34A) : AppColors.outline,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildOtpCell(
                          controller: _otp1Controller,
                          focusNode: _focus1,
                          nextFocus: _focus2,
                          isFirst: true,
                        ),
                        _buildOtpCell(
                          controller: _otp2Controller,
                          focusNode: _focus2,
                          prevFocus: _focus1,
                          nextFocus: _focus3,
                        ),
                        _buildOtpCell(
                          controller: _otp3Controller,
                          focusNode: _focus3,
                          prevFocus: _focus2,
                          nextFocus: _focus4,
                        ),
                        _buildOtpCell(
                          controller: _otp4Controller,
                          focusNode: _focus4,
                          prevFocus: _focus3,
                          isLast: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 40,
                            child: ElevatedButton(
                              onPressed: _isPhoneVerified || _isSendingOtp ? null : _sendOtp,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _otpSent ? AppColors.surfaceContainerHighest : AppColors.primary,
                                foregroundColor: _otpSent ? AppColors.onSurface : AppColors.onPrimary,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: _isSendingOtp
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                    )
                                  : Text(
                                      _otpSent ? 'RESEND OTP' : 'SEND OTP',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: SizedBox(
                            height: 40,
                            child: ElevatedButton(
                              onPressed: _isPhoneVerified || _isVerifyingOtp || !_otpSent ? null : _verifyOtp,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _isPhoneVerified ? const Color(0xFF16A34A) : AppColors.primaryContainer,
                                foregroundColor: _isPhoneVerified ? Colors.white : AppColors.onPrimaryContainer,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: _isVerifyingOtp
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                                    )
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        if (_isPhoneVerified) ...[
                                          const Icon(Icons.check, size: 16, color: Colors.white),
                                          const SizedBox(width: 4),
                                        ],
                                        Text(
                                          _isPhoneVerified ? 'VERIFIED' : 'VERIFY',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (!_isPhoneVerified) ...[
                          InkWell(
                            onTap: (_otpSent && _timerSeconds == 0 && !_isSendingOtp)
                                ? _sendOtp
                                : null,
                            child: Text(
                              'Resend OTP',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: (_otpSent && _timerSeconds == 0)
                                    ? AppColors.primary
                                    : AppColors.outline.withOpacity(0.5),
                              ),
                            ),
                          ),
                          if (_lastReceivedOtp != null)
                            InkWell(
                              onTap: () => _autoFillOtp(_lastReceivedOtp!),
                              child: Text(
                                'Auto-fill: $_lastReceivedOtp',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF16A34A),
                                ),
                              ),
                            ),
                        ] else ...[
                          Row(
                            children: [
                              const Icon(Icons.verified, size: 16, color: Color(0xFF16A34A)),
                              const SizedBox(width: 4),
                              Text(
                                'OTP verified successfully.',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF16A34A),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 5. WhatsApp Number
              Row(
                children: [
                  Checkbox(
                    value: _sameAsPhone,
                    onChanged: (val) {
                      setState(() {
                        _sameAsPhone = val ?? false;
                        if (_sameAsPhone) {
                          _whatsappController.text = _phoneController.text;
                        } else {
                          _whatsappController.clear();
                        }
                      });
                    },
                    activeColor: AppColors.primary,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Same as Phone Number',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      color: AppColors.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: 'WhatsApp Number',
                hintText: 'Enter WhatsApp Number',
                prefixWidget: _buildPhonePrefix(),
                controller: _whatsappController,
              ),
              const SizedBox(height: 20),

              // 7. Email
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextField(
                    label: 'Email',
                    hintText: 'Enter Email Address (Optional)',
                    controller: _emailController,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 8. Delivery Address
              Text(
                'Delivery Address *',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: CustomTextField(
                      label: 'Door No *',
                      hintText: 'Flat / Door',
                      controller: _doorNoController,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: CustomTextField(
                      label: 'Street *',
                      hintText: 'Street Name',
                      controller: _streetController,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      label: 'City *',
                      hintText: 'City / Area',
                      controller: _cityController,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomTextField(
                      label: 'Pincode *',
                      hintText: '6 Digit PIN',
                      controller: _pincodeController,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 9. Password
              CustomTextField(
                label: 'Password *',
                hintText: 'Enter password',
                controller: _passwordController,
                obscureText: _obscurePassword,
                suffixIcon: _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                onSuffixIconTap: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              const SizedBox(height: 8),
              
              // Password Strength Indicator Pill Bar
              Row(
                children: [
                  Expanded(child: Container(height: 4, decoration: BoxDecoration(color: criteriaMetCount >= 1 ? (criteriaMetCount >= 5 ? AppColors.secondary : Colors.orange) : AppColors.surfaceContainerHighest, borderRadius: BorderRadius.circular(2)))),
                  const SizedBox(width: 6),
                  Expanded(child: Container(height: 4, decoration: BoxDecoration(color: criteriaMetCount >= 3 ? (criteriaMetCount >= 5 ? AppColors.secondary : Colors.orange) : AppColors.surfaceContainerHighest, borderRadius: BorderRadius.circular(2)))),
                  const SizedBox(width: 6),
                  Expanded(child: Container(height: 4, decoration: BoxDecoration(color: criteriaMetCount >= 5 ? AppColors.secondary : AppColors.surfaceContainerHighest, borderRadius: BorderRadius.circular(2)))),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Text('Weak', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: criteriaMetCount >= 1 ? Colors.orange : AppColors.outlineVariant)),
                  const SizedBox(width: 12),
                  Text('Medium', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: criteriaMetCount >= 3 ? Colors.orange : AppColors.outlineVariant)),
                  const SizedBox(width: 12),
                  Text('Strong ✓', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: criteriaMetCount >= 5 ? AppColors.secondary : AppColors.outlineVariant)),
                ],
              ),
              const SizedBox(height: 12),
              
              // Password Requirements Checklist
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _buildChecklistItem('Minimum 8 characters', hasMinLength),
                    _buildChecklistItem('Uppercase letter', hasUppercase),
                    _buildChecklistItem('Lowercase letter', hasLowercase),
                    _buildChecklistItem('Number', hasNumber),
                    _buildChecklistItem('Special character', hasSpecial),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 10. Confirm Password
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextField(
                    label: 'Confirm Password *',
                    hintText: 'Re-enter password',
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    suffixIcon: _obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    onSuffixIconTap: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.check_circle, size: 16, color: AppColors.secondary),
                      const SizedBox(width: 4),
                      Text(
                        'Passwords match successfully.',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // 11. CREATE ACCOUNT button
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : PrimaryButton(
                      text: 'CREATE ACCOUNT',
                      onPressed: _register,
                    ),
              const SizedBox(height: 16),

              // Centered Login Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an account? ",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14, // body-md
                      fontWeight: FontWeight.w400,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      "Login",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13, // label-md
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
