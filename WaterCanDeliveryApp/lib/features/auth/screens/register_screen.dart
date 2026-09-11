import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../widgets/primary_button.dart';
import '../widgets/custom_text_field.dart';
import 'package:flutter/gestures.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
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

  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController(text: '');
  final TextEditingController _whatsappController = TextEditingController(text: '');

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _whatsappController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_customerNameController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _addressController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all required fields.')));
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
        Uri.parse('http://10.203.29.64:3000/api/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'customerName': _customerNameController.text,
          'phone': _phoneController.text,
          'whatsapp': _whatsappController.text,
          'email': _emailController.text.isEmpty ? null : _emailController.text,
          'address': _addressController.text,
          'password': _passwordController.text,
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registration successful!')));
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => BuyerDashboardScreen(
          customerName: _customerNameController.text,
          phone: _phoneController.text,
          address: _addressController.text,
        )));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['message'] ?? 'Registration failed.')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error connecting to server.')));
    } finally {
      setState(() { _isLoading = false; });
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

  Widget _buildOtpCell(BuildContext context, {bool first = false, bool last = false}) {
    return Container(
      width: 48,
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: TextField(
        onChanged: (value) {
          if (value.isNotEmpty && !last) {
            FocusScope.of(context).nextFocus();
          } else if (value.isEmpty && !first) {
            FocusScope.of(context).previousFocus();
          }
        },
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
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
                    suffixIcon: Icons.check_circle,
                    controller: _phoneController,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const SizedBox(width: 4),
                      Text(
                        'Phone number verified successfully.',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: AppColors.secondary,
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
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'OTP Verification',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSurface,
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.timer_outlined, size: 16, color: AppColors.secondary),
                            const SizedBox(width: 4),
                            Text(
                              '00:45',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: AppColors.secondary,
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
                        _buildOtpCell(context, first: true),
                        _buildOtpCell(context),
                        _buildOtpCell(context),
                        _buildOtpCell(context, last: true),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 40,
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.surfaceContainerHighest,
                                foregroundColor: AppColors.onSurface,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                'SEND OTP',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
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
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryContainer,
                                foregroundColor: AppColors.onPrimaryContainer,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                'VERIFY',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
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
                        InkWell(
                          onTap: () {},
                          child: Text(
                            'Resend OTP',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.verified, size: 16, color: AppColors.secondary),
                            const SizedBox(width: 4),
                            Text(
                              'OTP verified successfully.',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: AppColors.secondary,
                              ),
                            ),
                          ],
                        ),
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

              // 8. Address
              CustomTextField(
                label: 'Address *',
                hintText: 'Enter Complete Address',
                maxLines: 3,
                controller: _addressController,
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
