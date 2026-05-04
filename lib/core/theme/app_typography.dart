import 'package:flutter/material.dart';
import 'package:a_milk_filter/core/theme/app_colors.dart';

/// Typography system using Courier-family monospace throughout.
/// This is a deliberate aesthetic constraint — the app's identity is
/// inseparable from monospace rendering at every hierarchy level.
abstract final class AppTypography {
  static const String _mono = 'Courier New';

  static TextTheme get textTheme => const TextTheme(
    displayLarge: TextStyle(
      fontFamily: _mono, fontSize: 32, fontWeight: FontWeight.w900,
      letterSpacing: -0.5, color: AppColors.chalk, height: 1.0,
    ),
    displayMedium: TextStyle(
      fontFamily: _mono, fontSize: 26, fontWeight: FontWeight.w900,
      letterSpacing: -0.3, color: AppColors.chalk, height: 1.1,
    ),
    displaySmall: TextStyle(
      fontFamily: _mono, fontSize: 22, fontWeight: FontWeight.w700,
      color: AppColors.chalk, height: 1.2,
    ),
    headlineLarge: TextStyle(
      fontFamily: _mono, fontSize: 18, fontWeight: FontWeight.w700,
      letterSpacing: 0.1, color: AppColors.chalk,
    ),
    headlineMedium: TextStyle(
      fontFamily: _mono, fontSize: 16, fontWeight: FontWeight.w700,
      color: AppColors.chalk,
    ),
    headlineSmall: TextStyle(
      fontFamily: _mono, fontSize: 14, fontWeight: FontWeight.w700,
      color: AppColors.chalk,
    ),
    titleLarge: TextStyle(
      fontFamily: _mono, fontSize: 13, fontWeight: FontWeight.w700,
      letterSpacing: 0.3, color: AppColors.chalk,
    ),
    titleMedium: TextStyle(
      fontFamily: _mono, fontSize: 12, fontWeight: FontWeight.w600,
      letterSpacing: 0.3, color: AppColors.dust,
    ),
    titleSmall: TextStyle(
      fontFamily: _mono, fontSize: 10, fontWeight: FontWeight.w700,
      letterSpacing: 0.5, color: AppColors.dust,
    ),
    bodyLarge: TextStyle(
      fontFamily: _mono, fontSize: 13, fontWeight: FontWeight.w400,
      color: AppColors.chalk, height: 1.5,
    ),
    bodyMedium: TextStyle(
      fontFamily: _mono, fontSize: 12, fontWeight: FontWeight.w400,
      color: AppColors.dust, height: 1.5,
    ),
    bodySmall: TextStyle(
      fontFamily: _mono, fontSize: 11, fontWeight: FontWeight.w400,
      color: AppColors.ash, height: 1.5,
    ),
    labelLarge: TextStyle(
      fontFamily: _mono, fontSize: 10, fontWeight: FontWeight.w700,
      letterSpacing: 0.6, color: AppColors.chalk,
    ),
    labelMedium: TextStyle(
      fontFamily: _mono, fontSize: 9, fontWeight: FontWeight.w700,
      letterSpacing: 0.5, color: AppColors.dust,
    ),
    labelSmall: TextStyle(
      fontFamily: _mono, fontSize: 8, fontWeight: FontWeight.w400,
      letterSpacing: 0.4, color: AppColors.ash,
    ),
  );
}
