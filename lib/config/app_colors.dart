import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Primary Background ──
  static const Color background = Color(0xFFFDF8F1);
  static const Color backgroundLight = Color(0xFFF7F7F4);
  static const Color shellOverlay = Color(0xFFF8F4EE);
  static const Color tiffanyMist = Color(0xFFEAFBFA);
  static const Color faluMist = Color(0xFFF8E5E5);

  // ── Black & Dark Grays ──
  static const Color black = Color(0xFF000000);
  static const Color blackPrimary = Color(0xFF1A1A1A);
  static const Color blackSecondary = Color(0xFF111111);
  static const Color blackTertiary = Color(0xFF222222);
  static const Color blackGlass = Color(0x33000000);

  // ── Tiffany Blue — Primary Accent ──
  static const Color tiffanyBlue = Color(0xFF0ABAB5);
  static const Color tiffanyBlueLight = Color(0xFF8DE8E5);
  static const Color tiffanyBlueDark = Color(0xFF088F8B);
  static const Color tiffanyBlueGlow = Color(0xFF00E5DF);
  static const Color tiffanyBlueMuted = Color(0xFF5DD3D0);

  // ── Falu Red — Secondary Accent ──
  static const Color faluRed = Color(0xFF801818);
  static const Color faluRedLight = Color(0xFFA63030);
  static const Color faluRedDark = Color(0xFF5C0E0E);
  static const Color faluRedGlow = Color(0xFFBF2424);
  static const Color faluRedMuted = Color(0xFFC06060);

  // ── Gold — Tertiary Accent ──
  static const Color gold = Color(0xFFD4AF37);
  static const Color goldLight = Color(0xFFF3E5AB);
  static const Color goldDark = Color(0xFF996515);
  static const Color goldGlow = Color(0xFFFFD700);
  static const Color goldString = Color(0xFFE2C15A);

  // ── Legacy Alias (so widgets referencing actionRed still compile) ──
  static const Color actionRed = faluRed;
  static const Color actionRedLight = faluRedLight;
  static const Color redAccent = faluRedGlow;
  static const Color redBright = Color(0xFFD02020);

  // ── Cards & Surfaces ──
  static const Color cardBg = Color(0xFFFDFDFD);
  static const Color surface = Color(0xFFF5F5F7);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE0E0E0);

  // ── Text ──
  static const Color textPrimary = Color(0xFF121212);
  static const Color textSecondary = Color(0xFF4A4A4A);
  static const Color textMuted = Color(0xFF9E9E9E);

  // ── Status ──
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFF57C00);
  static const Color info = Color(0xFF1976D2);
  static const Color loadingRed = faluRedLight;
  static const Color loadingGreen = Color(0xFF2E8B57);

  // ── Crypto / Chart ──
  static const Color chartPositive = Color(0xFF00D084);
  static const Color chartNegative = Color(0xFFFF4444);
  static const Color gridLine = Color(0xFFE8E8E8);

  // ═══════════════  GRADIENTS  ═══════════════

  // Primary — Tiffany Blue
  static const LinearGradient tiffanyGradient = LinearGradient(
    colors: [tiffanyBlueDark, tiffanyBlue, tiffanyBlueLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient tiffanyFaluSplitGradient = LinearGradient(
    colors: [
      Color(0xFFBFF4F2),
      tiffanyBlueLight,
      tiffanyBlue,
      faluRed,
      faluRedLight,
      Color(0xFFC04242),
    ],
    stops: [0.0, 0.30, 0.49, 0.51, 0.72, 1.0],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient faluTopBarGradient = LinearGradient(
    colors: [faluRedDark, faluRed, faluRedLight],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // Secondary — Falu Red
  static const LinearGradient faluRedGradient = LinearGradient(
    colors: [faluRedDark, faluRed, faluRedLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Tertiary — Gold (kept for subtle accents)
  static const LinearGradient goldGradient = LinearGradient(
    colors: [goldDark, gold, goldLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Nzelu identity gradient  (tiffany → falu → gold shimmer)
  static const LinearGradient nzeluGradient = LinearGradient(
    colors: [tiffanyBlueDark, tiffanyBlue, faluRed, gold],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Light page background gradient
  static const LinearGradient lightGradient = LinearGradient(
    colors: [background, shellOverlay],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFF8F8F8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Red gradient — now uses Falu Red
  static const LinearGradient redGradient = LinearGradient(
    colors: [faluRedDark, faluRed],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Dark crypto-style gradient
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

  // Glass effects
  static const LinearGradient glassGradient = LinearGradient(
    colors: [
      Color(0xCCFFFFFF),
      Color(0x66FFFFFF),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient tiffanyGlassGradient = LinearGradient(
    colors: [
      Color(0x550ABAB5),
      Color(0x330ABAB5),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGlassGradient = LinearGradient(
    colors: [
      Color(0xDDAF3780),
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
    colors: [faluRedDark, faluRed, faluRedGlow],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
