import 'package:flutter/material.dart';

class Gcolors{

  Gcolors._();

  //app basic colors
  static const Color primary = Color(0xFFFF4D01);


  //Text colors
  static const Color textPrimary = Color(0xFF333333);
  static const Color textSecondary = Color(0xFF6C757D);
  static const Color textWhite = Colors.white;

  //background Colors
  static const Color light = Color(0xFFF6F6F6);
  static const Color dark = Color(0xFF272727);
  static const Color primaryBackground = Color(0xFFF3F5FF);

  //container colors
  static const Color lightContainer = Color(0xFFF6F6F6);
  static Color darkContainer = Gcolors.textWhite.withOpacity(0.1);

  //button Colors
  static const Color buttonPrimary = Gcolors.primary;
  static const Color buttonSecondary = Color(0xFF6C757D);

  //Error and Validation
  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF388E3C);
  static const Color warning = Color(0xFFF57C00);
  static const Color info = Color(0xFF1976D2);

}