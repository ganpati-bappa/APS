import 'package:aps/src/constants/colors.dart';
import 'package:aps/src/widgetThemes.dart';
import 'package:flutter/material.dart';

class themes {
  themes._();
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: backgroundColor,
    outlinedButtonTheme: lightOutlineButtonData, 
    elevatedButtonTheme: lightElevatedButtonData,
    textTheme: lightTextTheme,
    fontFamily: 'Helvetica',
  );  

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
  );

}