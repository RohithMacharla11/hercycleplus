import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: AppColors.deepPlum,
      scaffoldBackgroundColor: AppColors.pearlWhite,
      textTheme: TextTheme(
        headlineLarge: GoogleFonts.dmSerifDisplay(
          fontSize: 28,
          color: AppColors.deepPlum,
        ),
        bodyMedium: GoogleFonts.poppins(
          fontSize: 16,
          color: AppColors.deepPlum,
        ),
        labelMedium: GoogleFonts.poppins(
          fontSize: 14,
          color: AppColors.deepPlum,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.blushRose,
          foregroundColor: AppColors.deepPlum,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
      cardTheme: CardTheme(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }
}