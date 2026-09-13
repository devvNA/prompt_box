import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  AppTypography._();

  static TextStyle display = GoogleFonts.spaceGrotesk(
    fontSize: 36,
    fontWeight: FontWeight.w800,
    color: AppColors.ink,
    height: 1.2,
  );

  static TextStyle h1 = GoogleFonts.spaceGrotesk(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: AppColors.ink,
    height: 1.25,
  );

  static TextStyle h2 = GoogleFonts.spaceGrotesk(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
    height: 1.3,
  );

  static TextStyle cardTitle = GoogleFonts.spaceGrotesk(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
    height: 1.3,
  );

  static TextStyle bodyLarge = GoogleFonts.plusJakartaSans(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.ink,
    height: 1.5,
  );

  static TextStyle body = GoogleFonts.plusJakartaSans(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.ink,
    height: 1.5,
  );

  static TextStyle bodyBold = GoogleFonts.plusJakartaSans(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
    height: 1.5,
  );

  static TextStyle caption = GoogleFonts.plusJakartaSans(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.muted,
    height: 1.4,
  );

  static TextStyle button = GoogleFonts.spaceGrotesk(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
    letterSpacing: 0.5,
  );
}
