import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFFE63946);
  static const accent = Color(0xFFF4B942);
  static const bg = Color(0xFF121115);
  static const surface1 = Color(0xFF1C1A20);
  static const surface2 = Color(0xFF2A272F);
  static const textMain = Color(0xFFF5F2F7);
  static const textMuted = Color(0xFFA29CB0);
  static const success = Color(0xFF3ECF8E);
}

class AppTheme {
  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.bg,
      fontFamily: 'Prompt',
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.surface1,
        error: AppColors.primary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textMain,
      ),
      textTheme: const TextTheme(
        headlineSmall: TextStyle(
            color: AppColors.textMain, fontWeight: FontWeight.w700, fontSize: 22),
        titleMedium: TextStyle(
            color: AppColors.textMain, fontWeight: FontWeight.w600, fontSize: 16),
        bodyMedium: TextStyle(color: AppColors.textMuted, fontSize: 14),
        bodySmall: TextStyle(color: AppColors.textMuted, fontSize: 12),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface1,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textMuted,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
      ),
    );
  }
}

class Responsive {
  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600;

  static int gridColumns(BuildContext context) => isTablet(context) ? 4 : 2;
}
