import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ═══════════════  NZELU PREMIUM COLOR SYSTEM  ═══════════════
  // Abyssal Teal (Primary)
  static const Color abyssalTeal = Color(0xFF063F47);
  static const Color abyssalTealLight = Color(0xFF1B6B78);
  static const Color abyssalTealMuted = Color(0xFF2E7F89);
  
  // Crimson Burgundy (Secondary)
  static const Color crimsonBurgundy = Color(0xFF790D0D);
  static const Color crimsonBurgundyLight = Color(0xFFA91414);
  static const Color crimsonBurgundyMuted = Color(0xFF6B0A0A);
  
  // Bright Crimson (Accent/Call-to-Action)
  static const Color brightCrimson = Color(0xFFC21A03);
  static const Color brightCrimsonLight = Color(0xFFE83F2F);
  static const Color brightCrimsonMuted = Color(0xFFAA1603);

  // ── Light Mode Colors ──
  static const Color background = Color(0xFFFFFFFF); // Pure White
  static const Color backgroundLight = Color(0xFFFAFAFA);
  static const Color shellOverlay = Color(0xFFF5F5F5);
  static const Color surfaceMist = Color(0xFFF0F4F6);
  static const Color cardSurface = Color(0xFFFFFFFF);

  // ── Dark Mode Colors ──
  static const Color darkBackground = Color(0xFF0D0D0D); // Deep Dark Charcoal
  static const Color darkSurface = Color(0xFF1A1A1A);
  static const Color darkSurfaceAlt = Color(0xFF242424);
  static const Color darkCardBg = Color(0xFF181818);

  // ── Black & Dark Grays ──
  static const Color black = Color(0xFF000000);
  static const Color blackPrimary = Color(0xFF1A1A1A);
  static const Color blackSecondary = Color(0xFF111111);
  static const Color blackTertiary = Color(0xFF222222);
  static const Color blackGlass = Color(0x33000000);

  // ── Text Colors - Light Mode ──
  static const Color textPrimary = Color(0xFF000000); // Pure Black
  static const Color textSecondary = Color(0xFF333333); // Dark Gray
  static const Color textTertiary = Color(0xFF666666); // Medium Gray
  static const Color textMuted = Color(0xFF999999); // Light Gray
  
  // ── Text Colors - Dark Mode ──
  static const Color darkTextPrimary = Color(0xFFFFFFFF); // Pure White
  static const Color darkTextSecondary = Color(0xFFCCCCCC); // Light Gray
  static const Color darkTextTertiary = Color(0xFFAAAAAA); // Medium Gray
  static const Color darkTextMuted = Color(0xFF777777); // Dim Gray

  // ── Cards & Borders - Light Mode ──
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFFAFAFA);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE8E8E8);
  static const Color borderLight = Color(0xFFF0F0F0);

  // ── Cards & Borders - Dark Mode ──
  static const Color darkBorder = Color(0xFF333333);
  static const Color darkBorderLight = Color(0xFF262626);
  static const Color darkCardBorder = Color(0xFF2A2A2A);

  // ── Legacy Aliases (for backward compatibility) ──
  static const Color tiffanyBlue = abyssalTeal;
  static const Color tiffanyBlueLight = abyssalTealLight;
  static const Color tiffanyBlueDark = abyssalTeal;
  static const Color tiffanyBlueGlow = abyssalTealLight;
  static const Color tiffanyBlueMuted = abyssalTealMuted;
  
  static const Color faluRed = crimsonBurgundy;
  static const Color faluRedLight = crimsonBurgundyLight;
  static const Color faluRedDark = crimsonBurgundyMuted;
  static const Color faluRedGlow = brightCrimson;
  static const Color faluRedMuted = crimsonBurgundyMuted;
  
  static const Color actionRed = crimsonBurgundy;
  static const Color actionRedLight = crimsonBurgundyLight;
  static const Color redAccent = brightCrimson;
  static const Color redBright = brightCrimson;

  // ── Gold — Tertiary Accent ──
  static const Color gold = Color(0xFFD4AF37);
  static const Color goldLight = Color(0xFFF3E5AB);
  static const Color goldDark = Color(0xFF996515);
  static const Color goldGlow = Color(0xFFFFD700);
  static const Color goldString = Color(0xFFE2C15A);

  // ── Status Colors ──
  static const Color success = Color(0xFF22C55E); // Bright Green
  static const Color warning = Color(0xFFF59E0B); // Amber
  static const Color info = Color(0xFF3B82F6); // Blue
  static const Color error = Color(0xFFEF4444); // Red
  static const Color loadingRed = brightCrimson;
  static const Color loadingGreen = Color(0xFF10B981);

  // ── Chart Colors ──
  static const Color chartPositive = Color(0xFF10B981);
  static const Color chartNegative = Color(0xFFEF4444);
  static const Color gridLine = Color(0xFFE5E7EB);
  static const Color gridLineDark = Color(0xFF374151);

  // ── Withdrawal Lock Colors ──
  static const Color lockedState = Color(0xFFDC2626); // Warning Red
  static const Color unlockedState = Color(0xFF059669); // Success Green

  // ═══════════════  GRADIENTS  ═══════════════

  // Primary — Abyssal Teal
  static const LinearGradient tealgradient = LinearGradient(
    colors: [abyssalTealMuted, abyssalTeal, abyssalTealLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Secondary — Crimson Burgundy
  static const LinearGradient crimsonGradient = LinearGradient(
    colors: [crimsonBurgundyMuted, crimsonBurgundy, crimsonBurgundyLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Accent — Bright Crimson
  static const LinearGradient brightCrimsonGradient = LinearGradient(
    colors: [brightCrimsonMuted, brightCrimson, brightCrimsonLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Nzelu Premium Gradient
  static const LinearGradient premiumGradient = LinearGradient(
    colors: [abyssalTeal, crimsonBurgundy, brightCrimson],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Light Mode Card Gradient
  static const LinearGradient lightCardGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFFAFAFA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Dark Mode Card Gradient
  static const LinearGradient darkCardGradient = LinearGradient(
    colors: [Color(0xFF242424), Color(0xFF1A1A1A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Glass Effect Light
  static const LinearGradient glassGradient = LinearGradient(
    colors: [
      Color(0xE6FFFFFF),
      Color(0x80FFFFFF),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Glass Effect Dark
  static const LinearGradient darkGlassGradient = LinearGradient(
    colors: [
      Color(0x33FFFFFF),
      Color(0x1AFFFFFF),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Legacy gradient aliases
  static const LinearGradient tiffanyGradient = tealgradient;
  static const LinearGradient faluTopBarGradient = crimsonGradient;
  static const LinearGradient faluRedGradient = crimsonGradient;
  static const LinearGradient goldGradient = brightCrimsonGradient;
  static const LinearGradient nzeluGradient = premiumGradient;
  static const LinearGradient lightGradient = lightCardGradient;
  static const LinearGradient cardGradient = lightCardGradient;
  static const LinearGradient redGradient = brightCrimsonGradient;
  static const LinearGradient cryptoGradient = darkCardGradient;
  static const LinearGradient cryptoCardGradient = darkCardGradient;
  static const LinearGradient tiffanyGlassGradient = glassGradient;
  static const LinearGradient goldGlassGradient = glassGradient;
  static const LinearGradient goldCryptoGradient = brightCrimsonGradient;
  static const LinearGradient redCryptoGradient = brightCrimsonGradient;
}
