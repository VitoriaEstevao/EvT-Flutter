// lib/theme/app_theme.dart

import 'package:flutter/material.dart';

class AppTheme {
  // Cores Base (Adaptadas do seu CSS)
  static const Color primary = Color(0xFF3498db); // Azul
  static const Color primaryLight = Color(0xFF5dade2); // Azul Claro
  static const Color primaryDark = Color(0xFF2e86c1); // Azul Escuro
  static const Color secondary = Color(0xFFe74c3c); // Vermelho/Perigo
  static const Color danger = Color(0xFFe74c3c); // Alias para Danger
  static const Color secondaryLight = Color(0xFFec7063);
  static const Color white = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFf4f6f7); // Equivalente ao color-gray-light
  static const Color card = Color(0xFFFFFFFF); // Fundo do Card/Formulário
  static const Color border = Color(0xFFd0d3d4); // Cinza da Borda
  static const Color textPrimary = Color(0xFF2c3e50);

  // Estilo de Input Comum
  static InputDecoration inputDecoration(String labelText, {Color? errorColor}) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: TextStyle(color: textPrimary),
      contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6.0),
        borderSide: BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6.0),
        borderSide: BorderSide(color: primary, width: 2.0),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6.0),
        borderSide: BorderSide(color: errorColor ?? danger, width: 2.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6.0),
        borderSide: BorderSide(color: errorColor ?? danger, width: 2.0),
      ),
      filled: true,
      fillColor: white,
    );
  }

  // Tema Principal
  static final ThemeData appTheme = ThemeData(
    primaryColor: primary,
    scaffoldBackgroundColor: background,
    fontFamily: 'Roboto', // Adapte se usar outra fonte
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: white, 
        backgroundColor: primary,
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
    ),
  );
}