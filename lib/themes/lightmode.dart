import 'package:flutter/material.dart';

// Light Mode Theme
ThemeData lightmode = ThemeData(
  brightness: Brightness.light,
  scaffoldBackgroundColor: Colors.white, // Clean white background
  primaryColor: Colors.deepPurple, // Deep purple primary tone
  colorScheme: ColorScheme.light(
    primary: Colors.deepPurple, // Primary elements use deep purple
    primaryContainer: Colors.pinkAccent.shade100, // Lighter pink for containers
    secondary: Colors.blueAccent,
    surface: Colors.white,
    onPrimary: Colors.white, // Text on primary elements is white
    onSecondary: Colors.white,
    onSurface: Colors.black,
    inversePrimary:
        Colors.deepPurple.shade900, // For contrast on selected elements
    tertiary: Colors.purpleAccent, // Additional accent color
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.deepPurple,
    foregroundColor: Colors.white,
    elevation: 0,
    centerTitle: true,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.deepPurple,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
    ),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Colors.black,
    selectedItemColor: Colors.deepPurple,
    unselectedItemColor: Colors.grey,
  ),
);

// Dark Mode Theme
ThemeData darkmode = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: Colors.grey.shade900,
  primaryColor:
      Colors.deepPurple.shade300, // Lighter purple for dark backgrounds
  colorScheme: ColorScheme.dark(
    primary: Colors.deepPurple.shade300,
    primaryContainer:
        Colors.purpleAccent.shade700, // Richer accent for containers
    secondary: Colors.blueAccent.shade200,
    surface: Colors.grey.shade800,
    onPrimary: Colors.black,
    onSecondary: Colors.black,
    onSurface: Colors.white,
    inversePrimary: Colors.deepPurple.shade700,
    tertiary:
        Colors.pinkAccent.shade200, // Pink accent for additional highlights
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.deepPurple.shade300,
    foregroundColor: Colors.black,
    elevation: 0,
    centerTitle: true,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.deepPurple.shade300,
      foregroundColor: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.grey.shade800,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
    ),
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: Colors.grey.shade900,
    selectedItemColor: Colors.deepPurple.shade300,
    unselectedItemColor: Colors.grey.shade500,
  ),
);
