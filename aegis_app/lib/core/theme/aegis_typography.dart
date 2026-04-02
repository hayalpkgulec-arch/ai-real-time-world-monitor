import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'aegis_colors.dart';

/// AEGIS Intelligence Design System — Typography
/// Inter for headlines/body, Space Grotesk for labels (terminal aesthetic).
class AegisTypography {
  AegisTypography._();

  // ── Display (Big Number metrics) ──
  static TextStyle displayLg = GoogleFonts.inter(
    fontSize: 56, // 3.5rem
    fontWeight: FontWeight.w700,
    color: AegisColors.onSurface,
    height: 1.0,
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  static TextStyle displayMd = GoogleFonts.inter(
    fontSize: 44,
    fontWeight: FontWeight.w700,
    color: AegisColors.onSurface,
    height: 1.0,
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  static TextStyle displaySm = GoogleFonts.inter(
    fontSize: 36,
    fontWeight: FontWeight.w700,
    color: AegisColors.onSurface,
    height: 1.1,
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  // ── Headlines (Section anchors) ──
  static TextStyle headlineLg = GoogleFonts.inter(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    color: AegisColors.onSurface,
    letterSpacing: -0.5,
    height: 1.15,
  );

  static TextStyle headlineMd = GoogleFonts.inter(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AegisColors.onSurface,
    letterSpacing: -0.3,
    height: 1.2,
  );

  static TextStyle headlineSm = GoogleFonts.inter(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AegisColors.onSurface,
    letterSpacing: -0.2,
    height: 1.25,
  );

  // ── Body (Content text) ──
  static TextStyle bodyLg = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AegisColors.onSurfaceVariant,
    height: 1.5,
  );

  static TextStyle bodyMd = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AegisColors.onSurfaceVariant,
    height: 1.5,
  );

  static TextStyle bodySm = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AegisColors.onSurfaceVariant,
    height: 1.4,
  );

  // ── Labels (Space Grotesk — terminal/HUD feel) ──
  static TextStyle labelLg = GoogleFonts.spaceGrotesk(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AegisColors.onSurfaceVariant,
    letterSpacing: 2.0,
  );

  static TextStyle labelMd = GoogleFonts.spaceGrotesk(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AegisColors.onSurfaceVariant,
    letterSpacing: 1.5,
  );

  static TextStyle labelSm = GoogleFonts.spaceGrotesk(
    fontSize: 10,
    fontWeight: FontWeight.w400,
    color: AegisColors.onSurfaceVariant,
    letterSpacing: 2.0,
  );

  static TextStyle labelXs = GoogleFonts.spaceGrotesk(
    fontSize: 9,
    fontWeight: FontWeight.w400,
    color: AegisColors.onSurfaceVariant,
    letterSpacing: 1.5,
  );

  // ── Data Values (tabular-nums) ──
  static TextStyle dataLg = GoogleFonts.inter(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AegisColors.onSurface,
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  static TextStyle dataMd = GoogleFonts.inter(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AegisColors.onSurface,
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  static TextStyle dataSm = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AegisColors.onSurface,
    fontFeatures: const [FontFeature.tabularFigures()],
  );
}
