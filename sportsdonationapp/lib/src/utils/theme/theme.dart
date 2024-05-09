import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SAppTheme {
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    textTheme: TextTheme(
      displayMedium: GoogleFonts.montserrat(
        fontSize: 24,
        // Specify the font size or other properties as needed
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
  );
}
