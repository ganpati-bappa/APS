import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

OutlinedButtonThemeData lightOutlineButtonData = OutlinedButtonThemeData(
  style: ButtonStyle(
    textStyle:  WidgetStatePropertyAll(GoogleFonts.ptSerif(fontWeight: FontWeight.w200, fontSize:5, color: Colors.black)),
    shape: WidgetStatePropertyAll(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5.0),
      )
    ),
    padding: const WidgetStatePropertyAll(EdgeInsetsDirectional.symmetric(vertical: 10.0))
  )
);

TextTheme lightTextTheme = TextTheme(
  displayLarge: GoogleFonts.ptSerif(fontWeight: FontWeight.w600, fontSize: 18),
  displayMedium: GoogleFonts.ptSerif(fontWeight: FontWeight.w400, fontSize: 16),
  headlineMedium: GoogleFonts.ptSerif(fontWeight: FontWeight.w500, fontSize: 18),
  labelLarge: GoogleFonts.ptSerif(fontWeight: FontWeight.w700, fontSize: 20),
  labelMedium: GoogleFonts.ptSerif(fontSize: 16, fontWeight: FontWeight.w700),
  labelSmall: GoogleFonts.ptSerif(fontWeight: FontWeight.w400, fontSize: 14),
  bodyMedium: GoogleFonts.lato(),
  headlineLarge: GoogleFonts.ptSerif(fontWeight: FontWeight.w900, fontSize: 24),
  headlineSmall: GoogleFonts.ptSerif(fontSize: 15),
  titleLarge: GoogleFonts.ptSerif(fontWeight: FontWeight.w600, fontSize: 20, color: Colors.white),
  titleMedium: GoogleFonts.ptSerif(fontWeight: FontWeight.w500, fontSize: 16, color: Colors.white),
  titleSmall: GoogleFonts.ptSerif(fontWeight: FontWeight.w500, fontSize: 14, color: Colors.white),
);

ElevatedButtonThemeData lightElevatedButtonData =  ElevatedButtonThemeData(
  style: ButtonStyle(
    textStyle:  WidgetStatePropertyAll(GoogleFonts.ptSerif(fontWeight: FontWeight.w500, fontSize: 15, color: Colors.white)),
    backgroundColor: const WidgetStatePropertyAll(Color.fromARGB(255, 9, 9, 26)),
    padding: const WidgetStatePropertyAll(EdgeInsetsDirectional.symmetric(vertical: 10.0)),
    shape: WidgetStatePropertyAll(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      )
    ),
  )
);

ProgressIndicatorThemeData progressIndicatorThemeData = const ProgressIndicatorThemeData(
  color: Colors.black45,
  circularTrackColor: Colors.black45
);
