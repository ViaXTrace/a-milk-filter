import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:a_milk_filter/core/theme/app_colors.dart';
import 'package:a_milk_filter/core/theme/app_typography.dart';

abstract final class AppTheme {
  static ThemeData dark() => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      brightness: Brightness.dark,
      primary: AppColors.crimson,
      onPrimary: AppColors.chalk,
      primaryContainer: AppColors.maroon,
      onPrimaryContainer: AppColors.chalk,
      secondary: AppColors.mauve,
      onSecondary: AppColors.chalk,
      secondaryContainer: AppColors.haze,
      onSecondaryContainer: AppColors.chalk,
      surface: AppColors.abyss,
      onSurface: AppColors.chalk,
      surfaceContainerHighest: AppColors.crypt,
      onSurfaceVariant: AppColors.dust,
      outline: AppColors.border,
      outlineVariant: AppColors.divider,
      error: AppColors.error,
      onError: AppColors.chalk,
      shadow: AppColors.shadow,
    ),
    scaffoldBackgroundColor: AppColors.void_,
    textTheme: AppTypography.textTheme,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.abyss,
      elevation: 0,
      scrolledUnderElevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppColors.void_,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      iconTheme: IconThemeData(color: AppColors.chalk, size: 18),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.divider,
      thickness: 1,
      space: 0,
    ),
    iconTheme: const IconThemeData(color: AppColors.chalk, size: 18),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.crimson,
        foregroundColor: AppColors.chalk,
        textStyle: const TextStyle(
          fontFamily: 'Courier New',
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.chalk,
        side: const BorderSide(color: AppColors.border),
        textStyle: const TextStyle(
          fontFamily: 'Courier New',
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
      ),
    ),
    sliderTheme: const SliderThemeData(
      activeTrackColor: AppColors.crimson,
      inactiveTrackColor: AppColors.crypt,
      thumbColor: AppColors.crimson,
      overlayColor: Color(0x18660020),
      trackHeight: 2,
      thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6),
      valueIndicatorColor: AppColors.maroon,
      valueIndicatorTextStyle: TextStyle(
        fontFamily: 'Courier New',
        fontSize: 10,
        color: AppColors.chalk,
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.crypt,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: AppColors.border),
      ),
      contentTextStyle: const TextStyle(
        fontFamily: 'Courier New',
        fontSize: 11,
        color: AppColors.chalk,
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (states) =>
            states.contains(WidgetState.selected)
                ? AppColors.chalk
                : AppColors.ash,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (states) =>
            states.contains(WidgetState.selected)
                ? AppColors.crimson
                : AppColors.vessel,
      ),
      trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
  );
}
