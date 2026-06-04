import 'package:flutter/material.dart';

import 'app_colors.dart';

class DesignSystem {
  DesignSystem._();

  // ═════════════════════ SPACING ═════════════════════
  /// Unified spacing scale for consistent layouts
  static const double spacingXs = 4;
  static const double spacingS = 8;
  static const double spacingM = 12;
  static const double spacingL = 16;
  static const double spacingXl = 20;
  static const double spacingXxl = 24;
  static const double spacingXxxl = 32;

  // Common combinations
  static const EdgeInsets paddingXs =
      EdgeInsets.all(spacingXs);
  static const EdgeInsets paddingS =
      EdgeInsets.all(spacingS);
  static const EdgeInsets paddingM =
      EdgeInsets.all(spacingM);
  static const EdgeInsets paddingL =
      EdgeInsets.all(spacingL);
  static const EdgeInsets paddingXl =
      EdgeInsets.all(spacingXl);
  static const EdgeInsets paddingXxl =
      EdgeInsets.all(spacingXxl);

  static const EdgeInsets paddingHorizontalM =
      EdgeInsets.symmetric(horizontal: spacingM);
  static const EdgeInsets paddingHorizontalL =
      EdgeInsets.symmetric(horizontal: spacingL);
  static const EdgeInsets paddingVerticalM =
      EdgeInsets.symmetric(vertical: spacingM);
  static const EdgeInsets paddingVerticalL =
      EdgeInsets.symmetric(vertical: spacingL);

  // ═════════════════════ BORDER RADIUS ═════════════════════
  static const double cornerRadiusXs = 4;
  static const double cornerRadiusS = 8;
  static const double cornerRadiusM = 12;
  static const double cornerRadiusL = 14;
  static const double cornerRadiusXl = 16;
  static const double cornerRadiusXxl = 18;
  static const double cornerRadiusCircle = 24;

  static const BorderRadius radiusXs =
      BorderRadius.all(Radius.circular(cornerRadiusXs));
  static const BorderRadius radiusS =
      BorderRadius.all(Radius.circular(cornerRadiusS));
  static const BorderRadius radiusM =
      BorderRadius.all(Radius.circular(cornerRadiusM));
  static const BorderRadius radiusL =
      BorderRadius.all(Radius.circular(cornerRadiusL));
  static const BorderRadius radiusXl =
      BorderRadius.all(Radius.circular(cornerRadiusXl));
  static const BorderRadius radiusXxl =
      BorderRadius.all(Radius.circular(cornerRadiusXxl));

  // ═════════════════════ SHADOWS ═════════════════════
  static final BoxShadow shadowXs = BoxShadow(
    color: Colors.black.withAlpha(6),
    blurRadius: 4,
    offset: const Offset(0, 2),
  );

  static final BoxShadow shadowS = BoxShadow(
    color: Colors.black.withAlpha(8),
    blurRadius: 8,
    offset: const Offset(0, 4),
  );

  static final BoxShadow shadowM = BoxShadow(
    color: Colors.black.withAlpha(10),
    blurRadius: 12,
    offset: const Offset(0, 6),
  );

  static final BoxShadow shadowL = BoxShadow(
    color: Colors.black.withAlpha(12),
    blurRadius: 16,
    offset: const Offset(0, 8),
  );

  static final BoxShadow shadowXl = BoxShadow(
    color: Colors.black.withAlpha(14),
    blurRadius: 24,
    offset: const Offset(0, 12),
  );

  // Shadow combinations
  static final List<BoxShadow> shadowsXs = [shadowXs];
  static final List<BoxShadow> shadowsS = [shadowS];
  static final List<BoxShadow> shadowsM = [shadowM];
  static final List<BoxShadow> shadowsL = [shadowL];
  static final List<BoxShadow> shadowsXl = [shadowXl];

  static final BoxShadow shadowXsDark = shadowXs;
  static final BoxShadow shadowSDark = shadowS;
  static final BoxShadow shadowMDark = shadowM;
  static final BoxShadow shadowLDark = shadowL;
  static final List<BoxShadow> shadowsDarkM = shadowsM;
  static final List<BoxShadow> shadowsDarkL = shadowsL;

  // ═════════════════════ CARD STYLING ═════════════════════
  static BoxDecoration cardDecorationLight({
    bool hasBorder = false,
  }) {
    return BoxDecoration(
      color: AppColors.cardSurface,
      borderRadius: radiusXl,
      border: hasBorder
          ? Border.all(color: AppColors.borderLight)
          : null,
      boxShadow: shadowsS,
    );
  }

  static BoxDecoration cardDecorationDark({
    bool hasBorder = false,
  }) {
    return cardDecorationLight(hasBorder: hasBorder);
  }

  // ═════════════════════ BUTTON STYLING ═════════════════════
  /// Standard button padding and sizing
  static const EdgeInsets buttonPaddingS =
      EdgeInsets.symmetric(horizontal: 16, vertical: 8);
  static const EdgeInsets buttonPaddingM =
      EdgeInsets.symmetric(horizontal: 24, vertical: 12);
  static const EdgeInsets buttonPaddingL =
      EdgeInsets.symmetric(horizontal: 32, vertical: 14);
  static const EdgeInsets buttonPaddingXl =
      EdgeInsets.symmetric(horizontal: 40, vertical: 16);

  static const double buttonHeightS = 36;
  static const double buttonHeightM = 44;
  static const double buttonHeightL = 48;

  // Icon button sizing
  static const double iconButtonSizeS = 32;
  static const double iconButtonSizeM = 40;
  static const double iconButtonSizeL = 48;

  // ═════════════════════ BORDER STYLING ═════════════════════
  static const BorderSide borderLight =
      BorderSide(color: AppColors.borderLight, width: 1);
  static const BorderSide borderLightThick =
      BorderSide(color: AppColors.border, width: 1);
  static const BorderSide borderDark = borderLight;
  static const BorderSide borderDarkThick = borderLightThick;

  // ═════════════════════ ICON SIZES ═════════════════════
  static const double iconSizeXs = 16;
  static const double iconSizeS = 18;
  static const double iconSizeM = 24;
  static const double iconSizeL = 32;
  static const double iconSizeXl = 40;

  // ═════════════════════ ANIMATION DURATION ═════════════════════
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);

  // ═════════════════════ HELPER METHODS ═════════════════════
  static List<BoxShadow> getShadows(
    Brightness brightness, {
    required double elevation,
  }) {
    if (elevation <= 4) {
      return shadowsXs;
    } else if (elevation <= 8) {
      return shadowsS;
    } else if (elevation <= 12) {
      return shadowsM;
    } else if (elevation <= 16) {
      return shadowsL;
    } else {
      return shadowsXl;
    }
  }

  static BoxDecoration getCardDecoration(
    Brightness brightness, {
    bool hasBorder = false,
  }) {
    return cardDecorationLight(hasBorder: hasBorder);
  }
}

/// Responsive spacing helper
class ResponsiveSpacing {
  final BuildContext context;

  ResponsiveSpacing(this.context);

  /// Get screen width
  double get screenWidth => MediaQuery.of(context).size.width;

  /// Get screen height
  double get screenHeight => MediaQuery.of(context).size.height;

  /// Check if device is mobile (< 600px)
  bool get isMobile => screenWidth < 600;

  /// Check if device is tablet (>= 600px)
  bool get isTablet => screenWidth >= 600;

  /// Get responsive padding
  EdgeInsets getResponsivePadding({
    double mobileValue = 16,
    double tabletValue = 24,
  }) {
    return EdgeInsets.all(isMobile ? mobileValue : tabletValue);
  }

  double getResponsiveFontSize({
    double baseMobileSize = 14,
    double baseTabletSize = 16,
  }) {
    return isMobile ? baseMobileSize : baseTabletSize;
  }

  /// Get responsive spacing value
  double getResponsiveSpacing({
    double mobileValue = 16,
    double tabletValue = 24,
  }) {
    return isMobile ? mobileValue : tabletValue;
  }
}
