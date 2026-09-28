import 'package:flutter/material.dart';

/// CineGo design tokens — keep these in sync with the Figma file.
/// If เม่ยเปลี่ยนสีใน Figma ให้มาแก้ค่าที่นี่ที่เดียว ทั้งแอพจะเปลี่ยนตาม
class AppColors {
  static const primary = Color(0xFFE63946); // แดง
  static const accent = Color(0xFFF4B942); // ทอง
  static const bg = Color(0xFF121115); // พื้นหลังหลัก
  static const surface1 = Color(0xFF1C1A20); // การ์ด/แถบ
  static const surface2 = Color(0xFF2A272F); // ปุ่มรอง/เส้นขอบ
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
      fontFamily: 'Prompt', // ใส่ฟอนต์ Prompt ใน pubspec.yaml -> assets/fonts
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

/// Breakpoint เดียวที่ใช้ทั้งแอพ เพื่อตัดสินว่ามือถือหรือแท็บเล็ต
class Responsive {
  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600;

  /// จำนวนคอลัมน์ของ grid หนัง: มือถือ 2, แท็บเล็ต 4
  static int gridColumns(BuildContext context) => isTablet(context) ? 4 : 2;
}
