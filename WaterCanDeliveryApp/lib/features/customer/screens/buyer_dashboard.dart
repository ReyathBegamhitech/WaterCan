import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import 'my_orders_screen.dart';
import 'product_detail_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../auth/screens/login_screen.dart';

class BuyerDashboardScreen extends StatefulWidget {
  final String customerName;
  final String address;
  final String phone;

  const BuyerDashboardScreen({
    super.key,
    required this.customerName,
    required this.address,
    required this.phone,
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

  void _showProfileSheet() {
    bool isEditingPhone = false;
    bool isOtpSent = false;
    bool isLoading = false;
    TextEditingController phoneController = TextEditingController(text: _addressLine2);
    TextEditingController otpController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
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
                  const CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.primaryContainer,
                    child: Icon(Icons.person, size: 40, color: AppColors.primary),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.customerName,
                    style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
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
                                _addressLine2,
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
                      onPressed: () {
                        if (phoneController.text.isNotEmpty && phoneController.text != _addressLine2) {
                          setModalState(() {
                            isOtpSent = true;
                          });
                        }
                      },
                      child: const Text('Send OTP'),
                    ),
                  ],

                  if (isOtpSent) ...[
                    const SizedBox(height: 16),
                    TextField(
                      controller: otpController,
                      decoration: const InputDecoration(hintText: 'Enter OTP (Type 1234)'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: () async {
                              if (otpController.text == '1234') {
                                setModalState(() { isLoading = true; });
                                try {
                                  final response = await http.put(
                                    Uri.parse('http://localhost:3000/api/auth/phone'),
                                    headers: {'Content-Type': 'application/json'},
                                    body: jsonEncode({
                                      'oldPhone': _addressLine2,
                                      'newPhone': phoneController.text,
                                    }),
                                  );
                                  if (response.statusCode == 200) {
                                    setState(() { _addressLine2 = phoneController.text; });
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Phone number updated!')));
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to update phone.')));
                                  }
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error connecting to server.')));
                                } finally {
                                  setModalState(() { isLoading = false; });
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid OTP')));
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
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      icon: const Icon(Icons.logout),
                      label: Text('Logout', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
                      onPressed: () {
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
                                onPressed: () {
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                                    (route) => false,
                                  );
                                },
                                child: const Text('Yes', style: TextStyle(color: AppColors.error)),
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

  late String _addressLine1;
  late String _addressLine2;

  @override
  void initState() {
    super.initState();
    _addressLine1 = widget.address.isNotEmpty ? widget.address : 'No address provided';
    _addressLine2 = widget.phone;
  }

  final List<Map<String, String>> shops = [
    {
      'name': 'Aqua Pure SpringsP',
      'location': 'Sector 4, Bellandur',
      'image': 'https://lh3.googleusercontent.com/aida-public/AB6AXuAet-1rb_NdGWMMjB0XFPCWZs2tPo8xJNywp8bDviNbrW1eTNTvTqz1DncuC9UeqWDgVcJ1bThd1934sHn2W06qu1I66hWvCwXinOF2P3b2k16ZaytIs71YkQtu7D4MJs1ziN9RhomXmlwrD-nEHxfXf1ewFzMWe_VWURXG5vlGv80c5UgH4nHuLubO2b4VRABwgmNL1Z5VrnOJzHgj6sihTjjWy1lWQw_qw8ykVRG5Pw23NdZ83OOh'
    },
    {
      'name': 'Blue Drop Water Co.',
      'location': 'Outer Ring Road, Bengaluru',
      'image': 'https://lh3.googleusercontent.com/aida-public/AB6AXuAuCRqyDtGstt5_ULqIahq4qNxrL5ss9B-ZiYN2PZdLNT0fy9ldRjHJuBELLd12X4TMbRmc1yx1oD1jt8WtNwW_qyenU_AylmuWCDEH5M27RBLtCK34ssvaW0XEIlMvFf6lRjBwhWGKzIu3uMz1mvxsGbR5vXuqGgygRU3kSeIYmlHRM8yFn0ubjfRtEjll0BCrv1DHND-FIowU0j08cVM2m6pqbgAlCQ75ImQhZK_Q4IeygqDLZP0l'
    },
    {
      'name': 'Pristine Waters Hub',
      'location': 'Koramangala 5th Block',
      'image': 'https://lh3.googleusercontent.com/aida-public/AB6AXuCBFduyAMEg9R71t9fPWde_lFIVuSEwfZ-DWelEVDYAH73UI8NB6e7yQpQHK25hgg5WAaDPkMcHl4Z50kqgZG4H4S6bOUX1JR-cRiG_KaKklnbzm_j3nPah-4D_vCRnsITR1tdQsId2-qwjDux3JHzZOPCv-ee8-64XCWtPV7vP6gczGZGJKAeyQrIX4QRsWmD0WdHJCbGozLw8F25P3fuJChH6D86xJ_PjXUsbFJZKYyqMLaIpWPml'
    },
    {
      'name': 'Himalayan Stream Plant',
      'location': 'HSR Layout, Sector 2',
      'image': 'https://lh3.googleusercontent.com/aida-public/AB6AXuDxOqHs9vWA_K9QGqA62ze_SpTAU2MBNSmxncRe1FhEpwsZmacCz_LvhmujKVR0cEYgOVJWs0Zd62wyoeFhGVSSUmQbO18xdMkrvqEdH8q85419DX9ButZkHnQRwY1Smnyzx7FMWIRpVvBSaCxAsNxQZS517bMdghT4vYu2oQkVFZt2BrCWPV0irM8_p0vCtqsoUKelVF_cTowIIQfnixPkg5M2Peb_dr9RM3S7JGOK6YkPrffkEHFo'
    },
    {
      'name': 'Crystal Clear Supplies',
      'location': 'Marathahalli Main Rd',
      'image': 'https://lh3.googleusercontent.com/aida-public/AB6AXuAet-1rb_NdGWMMjB0XFPCWZs2tPo8xJNywp8bDviNbrW1eTNTvTqz1DncuC9UeqWDgVcJ1bThd1934sHn2W06qu1I66hWvCwXinOF2P3b2k16ZaytIs71YkQtu7D4MJs1ziN9RhomXmlwrD-nEHxfXf1ewFzMWe_VWURXG5vlGv80c5UgH4nHuLubO2b4VRABwgmNL1Z5VrnOJzHgj6sihTjjWy1lWQw_qw8ykVRG5Pw23NdZ83OOh'
    },
    {
      'name': 'Oasis Water Depot',
      'location': 'Whitefield ITPL Road',
      'image': 'https://lh3.googleusercontent.com/aida-public/AB6AXuAuCRqyDtGstt5_ULqIahq4qNxrL5ss9B-ZiYN2PZdLNT0fy9ldRjHJuBELLd12X4TMbRmc1yx1oD1jt8WtNwW_qyenU_AylmuWCDEH5M27RBLtCK34ssvaW0XEIlMvFf6lRjBwhWGKzIu3uMz1mvxsGbR5vXuqGgygRU3kSeIYmlHRM8yFn0ubjfRtEjll0BCrv1DHND-FIowU0j08cVM2m6pqbgAlCQ75ImQhZK_Q4IeygqDLZP0l'
    },
    {
      'name': 'Glacier Peak Drops',
      'location': 'Indiranagar 100ft Road',
      'image': 'https://lh3.googleusercontent.com/aida-public/AB6AXuCBFduyAMEg9R71t9fPWde_lFIVuSEwfZ-DWelEVDYAH73UI8NB6e7yQpQHK25hgg5WAaDPkMcHl4Z50kqgZG4H4S6bOUX1JR-cRiG_KaKklnbzm_j3nPah-4D_vCRnsITR1tdQsId2-qwjDux3JHzZOPCv-ee8-64XCWtPV7vP6gczGZGJKAeyQrIX4QRsWmD0WdHJCbGozLw8F25P3fuJChH6D86xJ_PjXUsbFJZKYyqMLaIpWPml'
    },
    {
      'name': 'Nectar Can Deliveries',
      'location': 'BTM Layout, 2nd Stage',
      'image': 'https://lh3.googleusercontent.com/aida-public/AB6AXuDxOqHs9vWA_K9QGqA62ze_SpTAU2MBNSmxncRe1FhEpwsZmacCz_LvhmujKVR0cEYgOVJWs0Zd62wyoeFhGVSSUmQbO18xdMkrvqEdH8q85419DX9ButZkHnQRwY1Smnyzx7FMWIRpVvBSaCxAsNxQZS517bMdghT4vYu2oQkVFZt2BrCWPV0irM8_p0vCtqsoUKelVF_cTowIIQfnixPkg5M2Peb_dr9RM3S7JGOK6YkPrffkEHFo'
    },
    {
      'name': 'Springs Direct',
      'location': 'Electronic City Phase 1',
      'image': 'https://lh3.googleusercontent.com/aida-public/AB6AXuAet-1rb_NdGWMMjB0XFPCWZs2tPo8xJNywp8bDviNbrW1eTNTvTqz1DncuC9UeqWDgVcJ1bThd1934sHn2W06qu1I66hWvCwXinOF2P3b2k16ZaytIs71YkQtu7D4MJs1ziN9RhomXmlwrD-nEHxfXf1ewFzMWe_VWURXG5vlGv80c5UgH4nHuLubO2b4VRABwgmNL1Z5VrnOJzHgj6sihTjjWy1lWQw_qw8ykVRG5Pw23NdZ83OOh'
    },
    {
      'name': 'River Source Co.',
      'location': 'Jayanagar 4th Block',
      'image': 'https://lh3.googleusercontent.com/aida-public/AB6AXuAuCRqyDtGstt5_ULqIahq4qNxrL5ss9B-ZiYN2PZdLNT0fy9ldRjHJuBELLd12X4TMbRmc1yx1oD1jt8WtNwW_qyenU_AylmuWCDEH5M27RBLtCK34ssvaW0XEIlMvFf6lRjBwhWGKzIu3uMz1mvxsGbR5vXuqGgygRU3kSeIYmlHRM8yFn0ubjfRtEjll0BCrv1DHND-FIowU0j08cVM2m6pqbgAlCQ75ImQhZK_Q4IeygqDLZP0l'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary.withOpacity(0.1), // bg-primary/10
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: AppBar(
          backgroundColor: AppColors.surface.withOpacity(0.85),
          elevation: 1,
          shadowColor: Colors.black.withOpacity(0.1),
          titleSpacing: 16,
          leadingWidth: 150, // Increased to prevent overflow
          leading: Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 12, bottom: 12),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MyOrdersScreen())),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh, // Darker background to look more like a button
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)), // Added subtle border
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
          title: Text(
            'Hello 👋 ${widget.customerName.split(' ').first}',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: InkWell(
                onTap: _showProfileSheet,
                child: const CircleAvatar(
                  backgroundColor: AppColors.primary,
                  radius: 20,
                  child: const Icon(Icons.person, color: AppColors.onPrimary, size: 20),
                ),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Bar
            Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.outlineVariant.withOpacity(0.3)),
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
                  const Icon(Icons.search, color: AppColors.onSurfaceVariant, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      style: GoogleFonts.plusJakartaSans(fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Search by shop name or location...',
                        hintStyle: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          color: AppColors.onSurfaceVariant,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(shape: BoxShape.circle),
                      child: const Icon(Icons.tune, color: AppColors.onSurfaceVariant, size: 20),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

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
                            InkWell(
                              onTap: () {
                                final TextEditingController line1Ctrl = TextEditingController(text: _addressLine1);
                                final TextEditingController line2Ctrl = TextEditingController(text: _addressLine2);
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: AppColors.surfaceContainerLowest,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                  ),
                                  builder: (context) => Padding(
                                    padding: EdgeInsets.only(
                                      bottom: MediaQuery.of(context).viewInsets.bottom,
                                      left: 20, right: 20, top: 20,
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Edit Delivery Address', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
                                        const SizedBox(height: 16),
                                        TextField(
                                          controller: line1Ctrl,
                                          decoration: InputDecoration(
                                            labelText: 'Address Line 1',
                                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        TextField(
                                          controller: line2Ctrl,
                                          decoration: InputDecoration(
                                            labelText: 'Address Line 2 (City, Pincode)',
                                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton(
                                            onPressed: () {
                                              setState(() {
                                                _addressLine1 = line1Ctrl.text;
                                                _addressLine2 = line2Ctrl.text;
                                              });
                                              Navigator.pop(context);
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
                              borderRadius: BorderRadius.circular(6),
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
                        const SizedBox(height: 4),
                        Text(
                          _addressLine1,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          _addressLine2,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: AppColors.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Available Shops Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 20,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Available Shops',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurface,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Padding(
                    padding: const EdgeInsets.only(left: 14.0),
                    child: Text(
                      'Verified water suppliers near you',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Shop Grid with 3D Scroll Effect
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.75, // Adjust based on card height
              ),
              itemCount: shops.length,
              itemBuilder: (context, index) {
                final shop = shops[index];
                
                return AnimatedBuilder(
                  animation: _scrollController,
                  builder: (context, child) {
                    double scale = 1.0;
                    double fadeLevel = 0.0;
                    
                    if (_scrollController.hasClients) {
                      double cardTop = 280.0 + ((index ~/ 2) * 250.0);
                      double screenCenter = _scrollController.offset + (MediaQuery.of(context).size.height / 2);
                      double cardCenter = cardTop + 125.0;
                      
                      double distanceFromCenter = (screenCenter - cardCenter).abs();
                      
                      // Create a 'safe zone' in the middle of the screen where cards are 100% visible
                      // This ensures the last row is visible even if it can't reach the exact pixel center
                      double safeZone = 150.0; 
                      double effectiveDistance = (distanceFromCenter - safeZone).clamp(0.0, 1000.0);
                      
                      // Smoother scale (down to 0.8)
                      scale = (1 - (effectiveDistance / 800)).clamp(0.8, 1.0);
                      
                      // Fade level for opacity and fold
                      fadeLevel = (effectiveDistance / 300).clamp(0.0, 1.0);
                      
                      // 3D Matrix Transform for fold and slide
                      final double rotationDirection = cardCenter > screenCenter ? 1.0 : -1.0;
                      final Matrix4 matrix = Matrix4.identity()
                        ..setEntry(3, 2, 0.001) // Perspective
                        ..translate(0.0, fadeLevel * 60.0 * rotationDirection, 0.0) // Slide outwards (parallax)
                        ..rotateX(fadeLevel * 0.4 * rotationDirection) // 3D Fold back
                        ..scale(scale, scale, 1.0);

                      return Transform(
                        transform: matrix,
                        alignment: FractionalOffset.center,
                        child: Opacity(
                          // Clean fade into the background without dark overlays
                          opacity: (1.0 - (fadeLevel * 1.2)).clamp(0.0, 1.0),
                          child: child,
                        ),
                      );
                    }

                    return child!;
                  },
                  child: _buildShopCard(context, index, shop),
                );
              },
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildShopCard(BuildContext context, int index, Map<String, String> shop) {
    final card = Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  shop['image']!,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      shop['name']!,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      shop['location']!,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: AppColors.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_forward, color: AppColors.onPrimary, size: 18),
              ),
            ],
          ),
        ],
      ),
    );

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(shop: shop),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: card,
    );
  }
}
