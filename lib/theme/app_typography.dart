import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Poppins for Latin UI; Noto Sans families for regional scripts.
abstract final class AppTypography {
  static TextStyle poppins({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w400,
    Color color = AppColors.subtitle,
    double height = 1.35,
    double? letterSpacing,
  }) {
    return GoogleFonts.poppins(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle heading({double fontSize = 22}) {
    return poppins(
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
      color: AppColors.primary,
      height: 1.25,
    );
  }

  static TextStyle subtitle({double fontSize = 14}) {
    return poppins(
      fontSize: fontSize,
      fontWeight: FontWeight.w400,
      color: AppColors.subtitle,
    );
  }

  static TextStyle body({double fontSize = 14}) {
    return poppins(
      fontSize: fontSize,
      fontWeight: FontWeight.w400,
      color: AppColors.textPrimary,
    );
  }

  static TextStyle button() {
    return poppins(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: AppColors.onPrimary,
      height: 1.2,
    );
  }

  static TextStyle forLanguageScript(
    String languageCode, {
    double fontSize = 15,
    FontWeight fontWeight = FontWeight.w500,
    Color color = AppColors.subtitle,
  }) {
    switch (languageCode) {
      case 'hi':
      case 'mr':
        return GoogleFonts.notoSansDevanagari(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
        );
      case 'gu':
        return GoogleFonts.notoSansGujarati(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
        );
      case 'ta':
        return GoogleFonts.notoSansTamil(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
        );
      case 'te':
        return GoogleFonts.notoSansTelugu(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
        );
      case 'kn':
        return GoogleFonts.notoSansKannada(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
        );
      case 'bn':
        return GoogleFonts.notoSansBengali(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
        );
      default:
        return poppins(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
        );
    }
  }
}
