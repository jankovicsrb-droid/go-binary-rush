import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Palette ───────────────────────────────────────────────────
class AppColors {
  static const bg     = Color(0xFF000000);
  static const g0     = Color(0xFF0A1A0A);
  static const g1     = Color(0xFF163B1F);
  static const g2     = Color(0xFF2A7A3A);
  static const g3     = Color(0xFF4ECF6A);
  static const g4     = Color(0xFF7DFF97);
  static const g5     = Color(0xFFB8FFC7);
  static const amber  = Color(0xFFFFB547);
  static const red    = Color(0xFFFF4D4D);
  static const cyan   = Color(0xFF4DD6FF);
}

// ── Glow helpers ──────────────────────────────────────────────
class AppGlow {
  static List<BoxShadow> sm = [
    BoxShadow(color: AppColors.g4.withValues(alpha: 0.45), blurRadius: 4),
  ];
  static List<BoxShadow> md = [
    BoxShadow(color: AppColors.g4.withValues(alpha: 0.55), blurRadius: 10),
    BoxShadow(color: AppColors.g3.withValues(alpha: 0.25), blurRadius: 22),
  ];
  static List<BoxShadow> lg = [
    BoxShadow(color: AppColors.g4.withValues(alpha: 0.65), blurRadius: 18),
    BoxShadow(color: AppColors.g3.withValues(alpha: 0.35), blurRadius: 40),
  ];
  static List<BoxShadow> amber = [
    BoxShadow(color: AppColors.amber.withValues(alpha: 0.55), blurRadius: 8),
  ];
  static List<BoxShadow> red = [
    BoxShadow(color: AppColors.red.withValues(alpha: 0.55), blurRadius: 8),
  ];
}

// ── Text styles ───────────────────────────────────────────────
class AppText {
  static TextStyle kicker({Color color = AppColors.g2}) => GoogleFonts.jetBrainsMono(
    fontSize: 10, letterSpacing: 2.2, color: color,
  );
  static TextStyle label({Color color = AppColors.g3}) => GoogleFonts.jetBrainsMono(
    fontSize: 13, letterSpacing: 1.8, color: color,
    shadows: AppGlow.sm.map((s) => Shadow(color: s.color, blurRadius: s.blurRadius)).toList(),
  );
  static TextStyle hudValue({Color color = AppColors.g4}) => GoogleFonts.jetBrainsMono(
    fontSize: 16, fontWeight: FontWeight.w600, color: color,
    shadows: AppGlow.sm.map((s) => Shadow(color: s.color, blurRadius: s.blurRadius)).toList(),
  );
  static TextStyle bigTarget({Color color = AppColors.g5}) => GoogleFonts.jetBrainsMono(
    fontSize: 64, fontWeight: FontWeight.bold, color: color, height: 1.0,
    shadows: AppGlow.lg.map((s) => Shadow(color: s.color, blurRadius: s.blurRadius)).toList(),
  );
  static TextStyle mono({double size = 14, Color color = AppColors.g3, FontWeight weight = FontWeight.normal}) =>
      GoogleFonts.jetBrainsMono(fontSize: size, color: color, fontWeight: weight);
}

// ── Theme ─────────────────────────────────────────────────────
ThemeData buildAppTheme() {
  final base = ThemeData.dark();
  return base.copyWith(
    scaffoldBackgroundColor: AppColors.bg,
    colorScheme: const ColorScheme.dark(
      surface: AppColors.bg,
      primary: AppColors.g4,
    ),
    textTheme: GoogleFonts.jetBrainsMonoTextTheme(base.textTheme).apply(
      bodyColor: AppColors.g3,
      displayColor: AppColors.g4,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.bg,
      elevation: 0,
      iconTheme: const IconThemeData(color: AppColors.g2),
      titleTextStyle: GoogleFonts.jetBrainsMono(
        color: AppColors.g4, fontSize: 15, letterSpacing: 4,
      ),
    ),
  );
}
