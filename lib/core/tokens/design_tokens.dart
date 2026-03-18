import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─────────────────────────────────────────────
// COLORS
// ─────────────────────────────────────────────
class AppColors {
  AppColors._();

  // Backgrounds
  static const Color backgroundPrimary = Color(0xFFFFFFFF);
  static const Color backgroundSecondary = Color(0xFFF7F7F5);
  static const Color backgroundElevated = Color(0xFFF0EFEB);
  static const Color backgroundInput = Color(0xFFF5F5F3);

  // Surface & Borders
  static const Color surface = Color(0xFFEDEDE9);
  static const Color borderSubtle = Color(0xFFE8E8E4);
  static const Color borderDefault = Color(0xFFD4D4CE);

  // Text
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6B6B6B);
  static const Color textDisabled = Color(0xFFADADAD);
  static const Color textPlaceholder = Color(0xFFADADAD);

  // Accent
  static const Color accentPrimary = Color(0xFF1A1A1A);
  static const Color accentInteractive = Color(0xFFE8572A);
  static const Color accentDestructive = Color(0xFFD93025);
  static const Color accentWarning = Color(0xFFE67E00);
  static const Color accentSuccess = Color(0xFF1A7A4A);

  // Overlay
  static const Color overlay = Color(0x991A1A1A); // rgba(26,26,26,0.6)

  // Turn indicators
  static const Color turnActiveIndicator = Color(0xFFE8572A);
  static const Color turnWaitingIndicator = Color(0xFFD4D4CE);

  // Bubbles
  static const Color bubbleSent = Color(0xFF1A1A1A);
  static const Color bubbleSentText = Color(0xFFFFFFFF);
  static const Color bubbleReceived = Color(0xFFF0EFEB);
  static const Color bubbleReceivedText = Color(0xFF1A1A1A);
  static const Color bubbleReceivedBorder = Color(0xFFE8E8E4);
}

// ─────────────────────────────────────────────
// TYPOGRAPHY
// ─────────────────────────────────────────────
class AppTextStyles {
  AppTextStyles._();

  static TextStyle get displayStyle => GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 1.25,
        letterSpacing: -0.5,
        color: AppColors.textPrimary,
      );

  static TextStyle get headingLarge => GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 1.33,
        letterSpacing: -0.3,
        color: AppColors.textPrimary,
      );

  static TextStyle get headingMedium => GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.4,
        letterSpacing: -0.2,
        color: AppColors.textPrimary,
      );

  static TextStyle get headingSmall => GoogleFonts.inter(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        height: 1.41,
        letterSpacing: 0,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodyLarge => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
        letterSpacing: 0,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodyMedium => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        height: 1.47,
        letterSpacing: 0,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodySmall => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        height: 1.38,
        letterSpacing: 0.1,
        color: AppColors.textPrimary,
      );

  static TextStyle get caption => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        height: 1.45,
        letterSpacing: 0.3,
        color: AppColors.textPrimary,
      );

  static TextStyle get monoPin => const TextStyle(
        fontFamily: 'monospace',
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: 6,
        color: AppColors.textPrimary,
      );
}

// ─────────────────────────────────────────────
// SPACING (8px base grid)
// ─────────────────────────────────────────────
class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double huge = 40;
  static const double massive = 48;
  static const double giant = 64;
}

// ─────────────────────────────────────────────
// BORDER RADIUS
// ─────────────────────────────────────────────
class AppRadius {
  AppRadius._();

  static const double small = 8;
  static const double medium = 12;
  static const double large = 16;
  static const double xlarge = 24;
  static const double full = 9999;

  static BorderRadius get smallRadius => BorderRadius.circular(small);
  static BorderRadius get mediumRadius => BorderRadius.circular(medium);
  static BorderRadius get largeRadius => BorderRadius.circular(large);
  static BorderRadius get xlargeRadius => BorderRadius.circular(xlarge);
  static BorderRadius get fullRadius => BorderRadius.circular(full);
}

// ─────────────────────────────────────────────
// SHADOWS
// ─────────────────────────────────────────────
class AppShadows {
  AppShadows._();

  static const List<BoxShadow> low = [
    BoxShadow(
      color: Color(0x0F000000), // rgba(0,0,0,0.06)
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> medium = [
    BoxShadow(
      color: Color(0x1A000000), // rgba(0,0,0,0.10)
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> high = [
    BoxShadow(
      color: Color(0x29000000), // rgba(0,0,0,0.16)
      blurRadius: 32,
      offset: Offset(0, 8),
    ),
  ];
}

// ─────────────────────────────────────────────
// ANIMATION DURATIONS
// ─────────────────────────────────────────────
class AppDurations {
  AppDurations._();

  static const Duration micro = Duration(milliseconds: 150);
  static const Duration standard = Duration(milliseconds: 300);
  static const Duration enter = Duration(milliseconds: 200);
  static const Duration springSlideUp = Duration(milliseconds: 300);
}

class AppCurves {
  AppCurves._();

  static const Curve micro = Curves.easeOut;
  static const Curve standard = Curves.easeInOut;
  static const Curve enter = Curves.easeOut;
  static const Curve springSlideUp = Cubic(0.16, 1.0, 0.3, 1.0);
}

// ─────────────────────────────────────────────
// TAP TARGET SIZE
// ─────────────────────────────────────────────
class AppTapTargets {
  AppTapTargets._();

  static const double minimum = 48;
}
