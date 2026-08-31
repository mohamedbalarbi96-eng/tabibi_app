import 'package:flutter/material.dart';

/// TABIBI (طبيبي) - Ultra-Modern Glassmorphism & Bento Medical Design System
class AppTheme {
  // الألوان الطبية المعتمدة الفاخرة
  static const Color primary = Color(0xFF059669);        // زمردي طبي ملكي
  static const Color primaryLight = Color(0xFF10B981);   // زمردي فاتح ناعم
  static const Color primaryDark = Color(0xFF047857);    // زمردي داكن
  static const Color secondary = Color(0xFF0284C7);      // أزرق سماوي نقي
  static const Color accent = Color(0xFFF59E0B);         // ذهبي عنبري للتقييمات
  static const Color background = Color(0xFFF8FAFC);     // أبيض ثلجي مريح للعين
  static const Color surface = Colors.white;
  static const Color textMain = Color(0xFF0F172A);       // كحلي داكن نقي للنصوص
  static const Color textMuted = Color(0xFF64748B);      // رمادي ناعم للتفاصيل

  // التدرجات اللونية الزجاجية (Gradients)
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF059669), Color(0xFF0284C7)],
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
  );

  static const LinearGradient promoBannerGradient = LinearGradient(
    colors: [Color(0xFF059669), Color(0xFF047857), Color(0xFF0284C7)],
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
  );

  static const LinearGradient healthCardGradient = LinearGradient(
    colors: [Color(0xFF4F46E5), Color(0xFF0284C7)],
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
  );

  static const LinearGradient cardGlassGradient = LinearGradient(
    colors: [
      Color(0xF2FFFFFF), // أبيض بلوري شبه شفاف
      Color(0xD9FFFFFF),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // الظلال البلورية العميقة (Glass Shadows)
  static List<BoxShadow> get glassShadow => [
        BoxShadow(
          color: const Color(0xFF0F172A).withValues(alpha: 0.04),
          blurRadius: 18,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: const Color(0xFF059669).withValues(alpha: 0.03),
          blurRadius: 30,
          offset: const Offset(0, 12),
        ),
      ];

  static List<BoxShadow> get buttonGlow => [
        BoxShadow(
          color: primary.withValues(alpha: 0.35),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ];

  // الثيم الشامل للمشروع
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      fontFamily: 'Cairo',
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        secondary: secondary,
        surface: surface,
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 18,
          fontWeight: FontWeight.w900,
          color: textMain,
        ),
        iconTheme: IconThemeData(color: textMain),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.95),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        hintStyle: const TextStyle(
          color: textMuted,
          fontSize: 13,
          fontFamily: 'Cairo',
        ),
        labelStyle: const TextStyle(
          color: textMain,
          fontSize: 13,
          fontWeight: FontWeight.w700,
          fontFamily: 'Cairo',
        ),
      ),
    );
  }
}
