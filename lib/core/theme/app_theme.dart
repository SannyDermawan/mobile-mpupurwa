import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_dimens.dart';
import 'app_text_styles.dart';

/// `ThemeData` Material 3 yang meniru gaya di CSS HTML.
abstract final class AppTheme {
  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(seedColor: AppColors.amber, brightness: Brightness.light)
        .copyWith(
          primary: AppColors.amber,
          onPrimary: AppColors.charcoal,
          secondary: AppColors.goldDeep,
          onSecondary: AppColors.cream,
          surface: AppColors.cream,
          onSurface: AppColors.ink,
          outline: AppColors.stoneLine,
          outlineVariant: AppColors.stoneLine,
          error: AppColors.error,
        );

    OutlineInputBorder inputBorder(Color color) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppDimens.radiusSm),
      borderSide: BorderSide(color: color),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.cream,
      canvasColor: AppColors.cream,
      splashFactory: InkRipple.splashFactory,
      textTheme: TextTheme(
        displayLarge: AppTextStyles.serif(32),
        headlineLarge: AppTextStyles.serif(25),
        headlineMedium: AppTextStyles.serif(23),
        headlineSmall: AppTextStyles.serif(21),
        titleLarge: AppTextStyles.serif(18),
        titleMedium: AppTextStyles.serif(15),
        titleSmall: AppTextStyles.serif(14),
        bodyLarge: AppTextStyles.sans(14),
        bodyMedium: AppTextStyles.body,
        bodySmall: AppTextStyles.sans(11.5, color: AppColors.inkSoft),
        labelLarge: AppTextStyles.button,
        labelMedium: AppTextStyles.sans(12, weight: FontWeight.w600),
        labelSmall: AppTextStyles.navLabel,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.amber,
          foregroundColor: AppColors.charcoal,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.all(13),
          textStyle: AppTextStyles.button,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.radiusMd)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.offwhite,
          foregroundColor: AppColors.stoneDark,
          elevation: 0,
          padding: const EdgeInsets.all(13),
          textStyle: AppTextStyles.button,
          side: const BorderSide(color: AppColors.stoneLine),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.radiusMd)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.amber,
          textStyle: AppTextStyles.sans(12.5, weight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.offwhite,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        hintStyle: AppTextStyles.formHint,
        errorStyle: AppTextStyles.formError,
        border: inputBorder(AppColors.stoneLine),
        enabledBorder: inputBorder(AppColors.stoneLine),
        focusedBorder: inputBorder(AppColors.amber),
        errorBorder: inputBorder(AppColors.error),
        focusedErrorBorder: inputBorder(AppColors.error),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? AppColors.amber : null,
        ),
        checkColor: const WidgetStatePropertyAll(AppColors.charcoal),
        side: const BorderSide(color: AppColors.stoneMid, width: 1.5),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      ),
      dividerTheme: const DividerThemeData(color: AppColors.stoneLine, space: 1, thickness: 1),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.charcoal,
        contentTextStyle: AppTextStyles.sans(12.5, color: AppColors.cream),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
