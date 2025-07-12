import 'package:flutter/material.dart';
 class AppColors {   static const primaryColor = Color(0xFF286359); // Bright Blue
   static const accentColor = Color(0xFFFFcb64); // Vibrant Yellow
   static const backgroundColor = Color(0xFFF5F5F5); // Light Gray
  static const textPrimaryColor = Color(0xFF212121); // Dark Gray
  static const textSecondaryColor = Color(0xFF757575); // Light Gray
 }

 final appTheme = ThemeData(
useMaterial3: true,
  colorScheme: ColorScheme(
     brightness: Brightness.light,
          primary: AppColors.primaryColor,
     onPrimary: Colors.white,
     secondary: AppColors.accentColor,
     onSecondary: Colors.black,
    background: AppColors.backgroundColor,
     onBackground: AppColors.textPrimaryColor,
     surface: Colors.white,
    onSurface: AppColors.textPrimaryColor,
    error: Colors.red,
     onError: Colors.white,
   ),
   scaffoldBackgroundColor: AppColors.backgroundColor,
  primaryColor: AppColors.primaryColor,
  textTheme: TextTheme(
    displayLarge: TextStyle(
      fontSize: 57,
      fontWeight: FontWeight.bold,
      color: AppColors.textPrimaryColor,
    ),
    displayMedium: TextStyle(
      fontSize: 45,
      fontWeight: FontWeight.bold,
      color: AppColors.textPrimaryColor,
    ),
    displaySmall: TextStyle(
      fontSize: 36,
      fontWeight: FontWeight.bold,
      color: AppColors.textPrimaryColor,
    ),
    headlineLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimaryColor,
    ),
    headlineMedium: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimaryColor,
    ),
    headlineSmall: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimaryColor,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      color: AppColors.textPrimaryColor,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      color: AppColors.textPrimaryColor,
    ),
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: AppColors.primaryColor,
    ),
    titleLarge: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: AppColors.primaryColor,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primaryColor,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      textStyle: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: AppColors.primaryColor,
    elevation: 0,
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
    iconTheme: IconThemeData(color: Colors.white),
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: AppColors.primaryColor,
    foregroundColor: Colors.black,
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: BorderSide(color: AppColors.accentColor),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: BorderSide(color: AppColors.primaryColor, width: 2.0),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: BorderSide(color: AppColors.primaryColor),
    ),
    labelStyle: TextStyle(
      color: AppColors.textSecondaryColor,
      fontSize: 14,
    ),
    hintStyle: TextStyle(
      color: AppColors.textSecondaryColor.withOpacity(0.7),
      fontSize: 14,
    ),
  ),
);
