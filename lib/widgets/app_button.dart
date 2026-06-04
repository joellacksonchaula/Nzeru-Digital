import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../config/app_colors.dart';

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isSecondary;
  final bool isOutlined;
  final double? width;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isSecondary = false,
    this.isOutlined = false,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final fill = isSecondary ? AppColors.secondaryBlue : AppColors.primaryRed;

    return SizedBox(
      width: width,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : icon == null
                ? const SizedBox.shrink()
                : Icon(icon, size: 19),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: isOutlined ? Colors.white : fill,
          foregroundColor: isOutlined ? fill : Colors.white,
          disabledBackgroundColor: fill.withValues(alpha: 0.45),
          disabledForegroundColor: Colors.white,
          elevation: isOutlined ? 0 : 1,
          shadowColor: Colors.black.withValues(alpha: 0.10),
          side: isOutlined ? BorderSide(color: fill) : BorderSide.none,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }
}
