import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  static Color _primaryColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? AppColors.textPrimary : AppColors.lightTextPrimary;

  static Color _secondaryColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? AppColors.textSecondary : AppColors.lightTextSecondary;

  static Color _mutedColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? AppColors.textMuted : AppColors.lightTextMuted;

  static TextStyle displayLarge(BuildContext context, {Color? color}) => GoogleFonts.inter(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        height: 44 / 36,
        color: color ?? _primaryColor(context),
      );

  static TextStyle displayMedium(BuildContext context, {Color? color}) => GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 40 / 32,
        color: color ?? _primaryColor(context),
      );

  static TextStyle h1(BuildContext context, {Color? color}) => GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 36 / 28,
        color: color ?? _primaryColor(context),
      );

  static TextStyle h2(BuildContext context, {Color? color}) => GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 32 / 24,
        color: color ?? _primaryColor(context),
      );

  static TextStyle h3(BuildContext context, {Color? color}) => GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 28 / 20,
        color: color ?? _primaryColor(context),
      );

  static TextStyle h4(BuildContext context, {Color? color}) => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 26 / 18,
        color: color ?? _primaryColor(context),
      );

  static TextStyle bodyLarge(BuildContext context, {Color? color}) => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 24 / 16,
        color: color ?? _secondaryColor(context),
      );

  static TextStyle bodyMedium(BuildContext context, {Color? color}) => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 21 / 14,
        color: color ?? _secondaryColor(context),
      );

  static TextStyle bodySmall(BuildContext context, {Color? color}) => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 18 / 12,
        color: color ?? _mutedColor(context),
      );

  static TextStyle labelLarge(BuildContext context, {Color? color}) => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 20 / 14,
        color: color ?? _primaryColor(context),
      );

  static TextStyle labelSmall(BuildContext context, {Color? color}) => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        height: 16 / 11,
        color: color ?? _mutedColor(context),
      );

  static TextStyle button(BuildContext context, {Color? color}) => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 20 / 14,
        color: color ?? AppColors.textOnPrimary,
      );

  static TextStyle caption(BuildContext context, {Color? color}) => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 16 / 12,
        color: color ?? _mutedColor(context),
      );

  static TextStyle codeEditor(BuildContext context, {Color? color}) => GoogleFonts.firaCode(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 22 / 14,
        color: color ?? _primaryColor(context),
      );
}

