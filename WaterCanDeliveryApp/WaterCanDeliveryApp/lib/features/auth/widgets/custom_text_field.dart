import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String hintText;
  final IconData? prefixIcon;
  final Widget? prefixWidget;
  final IconData? suffixIcon;
  final Widget? suffixWidget;
  final bool obscureText;
  final VoidCallback? onSuffixIconTap;
  final String? errorText;
  final int maxLines;
  final TextEditingController? controller;

  const CustomTextField({
    super.key,
    required this.label,
    required this.hintText,
    this.prefixIcon,
    this.prefixWidget,
    this.suffixIcon,
    this.suffixWidget,
    this.obscureText = false,
    this.onSuffixIconTap,
    this.errorText,
    this.maxLines = 1,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            height: 18 / 13,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 4), // space-2xs
        Container(
          height: maxLines > 1 ? null : 52, // auto height if multiline
          constraints: maxLines > 1 ? const BoxConstraints(minHeight: 52) : null,
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            maxLines: maxLines,
            obscureText: obscureText,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.onSurface,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.outline,
              ),
              prefixIcon: prefixWidget ??
                  (prefixIcon != null
                      ? Icon(
                          prefixIcon,
                          size: 20,
                          color: AppColors.onSurfaceVariant,
                        )
                      : null),
              suffixIcon: suffixWidget ??
                  (suffixIcon != null
                      ? IconButton(
                          icon: Icon(
                            suffixIcon,
                            size: 22,
                            color: AppColors.onSurfaceVariant,
                          ),
                          onPressed: onSuffixIconTap,
                          splashRadius: 24,
                        )
                      : null),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                vertical: maxLines > 1 ? 12 : 16, 
                horizontal: (prefixIcon == null && prefixWidget == null) ? 16 : 0
              ),
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.info_outline, size: 16, color: AppColors.tertiary),
              const SizedBox(width: 4),
              Text(
                errorText!,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: AppColors.tertiary,
                ),
              ),
            ],
          ),
        ]
      ],
    );
  }
}
