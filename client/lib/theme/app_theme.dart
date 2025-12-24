import 'package:flutter/material.dart';

class AppTheme {
  static final TextTheme _textTheme = ThemeData.light().textTheme;

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF6750A4), // Deep Purple
        brightness: Brightness.light,
      ),
      fontFamily: 'LocalRoboto',
      textTheme: _textTheme.apply(
        fontFamily: 'LocalRoboto',
        bodyColor: const Color(0xFF1C1B1F),
        displayColor: const Color(0xFF1C1B1F),
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Color(0xFFF3EDF7), // Surface Container Low
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
      ),
      navigationRailTheme: const NavigationRailThemeData(
        elevation: 1,
        labelType: NavigationRailLabelType.all,
      ),
      dividerTheme: const DividerThemeData(
        space: 1,
        thickness: 1,
        color: Color(0xFFCAC4D0),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFFD0BCFF), // Light Purple
        brightness: Brightness.dark,
      ),
      fontFamily: 'LocalRoboto',
      textTheme: _textTheme.apply(
        fontFamily: 'LocalRoboto',
        bodyColor: const Color(0xFFE6E1E5),
        displayColor: const Color(0xFFE6E1E5),
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Color(0xFF141218),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
      ),
    );
  }
}
