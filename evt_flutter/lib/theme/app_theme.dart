import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFF7873F5);
  static const Color secondary = Color(0xFF9B5DE5);
  static const Color success = Color(0xFF06D6A0);
  static const Color danger = Color(0xFFEF476F);
  static const Color card = Colors.white;
  static const Color background = Color(0xFFF6F8FB);
  static const Color border = Color(0xFFE0E0E0);
  static const Color text = Color(0xFF2A2A2A);

  static ThemeData theme = ThemeData(
    scaffoldBackgroundColor: background,
    fontFamily: 'Outfit',

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: card,
      contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: primary, width: 1.6),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: border),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 14, horizontal: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: success,
        textStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    ),
  );
}
