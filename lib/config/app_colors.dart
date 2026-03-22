import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Background — Pure White
  static const Color background = Color(0xFFFFFFFF);
  static const Color backgroundLight = Color(0xFFFAFAFA);

  // Black & Dark Grays (Reduced usage)
  static const Color black = Color(0xFF000000);
  static const Color blackPrimary = Color(0xFF1A1A1A);
  static const Color blackSecondary = Color(0xFF111111);
  static const Color blackTertiary = Color(0xFF222222);
  static const Color blackGlass = Color(0x33000000); // Transparent black for glass overlay

  // Premium Gold (5%)
  static const Color gold = Color(0xFFD4AF37);
  static const Color goldLight = Color(0xFFF3E5AB);
  static const Color goldDark = Color(0xFF996515);
  static const Color goldGlow = Color(0xFFFFD700);

  // Action Red (10%)
  static const Color actionRed = Color(0xFFFF0000);
  static const Color actionRedLight = Color(0xFFFF4D4D);
  static const Color redAccent = Color(0xFFFF3333);
  static const Color redBright = Color(0xFFFF0000);

  // Secondary Light Gray — cards & panels
  static const Color cardBg = Color(0xFFFDFDFD);
  static const Color surface = Color(0xFFF5F5F7);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE0E0E0);

  // Text — Dark for Light theme
  static const Color textPrimary = Color(0xFF121212);
  static const Color textSecondary = Color(0xFF4A4A4A);
  static const Color textMuted = Color(0xFF9E9E9E);

  // Status
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFF57C00);
  static const Color info = Color(0xFF1976D2);

  // Crypto Chart Colors
  static const Color chartPositive = Color(0xFF00D084);
  static const Color chartNegative = Color(0xFFFF4444);
  static const Color gridLine = Color(0xFFE8E8E8);

  // Gradients
  static const LinearGradient goldGradient = LinearGradient(
    colors: [goldDark, gold, goldLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient lightGradient = LinearGradient(
    colors: [background, Color(0xFFF0F0F0)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFF8F8F8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient redGradient = LinearGradient(
    colors: [Color(0xFFC1121F), Color(0xFFB00020)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Futuristic Crypto Gradients
  static const LinearGradient cryptoGradient = LinearGradient(
    colors: [blackSecondary, black, blackTertiary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cryptoCardGradient = LinearGradient(
    colors: [background, Color(0xFFFDFDFD), Color(0xFFF9F9F9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient glassGradient = LinearGradient(
    colors: [
      Color(0xCCFFFFFF), // White with 80% opacity
      Color(0x66FFFFFF), // White with 40% opacity
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGlassGradient = LinearGradient(
    colors: [
      Color(0xDDAF3780), // Gold with transparency
      Color(0xAAAF3740),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldCryptoGradient = LinearGradient(
    colors: [goldDark, goldLight, goldGlow],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient redCryptoGradient = LinearGradient(
    colors: [actionRed, redAccent, redBright],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
