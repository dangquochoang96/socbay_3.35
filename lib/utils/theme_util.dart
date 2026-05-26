import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'color_util.dart';

class ThemeUtil {
  static ThemeData appTheme = ThemeData(
    // Define the default brightness and colors.
    brightness: Brightness.light,
    primaryColor: ColorUtil.primary,
    hintColor: ColorUtil.silverChalice,
    scaffoldBackgroundColor: ColorUtil.white,

    // Define the default TextTheme. Use this to specify the default

    // text styling for headlines, titles, bodies of text, and more.
    textTheme: TextTheme(
      headlineSmall: GoogleFonts.roboto(
        textStyle: const TextStyle(
          color: ColorUtil.raisinBlack,
          fontSize: 17,
          fontWeight: MyFontWeight.semiBold,
        ),
      ),

      //Large text in app bar title
      titleLarge: GoogleFonts.roboto(
        textStyle: const TextStyle(
          color: ColorUtil.raisinBlack,
          fontSize: 16,
          fontWeight: MyFontWeight.semiBold,
        ),
      ),

      //Primary text in list title
      titleMedium: GoogleFonts.roboto(
        textStyle: const TextStyle(
          color: ColorUtil.raisinBlack,
          fontSize: 15,
          fontWeight: MyFontWeight.regular,
        ),
      ),

      //Used for emphasizing text in body
      bodyLarge: GoogleFonts.roboto(
        textStyle: const TextStyle(
          color: ColorUtil.raisinBlack,
          fontSize: 15,
          fontWeight: MyFontWeight.regular,
        ),
      ),

      //Default Textstyle
      bodyMedium: GoogleFonts.roboto(
        textStyle: const TextStyle(
          color: ColorUtil.raisinBlack,
          fontSize: 14,
          fontWeight: MyFontWeight.regular,
        ),
      ),

      //Default button textstyle
      labelLarge: GoogleFonts.roboto(
        textStyle: const TextStyle(
          color: ColorUtil.raisinBlack,
          fontSize: 16,
          fontWeight: MyFontWeight.semiBold,
        ),
      ),
    ),
    // fontFamily: 'Montserrat', colorScheme: ColorScheme.fromSwatch().copyWith(secondary: ColorUtil.mustardAccent),
  );
}

class MyFontWeight {
  static const thin = FontWeight.w100;
  static const extraLight = FontWeight.w200;
  static const light = FontWeight.w300;
  static const regular = FontWeight.w400;
  static const medium = FontWeight.w500;
  static const semiBold = FontWeight.w600;
  static const bold = FontWeight.w700;
  static const extraBold = FontWeight.w800;
  static const ultraBold = FontWeight.w900;
}
