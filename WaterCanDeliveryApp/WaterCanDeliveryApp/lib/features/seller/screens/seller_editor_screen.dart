import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dotted_border/dotted_border.dart';
import '../../../core/constants/app_colors.dart';

class SellerEditorScreen extends StatefulWidget {
  const SellerEditorScreen({super.key});

  @override
  State<SellerEditorScreen> createState() => _SellerEditorScreenState();
}

class _SellerEditorScreenState extends State<SellerEditorScreen> {
  int? _editingIndex;
  final TextEditingController _priceEditController = TextEditingController();

  @override
  void dispose() {
    _priceEditController.dispose();
    super.dispose();
  }

  final List<Map<String, dynamic>> _mockProducts = [
    {
      'title': '25L CAN',
      'capacity': '25 Litres',
      'price': '90',
      'available': true,
      'image': 'https://lh3.googleusercontent.com/aida-public/AB6AXuCwb6zcvdSGBERLAc1JVr4yN8aKUjtxJtTofmLSaEaCwgkMj2RQ74Rl_WYynPM4hx4xrrKfsL8EPas9_bnmBkst3SHWG2V1ZRmzBOjsvZmUlH4q-XYYdWRKDySQ7Dub7bKTYM5yxwCVZzlpoawYgTFAqfCrk71o30y7481nYSo01g4I8xBaGCXbMG0T9GqK-tZlezhQEMwQ_2id5pCiJN5xWbE3pujE1gr0puAWKg2NPylg9gnRFTfYmA',
    },
    {
      'title': '35L CAN',
      'capacity': '35 Litres',
      'price': '130',
      'available': true,
      'image': 'https://lh3.googleusercontent.com/aida-public/AB6AXuCwb6zcvdSGBERLAc1JVr4yN8aKUjtxJtTofmLSaEaCwgkMj2RQ74Rl_WYynPM4hx4xrrKfsL8EPas9_bnmBkst3SHWG2V1ZRmzBOjsvZmUlH4q-XYYdWRKDySQ7Dub7bKTYM5yxwCVZzlpoawYgTFAqfCrk71o30y7481nYSo01g4I8xBaGCXbMG0T9GqK-tZlezhQEMwQ_2id5pCiJN5xWbE3pujE1gr0puAWKg2NPylg9gnRFTfYmA',
    },
    {
      'title': '20L CAN',
      'capacity': '20 Litres',
      'price': '80',
      'available': true,
      'image': 'https://lh3.googleusercontent.com/aida-public/AB6AXuCwb6zcvdSGBERLAc1JVr4yN8aKUjtxJtTofmLSaEaCwgkMj2RQ74Rl_WYynPM4hx4xrrKfsL8EPas9_bnmBkst3SHWG2V1ZRmzBOjsvZmUlH4q-XYYdWRKDySQ7Dub7bKTYM5yxwCVZzlpoawYgTFAqfCrk71o30y7481nYSo01g4I8xBaGCXbMG0T9GqK-tZlezhQEMwQ_2id5pCiJN5xWbE3pujE1gr0puAWKg2NPylg9gnRFTfYmA',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: SafeArea(
        child: Container(
          color: const Color(0xFFFFFAF5),
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  children: [
                    _buildSubheading(),
                    const SizedBox(height: 12),
                    ...List.generate(_mockProducts.length, (index) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _buildProductCard(index),
                    )),
                    const SizedBox(height: 8),
                    _buildAddProductButton(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Row(
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
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const Icon(Icons.arrow_back, size: 20, color: Colors.black87),
            ),
          ),
          const SizedBox(width: 16),
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [AppColors.seller700, AppColors.seller400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds),
            child: Text(
              'EDIT PRODUCTS',
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
    );
  }

  Widget _buildSubheading() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'AVAILABLE PRODUCTS',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: Colors.grey.shade800,
              letterSpacing: 0.5,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.grey.shade200.withOpacity(0.6),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '${_mockProducts.length} Items',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(int index) {
    final product = _mockProducts[index];
    final isEditing = _editingIndex == index;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade900, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Image Container
          Container(
            width: 80,
            height: 80,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Image.network(
              product['image'],
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.water_drop, color: Colors.blue),
            ),
          ),
          const SizedBox(width: 14),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      product['title'],
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Colors.grey.shade900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    if (product['available'] == true)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          border: Border.all(color: Colors.green.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: Colors.green.shade500,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Available',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.green.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Capacity: ${product['capacity']}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: Colors.grey.shade100)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          if (isEditing)
                            SizedBox(
                              width: 60,
                              child: TextField(
                                controller: _priceEditController,
                                keyboardType: TextInputType.number,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.grey.shade900,
                                ),
                                decoration: InputDecoration(
                                  prefixText: '₹ ',
                                  prefixStyle: GoogleFonts.plusJakartaSans(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.grey.shade900,
                                  ),
                                  isDense: true,
                                  contentPadding: const EdgeInsets.only(bottom: 4),
                                ),
                              ),
                            )
                          else
                            Text(
                              '₹ ${product['price']}',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: Colors.grey.shade900,
                              ),
                            ),
                          const SizedBox(width: 4),
                          Text(
                            '/ can',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (isEditing) {
                            setState(() {
                              _mockProducts[index]['price'] = _priceEditController.text;
                              _editingIndex = null;
                            });
                          } else {
                            setState(() {
                              _editingIndex = index;
                              _priceEditController.text = product['price'].toString();
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isEditing ? Colors.green.shade600 : AppColors.seller500,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                          minimumSize: const Size(0, 32),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          isEditing ? 'SAVE' : 'EDIT',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddProductButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: InkWell(
        onTap: () {
          _showAddProductDialog();
        },
        borderRadius: BorderRadius.circular(16),
        child: DottedBorder(
          options: const RoundedRectDottedBorderOptions(
            color: AppColors.seller500,
            strokeWidth: 2,
            dashPattern: [8, 4],
            radius: Radius.circular(16),
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.seller500,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.seller500.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 20),
                ),
                const SizedBox(height: 6),
                Text(
                  'ADD NEW PRODUCT',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: AppColors.seller500,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddProductDialog() {
    final capacityController = TextEditingController();
    final priceController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'ADD NEW PRODUCT',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppColors.seller600,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: capacityController,
                decoration: InputDecoration(
                  labelText: 'Capacity (e.g., 10L)',
                  labelStyle: GoogleFonts.plusJakartaSans(fontSize: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Price (₹)',
                  labelStyle: GoogleFonts.plusJakartaSans(fontSize: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'CANCEL',
                style: GoogleFonts.plusJakartaSans(color: Colors.grey.shade600, fontWeight: FontWeight.bold),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (capacityController.text.isNotEmpty && priceController.text.isNotEmpty) {
                  setState(() {
                    _mockProducts.add({
                      'title': '${capacityController.text.toUpperCase()} CAN',
                      'capacity': '${capacityController.text} Litres',
                      'price': priceController.text,
                      'available': true,
                      'image': 'https://lh3.googleusercontent.com/aida-public/AB6AXuCwb6zcvdSGBERLAc1JVr4yN8aKUjtxJtTofmLSaEaCwgkMj2RQ74Rl_WYynPM4hx4xrrKfsL8EPas9_bnmBkst3SHWG2V1ZRmzBOjsvZmUlH4q-XYYdWRKDySQ7Dub7bKTYM5yxwCVZzlpoawYgTFAqfCrk71o30y7481nYSo01g4I8xBaGCXbMG0T9GqK-tZlezhQEMwQ_2id5pCiJN5xWbE3pujE1gr0puAWKg2NPylg9gnRFTfYmA',
                    });
                  });
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.seller500,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text('ADD PRODUCT', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}
