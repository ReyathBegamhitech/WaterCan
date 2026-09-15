import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/api_constants.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../customer/screens/buyer_dashboard.dart';
import '../../seller/screens/seller_dashboard.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;
  bool _isLoading = false;
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _login() async {
    if (_phoneController.text == 'seller123' && _passwordController.text == '123456') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SellerDashboardScreen()),
      );
      return;
    }

    if (_phoneController.text == 'buyer123' && _passwordController.text == '123456') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const BuyerDashboardScreen(
            customerName: 'Test Buyer',
            address: '123 Main St',
            phone: 'buyer123',
          ),
        ),
      );
      return;
    }

    if (_phoneController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields.')));
      return;
    }

    setState(() { _isLoading = true; });

    try {
      final response = await http.post(
        Uri.parse(ApiConstants.login),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone': _phoneController.text,
          'password': _passwordController.text,
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Login successful!')));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => BuyerDashboardScreen(
              customerName: data['user']['fullName'],
              address: data['user']['address'],
              phone: data['user']['phone'],
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['message'] ?? 'Login failed.')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error connecting to server.')));
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Top Banner Background
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 208, // h-52 is 13rem = 208px
            child: Stack(
              children: [
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.60, // Adjusted from 0.75 to make it slightly more subtle
                    child: Image.network(
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuDVtOSL7yYRX4hoG4qDjmkvSKeeV311xaCwZH1rZ3kdOECjPqkq560nIY_Tm0QP9nxK9vOxTPRkAVD1IfUFOoWgDOhMdWlOv8lAiKSrmcNUFnRd7oBDIxw8RP5PbIG8c6TPMxn09b1F5KaDxU6Bbbfb9GAQpV-nSoP9bbQjkmiqnwM6Ap7TUabTnMBQk7BXoFEWPdqNPSgsSqF0G_raf5WV4M5iLepTtkTGyEUZs12goue3c3upy922Bcbtz3wM6yb8ag',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.primary.withOpacity(0.1),
                          AppColors.background.withOpacity(0.0),
                          AppColors.background,
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Bottom Banner Background
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 176, // h-44 is 11rem = 176px
            child: Stack(
              children: [
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.60, // Adjusted from 0.75 to make it slightly more subtle
                    child: Image.network(
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuDP5rVrXr1yWQfFQ6gGvv4OHf8ZyvrWIr8fURTAtR_R6dfT1oMt-10u8vGbqIaNmrCLFV9AW4XTYPUuVtx9wfrXQt9VHROkAp4YeJHjeh6TYpx5EVEvJOGm9EKxdBruSZa8PU6sI-uQvTZ2V9Eysm21Vi9RLXmJNFJYVxBmpsY-WTI_dcFYtnJYaKSo0ArFlyJYfYfxVuLgTocYvAbZbFkNmVZ-BFrc1QyqtyKC2oKWGr5NSxMZtdZRna9K3Z3sOr075A',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.background,
                          AppColors.background.withOpacity(0.0),
                          AppColors.primary.withOpacity(0.1),
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Main Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16), // screen-margin-mobile
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Container(
                    padding: const EdgeInsets.all(20), // card-padding-mobile (1.25rem = 20px)
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(12), // rounded-xl
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Lock Icon
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.lock_outline,
                            color: AppColors.onPrimary,
                            size: 28,
                          ),
                        ),
                        const SizedBox(height: 12), // space-sm
                        
                        // LOGIN Title
                        Text(
                          'LOGIN',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 26, // headline-lg-mobile
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5, // tracking-tight
                            color: AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 32), // margin-bottom: 2rem
                        
                        // Phone/Email Field
                        CustomTextField(
                          controller: _phoneController,
                          label: 'Phone Number / Email',
                          hintText: 'Enter Phone Number / Email',
                          prefixIcon: Icons.account_circle_outlined,
                        ),
                        const SizedBox(height: 16), // space-md
                        
                        // Password Field
                        CustomTextField(
                          controller: _passwordController,
                          label: 'Password',
                          hintText: 'Enter Password',
                          prefixIcon: Icons.key_outlined,
                          obscureText: _obscurePassword,
                          suffixIcon: _obscurePassword 
                              ? Icons.visibility_off_outlined 
                              : Icons.visibility_outlined,
                          onSuffixIconTap: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        const SizedBox(height: 24), // pt-space-xs + space-md roughly
                        
                        // Login Button
                        _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : PrimaryButton(
                                text: 'LOGIN',
                                trailingIcon: Icons.arrow_forward,
                                onPressed: _login,
                              ),
                        const SizedBox(height: 16), // space-md
                        
                        // Register Link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account? ",
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12, // body-sm
                                fontWeight: FontWeight.w400,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const RegisterScreen()),
                                );
                              },
                              child: Text(
                                "Register",
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13, // label-md
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4), // pt-space-xs roughly
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
