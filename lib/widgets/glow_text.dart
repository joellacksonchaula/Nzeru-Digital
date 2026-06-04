import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/app_colors.dart';

class GlowText extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color color;
  final FontWeight fontWeight;
  final double glowRadius;

  const GlowText({
    super.key,
    required this.text,
    this.fontSize = 36,
    this.color = AppColors.gold,
    this.fontWeight = FontWeight.w700,
    this.glowRadius = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Glow layer
        Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: fontSize,
            fontWeight: fontWeight,
            color: color.withAlpha(80),
            shadows: [
              Shadow(
                color: color.withAlpha(120),
                blurRadius: glowRadius,
              ),
              Shadow(
                color: color.withAlpha(70),
                blurRadius: glowRadius * 2,
              ),
            ],
          ),
        ),
        // Main text
        Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: fontSize,
            fontWeight: fontWeight,
            color: color,
          ),
        ),
      ],
    );
  }
}
