import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primaryRed = Color(0xFFC21A03);
  static const Color secondaryBlue = Color(0xFF0C6170);
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceSoft = Color(0xFFF7FAFA);
  static const Color cardSurface = Color(0xFFFFFFFF);

  static const Color textPrimary = Color(0xFF151515);
  static const Color textSecondary = Color(0xFF4B5563);
  static const Color textTertiary = Color(0xFF6B7280);
  static const Color textMuted = Color(0xFF9CA3AF);

  static const Color border = Color(0xFFE5E7EB);
  static const Color borderLight = Color(0xFFF1F5F9);

  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = secondaryBlue;
  static const Color error = primaryRed;

  static const Color chartPrimary = primaryRed;
  static const Color chartSecondary = secondaryBlue;
  static const Color chartPositive = success;
  static const Color chartNegative = primaryRed;
  static const Color gridLine = Color(0xFFE5E7EB);

  static const Color lockedState = primaryRed;
  static const Color unlockedState = success;

  static const Color redMist = Color(0xFFFFF1EF);
  static const Color blueMist = Color(0xFFEAF6F7);

  static const LinearGradient flatRedGradient = LinearGradient(
    colors: [primaryRed, primaryRed],
  );
  static const LinearGradient flatBlueGradient = LinearGradient(
    colors: [secondaryBlue, secondaryBlue],
  );
  static const LinearGradient flatSurfaceGradient = LinearGradient(
    colors: [surface, surface],
  );

  // Compatibility aliases for older widgets. They all resolve to the new
  // red, Tiffany blue, and white fintech system.
  static const Color abyssalTeal = secondaryBlue;
  static const Color abyssalTealLight = secondaryBlue;
  static const Color abyssalTealMuted = secondaryBlue;
  static const Color crimsonBurgundy = primaryRed;
  static const Color crimsonBurgundyLight = primaryRed;
  static const Color crimsonBurgundyMuted = primaryRed;
  static const Color brightCrimson = primaryRed;
  static const Color brightCrimsonLight = primaryRed;
  static const Color brightCrimsonMuted = primaryRed;
  static const Color backgroundLight = background;
  static const Color shellOverlay = surfaceSoft;
  static const Color surfaceMist = blueMist;
  static const Color darkBackground = background;
  static const Color darkSurface = surface;
  static const Color darkSurfaceAlt = surfaceSoft;
  static const Color darkCardBg = cardSurface;
  static const Color black = textPrimary;
  static const Color blackPrimary = textPrimary;
  static const Color blackSecondary = textPrimary;
  static const Color blackTertiary = textSecondary;
  static const Color blackGlass = Color(0x14000000);
  static const Color darkTextPrimary = textPrimary;
  static const Color darkTextSecondary = textSecondary;
  static const Color darkTextTertiary = textTertiary;
  static const Color darkTextMuted = textMuted;
  static const Color cardBg = cardSurface;
  static const Color surfaceLight = surface;
  static const Color darkBorder = border;
  static const Color darkBorderLight = borderLight;
  static const Color darkCardBorder = borderLight;
  static const Color tiffanyBlue = secondaryBlue;
  static const Color tiffanyBlueLight = secondaryBlue;
  static const Color tiffanyBlueDark = secondaryBlue;
  static const Color tiffanyBlueGlow = secondaryBlue;
  static const Color tiffanyBlueMuted = secondaryBlue;
  static const Color tiffanyMist = blueMist;
  static const Color faluRed = primaryRed;
  static const Color faluRedLight = primaryRed;
  static const Color faluRedDark = primaryRed;
  static const Color faluRedGlow = primaryRed;
  static const Color faluRedMuted = primaryRed;
  static const Color faluMist = redMist;
  static const Color actionRed = primaryRed;
  static const Color actionRedLight = primaryRed;
  static const Color redAccent = primaryRed;
  static const Color redBright = primaryRed;
  static const Color loadingRed = primaryRed;
  static const Color loadingGreen = secondaryBlue;
  static const Color gridLineDark = gridLine;

  static const LinearGradient tealgradient = flatBlueGradient;
  static const LinearGradient crimsonGradient = flatRedGradient;
  static const LinearGradient brightCrimsonGradient = flatRedGradient;
  static const LinearGradient premiumGradient = flatRedGradient;
  static const LinearGradient lightCardGradient = flatSurfaceGradient;
  static const LinearGradient darkCardGradient = flatSurfaceGradient;
  static const LinearGradient glassGradient = flatSurfaceGradient;
  static const LinearGradient darkGlassGradient = flatSurfaceGradient;
  static const LinearGradient tiffanyGradient = flatBlueGradient;
  static const LinearGradient faluTopBarGradient = flatRedGradient;
  static const LinearGradient faluRedGradient = flatRedGradient;
  static const LinearGradient nzeluGradient = flatRedGradient;
  static const LinearGradient lightGradient = flatSurfaceGradient;
  static const LinearGradient cardGradient = flatSurfaceGradient;
  static const LinearGradient redGradient = flatRedGradient;
  static const LinearGradient cryptoGradient = flatSurfaceGradient;
  static const LinearGradient cryptoCardGradient = flatSurfaceGradient;
  static const LinearGradient tiffanyGlassGradient = flatSurfaceGradient;
  static const LinearGradient redCryptoGradient = flatRedGradient;
}
