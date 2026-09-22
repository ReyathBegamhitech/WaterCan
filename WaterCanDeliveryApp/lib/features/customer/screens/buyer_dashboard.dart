import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/user_controller.dart';
import '../controllers/order_controller.dart';
import 'my_orders_screen.dart';
import 'order_configuration_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../auth/screens/login_screen.dart';
import '../../../core/constants/api_constants.dart';

class BuyerDashboardScreen extends StatefulWidget {
  final String? customerName;
  final String? address;
  final String? phone;

  const BuyerDashboardScreen({
    super.key,
    this.customerName,
    this.address,
    this.phone,
  });

  @override
  State<BuyerDashboardScreen> createState() => _BuyerDashboardScreenState();
}

class _BuyerDashboardScreenState extends State<BuyerDashboardScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _showProfileSheet(UserController userCtrl) {
    bool isEditingName = false;
    bool isEditingPhone = false;
    bool isOtpSent = false;
    bool isLoading = false;
    TextEditingController nameController = TextEditingController(text: userCtrl.customerName);
    TextEditingController phoneController = TextEditingController(text: userCtrl.phone);
    TextEditingController otpController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
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
                  CircleAvatar(
                    radius: 42,
                    backgroundColor: const Color(0xFFE0F2FE), // Light sky blue
                    child: Text(
                      userCtrl.customerName.trim().isNotEmpty
                          ? userCtrl.customerName.trim()[0].toUpperCase()
                          : 'U',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0284C7), // Dark sky blue
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (isEditingName) ...[
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: nameController,
                            autofocus: true,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Full Name',
                              hintText: 'Enter your name',
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          tooltip: 'Save Name',
                          icon: const Icon(Icons.check_circle, color: AppColors.primary, size: 28),
                          onPressed: () async {
                            final newName = nameController.text.trim();
                            if (newName.isNotEmpty) {
                              await userCtrl.updateName(newName);
                              setModalState(() {
                                isEditingName = false;
                              });
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Name updated to "$newName"'),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              }
                            }
                          },
                        ),
                        IconButton(
                          tooltip: 'Cancel',
                          icon: const Icon(Icons.cancel_outlined, color: AppColors.onSurfaceVariant, size: 28),
                          onPressed: () {
                            setModalState(() {
                              isEditingName = false;
                              nameController.text = userCtrl.customerName;
                            });
                          },
                        ),
                      ],
                    ),
                  ] else ...[
                    InkWell(
                      onTap: () {
                        setModalState(() {
                          isEditingName = true;
                          nameController.text = userCtrl.customerName;
                        });
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                userCtrl.customerName,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              tooltip: 'Edit Name',
                              icon: const Icon(Icons.edit, size: 20, color: AppColors.primary),
                              onPressed: () {
                                setModalState(() {
                                  isEditingName = true;
                                  nameController.text = userCtrl.customerName;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  
                  Row(
                    children: [
                      const Icon(Icons.phone, color: AppColors.onSurfaceVariant),
                      const SizedBox(width: 12),
                      Expanded(
                        child: isEditingPhone
                            ? TextField(
                                controller: phoneController,
                                decoration: const InputDecoration(hintText: 'New Phone Number'),
                                keyboardType: TextInputType.phone,
                              )
                            : Text(
                                userCtrl.phone.isNotEmpty ? userCtrl.phone : 'No phone number provided',
                                style: GoogleFonts.plusJakartaSans(fontSize: 16),
                              ),
                      ),
                      IconButton(
                        icon: Icon(isEditingPhone ? Icons.close : Icons.edit, color: AppColors.primary),
                        onPressed: () {
                          setModalState(() {
                            isEditingPhone = !isEditingPhone;
                            isOtpSent = false;
                          });
                        },
                      ),
                    ],
                  ),
                  
                  if (isEditingPhone && !isOtpSent) ...[
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () async {
                        if (phoneController.text.isNotEmpty && phoneController.text != userCtrl.phone) {
                          setModalState(() { isLoading = true; });
                          try {
                            final response = await http.post(
                              Uri.parse(ApiConstants.sendOtp),
                              headers: {'Content-Type': 'application/json'},
                              body: jsonEncode({'phone': phoneController.text}),
                            );
                            final data = jsonDecode(response.body);
                            
                            if (response.statusCode == 200 && data['success'] == true) {
                              setModalState(() {
                                isOtpSent = true;
                              });
                              if (bottomSheetContext.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('OTP sent! ${data['message'] ?? ''}'))
                                );
                              }
                            } else {
                              if (bottomSheetContext.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(data['message'] ?? 'Failed to send OTP.'))
                                );
                              }
                            }
                          } catch (e) {
                            if (bottomSheetContext.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error connecting to server.')));
                            }
                          } finally {
                            setModalState(() { isLoading = false; });
                          }
                        }
                      },
                      child: isLoading 
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Send OTP'),
                    ),
                  ],

                  if (isOtpSent) ...[
                    const SizedBox(height: 16),
                    TextField(
                      controller: otpController,
                      decoration: const InputDecoration(hintText: 'Enter 4-digit OTP'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: () async {
                              if (otpController.text.length >= 4) {
                                setModalState(() { isLoading = true; });
                                try {
                                  // Verify OTP first
                                  final verifyResponse = await http.post(
                                    Uri.parse(ApiConstants.verifyOtp),
                                    headers: {'Content-Type': 'application/json'},
                                    body: jsonEncode({
                                      'phone': phoneController.text,
                                      'otp': otpController.text
                                    }),
                                  );
                                  
                                  final verifyData = jsonDecode(verifyResponse.body);
                                  
                                  if (verifyResponse.statusCode == 200 && verifyData['success'] == true) {
                                    // OTP Verified, now update phone number
                                    final response = await http.put(
                                      Uri.parse(ApiConstants.updatePhone),
                                      headers: {'Content-Type': 'application/json'},
                                      body: jsonEncode({
                                        'oldPhone': userCtrl.phone,
                                        'newPhone': phoneController.text,
                                      }),
                                    );
                                    
                                    if (response.statusCode == 200) {
                                      await userCtrl.updatePhone(phoneController.text);
                                      if (bottomSheetContext.mounted) {
                                        Navigator.pop(bottomSheetContext);
                                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Phone number updated successfully!')));
                                      }
                                    } else {
                                      if (bottomSheetContext.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to update phone.')));
                                      }
                                    }
                                  } else {
                                    if (bottomSheetContext.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(verifyData['message'] ?? 'Invalid OTP')));
                                    }
                                  }
                                } catch (e) {
                                  if (bottomSheetContext.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error connecting to server.')));
                                  }
                                } finally {
                                  setModalState(() { isLoading = false; });
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter the full OTP')));
                              }
                            },
                            child: const Text('Verify & Save'),
                          ),
                  ],

                  const Divider(height: 48),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.onSurfaceVariant,
                        side: BorderSide(color: AppColors.outline.withOpacity(0.3)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      icon: const Icon(Icons.logout),
                      label: Text('Logout', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (dialogCtx) => AlertDialog(
                            title: const Text('Logout'),
                            content: const Text('Are you sure you want to logout?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(dialogCtx),
                                child: const Text('No'),
                              ),
                              TextButton(
                                onPressed: () async {
                                  await userCtrl.clear();
                                  if (context.mounted) {
                                    Navigator.pop(dialogCtx);
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                                      (route) => false,
                                    );
                                  }
                                },
                                child: const Text('Yes', style: TextStyle(color: AppColors.error)),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      icon: const Icon(Icons.delete_forever),
                      label: Text('Deactivate Account', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (dialogCtx) => AlertDialog(
                            title: const Text('Deactivate Account'),
                            content: const Text('Are you sure you want to deactivate your account? This will completely erase all your data.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(dialogCtx),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () async {
                                  final success = await userCtrl.deleteAccount();
                                  if (context.mounted) {
                                    Navigator.pop(dialogCtx);
                                    if (success) {
                                      Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                                        (route) => false,
                                      );
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Account deactivated successfully')),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Failed to deactivate account')),
                                      );
                                    }
                                  }
                                },
                                child: const Text('Deactivate', style: TextStyle(color: AppColors.error)),
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
      },
    );
  }

  void _showEditNameDialog(UserController userCtrl) {
    final TextEditingController nameEditController = TextEditingController(text: userCtrl.customerName);
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.person, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              'Edit Your Name',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Update your display name across the app:',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameEditController,
              autofocus: true,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                labelText: 'Full Name',
                hintText: 'Enter your name',
                prefixIcon: const Icon(Icons.badge_outlined, color: AppColors.primary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(
              'Cancel',
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              final newName = nameEditController.text.trim();
              if (newName.isNotEmpty) {
                await userCtrl.updateName(newName);
                if (dialogCtx.mounted) {
                  Navigator.pop(dialogCtx);
                }
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Name updated to "$newName"'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              }
            },
            child: Text(
              'Save',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final userCtrl = Provider.of<UserController>(context, listen: false);
      if (userCtrl.customerName.isEmpty || userCtrl.customerName == 'User') {
        if (widget.customerName != null && widget.customerName!.isNotEmpty && widget.customerName != 'User') {
          userCtrl.updateName(widget.customerName!);
        }
      }
      if (userCtrl.phone.isEmpty && widget.phone != null && widget.phone!.isNotEmpty) {
        userCtrl.updatePhone(widget.phone!);
      }
      if (userCtrl.doorNo.isEmpty && widget.address != null && widget.address!.isNotEmpty) {
        userCtrl.updateAddress(
          doorNo: widget.address!,
          street: '',
          city: '',
          pincode: '',
        );
      }
    });
  }


  Widget _buildPricingCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String price,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.6)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                price,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.priceColor,
                ),
              ),
              Text(
                'per can',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserController>(
      builder: (context, userCtrl, _) {
        final displayName = userCtrl.customerName.isNotEmpty
            ? userCtrl.customerName
            : (widget.customerName?.isNotEmpty == true ? widget.customerName! : 'User');
        final givenAddress = userCtrl.fullAddress.isNotEmpty
            ? userCtrl.fullAddress
            : (widget.address?.isNotEmpty == true ? widget.address! : '');
        final displayAddress = givenAddress.isNotEmpty ? givenAddress : 'No address provided';

        return Scaffold(
          backgroundColor: AppColors.surfaceContainerLow,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(64),
            child: AppBar(
              backgroundColor: AppColors.surfaceContainerLow,
              elevation: 1,
              shadowColor: Colors.black.withOpacity(0.1),
              titleSpacing: 16,
              leadingWidth: 150,
              leading: Padding(
                padding: const EdgeInsets.only(left: 16.0, top: 12, bottom: 12),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MyOrdersScreen())),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.receipt_long, color: AppColors.primary, size: 20),
                        const SizedBox(width: 6),
                        Text(
                          'My Orders',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              centerTitle: true,
              title: InkWell(
                onTap: () => _showEditNameDialog(userCtrl),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: Text(
                    'Hello 👋 ${displayName.split(' ').first}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: GestureDetector(
                    onTap: () => _showProfileSheet(userCtrl),
                    child: CircleAvatar(
                      backgroundColor: AppColors.primary,
                      radius: 20,
                      child: Text(
                        userCtrl.customerName.trim().isNotEmpty
                            ? userCtrl.customerName.trim()[0].toUpperCase()
                            : 'U',
                        style: GoogleFonts.plusJakartaSans(
                          color: AppColors.onPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          body: Stack(
            children: [
              SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 120.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
            // Delivering To Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.secondaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.location_on, color: AppColors.onSecondaryContainer, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'DELIVERING TO',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: AppColors.onSurfaceVariant,
                                letterSpacing: 0.5,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                final TextEditingController doorNoCtrl = TextEditingController(
                                  text: userCtrl.doorNo,
                                );
                                final TextEditingController streetCtrl = TextEditingController(
                                  text: userCtrl.street,
                                );
                                final TextEditingController cityCtrl = TextEditingController(
                                  text: userCtrl.city,
                                );
                                final TextEditingController pincodeCtrl = TextEditingController(
                                  text: userCtrl.pincode,
                                );
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: AppColors.surfaceContainerLowest,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                  ),
                                  builder: (modalContext) => Padding(
                                    padding: EdgeInsets.only(
                                      bottom: MediaQuery.of(modalContext).viewInsets.bottom,
                                      left: 20, right: 20, top: 20,
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Edit Delivery Address', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
                                        const SizedBox(height: 16),
                                        Row(
                                          children: [
                                            Expanded(
                                              flex: 1,
                                              child: TextField(
                                                controller: doorNoCtrl,
                                                decoration: InputDecoration(
                                                  labelText: 'Door No',
                                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              flex: 2,
                                              child: TextField(
                                                controller: streetCtrl,
                                                decoration: InputDecoration(
                                                  labelText: 'Street',
                                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: TextField(
                                                controller: cityCtrl,
                                                decoration: InputDecoration(
                                                  labelText: 'City',
                                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: TextField(
                                                controller: pincodeCtrl,
                                                decoration: InputDecoration(
                                                  labelText: 'Pincode',
                                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 20),
                                        SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton(
                                            onPressed: () async {
                                              await userCtrl.updateAddress(
                                                doorNo: doorNoCtrl.text,
                                                street: streetCtrl.text,
                                                city: cityCtrl.text,
                                                pincode: pincodeCtrl.text,
                                              );
                                              if (modalContext.mounted) {
                                                Navigator.pop(modalContext);
                                              }
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(content: Text('Delivery address updated!')),
                                                );
                                              }
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: AppColors.primary,
                                              foregroundColor: AppColors.onPrimary,
                                              padding: const EdgeInsets.symmetric(vertical: 14),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                            ),
                                            child: const Text('Save Address', style: TextStyle(fontWeight: FontWeight.bold)),
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                      ],
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1),
                                ),
                                child: Text(
                                  'Change',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        InkWell(
                          onTap: () => _showEditNameDialog(userCtrl),
                          borderRadius: BorderRadius.circular(4),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.person_outline, size: 14, color: AppColors.primary),
                                const SizedBox(width: 4),
                                Text(
                                  displayName,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.onSurface,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          displayAddress,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSurface,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
                    const SizedBox(height: 24),
                    // Product Image
                    Container(
                      width: double.infinity,
                      height: 288,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          'https://lh3.googleusercontent.com/aida-public/AB6AXuB6PE3NGNhdEAaS7qpzHWGvc9tQOLb7TuJwM2aFU_PYLOVBXaab7YULTJSvmGNiWlIVIKNTlYSKuc2C_hYtt3U_owMwXZoifPA_JZGHkSoV4wmusYnTqbrp9S7ORF-a041ZibcksBBicAbgJF2sVmb62kRqQN2hu10bCFbF5o6baAq07a7yTGOVGSv8cfvD3uJqxErfr3UO8TyH0kLW12Lq2FOrht4n8CHoVUe7gx5UENJmzg9Xn0FF',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Primary Headline (Vendor info)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userCtrl.shopName.isNotEmpty ? userCtrl.shopName : 'Water Can Shop',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.onSurface,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.storefront_outlined, color: AppColors.primary, size: 18),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  userCtrl.shopAddress.isNotEmpty ? userCtrl.shopAddress : 'Address not provided',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    color: AppColors.onSurfaceVariant,
                                    height: 1.3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Litre & Pricing Section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Litre & Pricing',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.onSurface,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildPricingCard(
                            icon: Icons.water_drop,
                            title: '25 Litre Can',
                            subtitle: 'Standard household & office refill',
                            price: '₹50',
                          ),
                          _buildPricingCard(
                            icon: Icons.water_drop_outlined,
                            title: '15 Litre Can',
                            subtitle: 'Compact medium capacity',
                            price: '₹35',
                          ),
                          _buildPricingCard(
                            icon: Icons.local_drink,
                            title: '10 Litre Can',
                            subtitle: 'Small portable daily can',
                            price: '₹25',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Sticky Bottom Bar
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 24),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest.withOpacity(0.95),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 16,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Center(
                      child: _GlowingBookButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OrderConfigurationScreen(
                                shop: {
                                  'id': userCtrl.assignedSellerId.isNotEmpty ? userCtrl.assignedSellerId : 'S-0000',
                                  'name': userCtrl.shopName.isNotEmpty ? userCtrl.shopName : 'Water Can Shop',
                                  'location': 'Sector 4, Bellandur, Bengaluru - 560103',
                                },
                                deliveryAddress: userCtrl.fullAddress.isNotEmpty && userCtrl.fullAddress != 'No address provided' 
                                    ? userCtrl.fullAddress 
                                    : UserController.defaultFullAddress,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _GlowingBookButton extends StatefulWidget {
  final VoidCallback onPressed;
  const _GlowingBookButton({required this.onPressed});

  @override
  State<_GlowingBookButton> createState() => _GlowingBookButtonState();
}

class _GlowingBookButtonState extends State<_GlowingBookButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: 190,
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.4),
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: Stack(
              children: [
                SizedBox.expand(
                  child: ElevatedButton(
                    onPressed: widget.onPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.shopping_bag_outlined, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'BOOK NOW',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment(-2.0 + (_controller.value * 4), 0),
                          end: Alignment(-1.0 + (_controller.value * 4), 0),
                          colors: [
                            Colors.white.withOpacity(0.0),
                            Colors.white.withOpacity(0.5),
                            Colors.white.withOpacity(0.0),
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                      ),
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
}
