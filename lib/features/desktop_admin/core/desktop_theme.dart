import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DesktopTheme {
  // Brand Colors
  static const Color primaryBlue = Color(0xFF4F46E5);      // Indigo 600
  static const Color primaryLight = Color(0xFFEEF2FF);     // Indigo 50
  static const Color secondary = Color(0xFF0F172A);        // Slate 900
  
  // Sidebar Colors (Vibrant Dark)
  static const Color sidebarBg = Color(0xFF0F172A);        // Slate 900
  static const Color sidebarHover = Color(0xFF1E293B);     // Slate 800
  static const Color sidebarActive = Color(0xFF4F46E5);    // Indigo 600
  static const Color sidebarText = Color(0xFF94A3B8);      // Slate 400
  static const Color sidebarTextActive = Color(0xFFFFFFFF);

  // Surface Colors
  static const Color contentBg = Color(0xFFF8FAFC);        // Slate 50
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color headerBg = Colors.white; // Glassmorphism will be handled in widgets

  // Accent palette
  static const Color success = Color(0xFF10B981);         // Emerald 500
  static const Color warning = Color(0xFFF59E0B);         // Amber 500
  static const Color danger = Color(0xFFEF4444);          // Red 500
  static const Color info = Color(0xFF0EA5E9);            // Sky 500
  static const Color purple = Color(0xFF8B5CF6);          // Violet 500
  static const Color accentTeal = Color(0xFF14B8A6);      // Teal 500
  
  // Aliases for compatibility
  static const Color successGreen = success;
  static const Color warningAmber = warning;
  static const Color dangerRed = danger;
  static const Color purpleAccent = purple;
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderLight = Color(0xFFF1F5F9);

  // Text colors
  static const Color textPrimary = Color(0xFF0F172A);     // Slate 900
  static const Color textSecondary = Color(0xFF475569);   // Slate 600
  static const Color textMuted = Color(0xFF94A3B8);       // Slate 400

  // Layout consts
  static const double sidebarWidth = 280.0;
  static const double sidebarCollapsedWidth = 80.0;
  static const double headerHeight = 72.0;
  static const double contentPadding = 32.0;

  // Effects
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.03),
      offset: const Offset(0, 2),
      blurRadius: 4,
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      offset: const Offset(0, 10),
      blurRadius: 15,
      spreadRadius: -3,
    ),
  ];

  static BoxDecoration get glassEffect => BoxDecoration(
    color: Colors.white.withOpacity(0.7),
    border: Border.all(color: Colors.white.withOpacity(0.2)),
  );

  static Color statusColor(String status) {
    final s = status.toLowerCase();
    if (s.contains('approved') || s.contains('active') || s.contains('completed') || s.contains('success') || s == 'online') return success;
    if (s.contains('pending') || s == 'ongoing' || s.contains('wait')) return warning;
    if (s.contains('reject') || s.contains('fail') || s.contains('cancel') || s == 'blocked') return danger;
    if (s == 'new' || s == 'on trip') return primaryBlue;
    return textMuted;
  }

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        primary: primaryBlue,
        secondary: secondary,
        surface: contentBg,
      ),
      scaffoldBackgroundColor: contentBg,
      textTheme: GoogleFonts.plusJakartaSansTextTheme().copyWith(
        displayLarge: GoogleFonts.plusJakartaSans(fontSize: 32, fontWeight: FontWeight.w800, color: textPrimary, letterSpacing: -0.5),
        headlineLarge: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.w700, color: textPrimary, letterSpacing: -0.3),
        headlineMedium: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w600, color: textPrimary),
        titleLarge: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w600, color: textPrimary),
        titleMedium: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w600, color: textPrimary),
        bodyLarge: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w400, color: textPrimary),
        bodyMedium: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w400, color: textSecondary),
        labelLarge: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: textPrimary),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: cardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFF1F5F9), width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryBlue, width: 2),
        ),
        hintStyle: GoogleFonts.plusJakartaSans(color: textMuted, fontSize: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
    );
  }
}
