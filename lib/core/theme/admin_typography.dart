import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class AdminTypography {
  static TextStyle serif({
    double fontSize = 32,
    double height = 1,
    double letterSpacing = 0,
    FontWeight fontWeight = FontWeight.w500,
    Color color = const Color(0xFF171511),
  }) {
    return GoogleFonts.cormorantGaramond(
      fontSize: fontSize,
      height: height,
      letterSpacing: letterSpacing,
      fontWeight: fontWeight,
      color: color,
    );
  }

  static TextStyle label({
    double fontSize = 11,
    double letterSpacing = 1.5,
    FontWeight fontWeight = FontWeight.w500,
    Color color = const Color(0xFF171511),
  }) {
    return TextStyle(
      fontSize: fontSize,
      letterSpacing: letterSpacing,
      fontWeight: fontWeight,
      color: color,
    );
  }

  static TextStyle body({
    double fontSize = 13.5,
    double height = 1.55,
    FontWeight fontWeight = FontWeight.w400,
    Color color = const Color(0xFF171511),
  }) {
    return TextStyle(
      fontSize: fontSize,
      height: height,
      fontWeight: fontWeight,
      color: color,
    );
  }
}
