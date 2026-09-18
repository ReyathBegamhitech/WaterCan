import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/user_controller.dart';
import '../controllers/order_controller.dart';
import 'my_orders_screen.dart';
import 'product_detail_screen.dart';
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
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedLocation = 'All';
  String _sortBy = 'default';

  bool get _isFilterActive => _selectedLocation != 'All' || _sortBy != 'default';

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
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
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
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

  List<Map<String, String>> get _filteredShops {
    List<Map<String, String>> list = List.from(shops);

    // 1. Filter by location
    if (_selectedLocation != 'All') {
      list = list.where((shop) {
        final loc = (shop['location'] ?? '').toLowerCase();
        return loc.contains(_selectedLocation.toLowerCase());
      }).toList();
    }

    // 2. Filter by search query
    if (_searchQuery.trim().isNotEmpty) {
      final query = _searchQuery.trim().toLowerCase();
      list = list.where((shop) {
        final name = (shop['name'] ?? '').toLowerCase();
        final loc = (shop['location'] ?? '').toLowerCase();
        return name.contains(query) || loc.contains(query);
      }).toList();
    }

    // 3. Sort
    if (_sortBy == 'name_asc') {
      list.sort((a, b) => (a['name'] ?? '').toLowerCase().compareTo((b['name'] ?? '').toLowerCase()));
    } else if (_sortBy == 'name_desc') {
      list.sort((a, b) => (b['name'] ?? '').toLowerCase().compareTo((a['name'] ?? '').toLowerCase()));
    }

    return list;
  }

  void _showFilterSheet() {
    String tempLocation = _selectedLocation;
    String tempSort = _sortBy;

    const List<String> locations = [
      'All',
      'Bellandur',
      'Outer Ring Road',
      'Koramangala',
      'HSR Layout',
      'Marathahalli',
      'Whitefield',
      'Indiranagar',
      'BTM Layout',
      'Electronic City',
      'Jayanagar',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                left: 20,
                right: 20,
                top: 20,
              ),
              decoration: const BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.outlineVariant.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.tune, color: AppColors.primary, size: 20),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Filters & Sort',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.onSurface,
                            ),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () {
                          setSheetState(() {
                            tempLocation = 'All';
                            tempSort = 'default';
                          });
                        },
                        child: Text(
                          'Reset All',
                          style: GoogleFonts.plusJakartaSans(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'SORT BY',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurfaceVariant,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildSortChip(
                        label: 'Recommended',
                        icon: Icons.star_outline,
                        isSelected: tempSort == 'default',
                        onTap: () => setSheetState(() => tempSort = 'default'),
                      ),
                      _buildSortChip(
                        label: 'Name (A to Z)',
                        icon: Icons.arrow_downward,
                        isSelected: tempSort == 'name_asc',
                        onTap: () => setSheetState(() => tempSort = 'name_asc'),
                      ),
                      _buildSortChip(
                        label: 'Name (Z to A)',
                        icon: Icons.arrow_upward,
                        isSelected: tempSort == 'name_desc',
                        onTap: () => setSheetState(() => tempSort = 'name_desc'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'FILTER BY LOCATION',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurfaceVariant,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 160),
                    child: SingleChildScrollView(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: locations.map((loc) {
                          final isSelected = tempLocation == loc;
                          return ChoiceChip(
                            label: Text(loc),
                            selected: isSelected,
                            onSelected: (selected) {
                              setSheetState(() {
                                tempLocation = selected ? loc : 'All';
                              });
                            },
                            labelStyle: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected ? AppColors.onPrimary : AppColors.onSurface,
                            ),
                            selectedColor: AppColors.primary,
                            backgroundColor: AppColors.surfaceContainerLow,
                            side: BorderSide(
                              color: isSelected ? AppColors.primary : AppColors.outlineVariant.withOpacity(0.5),
                            ),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            showCheckmark: false,
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _selectedLocation = tempLocation;
                          _sortBy = tempSort;
                        });
                        Navigator.pop(modalContext);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 2,
                      ),
                      child: Text(
                        'Apply Filters',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
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

  Widget _buildSortChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.outlineVariant.withOpacity(0.5),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? AppColors.onPrimary : AppColors.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.onPrimary : AppColors.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserController>(
      builder: (context, userCtrl, _) {
        final finalShops = _filteredShops;
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
                  child: InkWell(
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
                      controller: _searchController,
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val;
                        });
                      },
                      style: GoogleFonts.plusJakartaSans(fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Search by shop name or location...',
                        hintStyle: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          color: AppColors.onSurfaceVariant,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 16, color: AppColors.onSurfaceVariant),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _searchQuery = '';
                                  });
                                },
                              )
                            : null,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: _showFilterSheet,
                    borderRadius: BorderRadius.circular(20),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _isFilterActive
                                ? AppColors.primary.withOpacity(0.12)
                                : Colors.transparent,
                            shape: BoxShape.circle,
                            border: _isFilterActive
                                ? Border.all(color: AppColors.primary.withOpacity(0.4), width: 1.5)
                                : null,
                          ),
                          child: Icon(
                            Icons.tune,
                            color: _isFilterActive ? AppColors.primary : AppColors.onSurfaceVariant,
                            size: 20,
                          ),
                        ),
                        if (_isFilterActive)
                          Positioned(
                            top: 2,
                            right: 2,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Active Filter Tags
            if (_isFilterActive || _searchQuery.isNotEmpty) ...[
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    if (_selectedLocation != 'All')
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: InputChip(
                          avatar: const Icon(Icons.location_on, size: 14, color: AppColors.primary),
                          label: Text(_selectedLocation, style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600)),
                          onDeleted: () => setState(() => _selectedLocation = 'All'),
                          deleteIconColor: AppColors.primary,
                          backgroundColor: AppColors.primary.withOpacity(0.08),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          side: BorderSide(color: AppColors.primary.withOpacity(0.3)),
                        ),
                      ),
                    if (_sortBy != 'default')
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: InputChip(
                          avatar: const Icon(Icons.sort, size: 14, color: AppColors.primary),
                          label: Text(
                            _sortBy == 'name_asc' ? 'Name: A-Z' : 'Name: Z-A',
                            style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                          onDeleted: () => setState(() => _sortBy = 'default'),
                          deleteIconColor: AppColors.primary,
                          backgroundColor: AppColors.primary.withOpacity(0.08),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          side: BorderSide(color: AppColors.primary.withOpacity(0.3)),
                        ),
                      ),
                    if (_searchQuery.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: InputChip(
                          avatar: const Icon(Icons.search, size: 14, color: AppColors.primary),
                          label: Text('Search: "$_searchQuery"', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600)),
                          onDeleted: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                          deleteIconColor: AppColors.primary,
                          backgroundColor: AppColors.primary.withOpacity(0.08),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          side: BorderSide(color: AppColors.primary.withOpacity(0.3)),
                        ),
                      ),
                    TextButton(
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                          _selectedLocation = 'All';
                          _sortBy = 'default';
                        });
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Clear all',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
                        'Available Shops (${finalShops.length})',
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

            // Shop Grid with 3D Scroll Effect or Empty State
            if (finalShops.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
                margin: const EdgeInsets.only(top: 16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.outlineVariant.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: AppColors.surfaceContainerHigh,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.search_off, size: 40, color: AppColors.onSurfaceVariant),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No shops found',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'No suppliers match your search or filter criteria.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                          _selectedLocation = 'All';
                          _sortBy = 'default';
                        });
                      },
                      icon: const Icon(Icons.refresh, size: 16),
                      label: const Text('Reset Filters'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.onPrimary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.75, // Adjust based on card height
                ),
                itemCount: finalShops.length,
                itemBuilder: (context, index) {
                  final shop = finalShops[index];
                
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
      },
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
