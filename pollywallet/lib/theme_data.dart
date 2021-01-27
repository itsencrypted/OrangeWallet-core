import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const Color backgroundWhite = Color(0xffE5E5E5);
  static const Color white = Color(0xFFFFFFFF);
  static const Color somewhatYellow = Color(0xffE3DECF);
  static const Color primaryColor = Color(0xFFD287FD);
  static const Color secondaryColor = Color(0xffEABC78);
  static const Color black = Color(0xFF000000);

  static const Color grey = Color(0xFF3A5160);
  static const Color purpleSelected = Color(0x7854C5);
  static const Color darkText = Color(0xFF253840);
  static const Color darkerText = Color(0xFF17262A);
  static const Color lightText = Color(0xFF4A6572);
  static const Color deactivatedText = Color(0xFF767676);
  static const Color dismissibleBackground = Color(0xFF364A54);
  static const Color whiteTextColor = Color(0xFFEEF1F3);
  static const Color spacer = Color(0xFFF2F2F2);
  static const double cardRadius = 12;
  static const double cardElevations = 8;
  static const String fontName = 'WorkSans';
  static const double tokenIconHeight = 34;
  static const textTheme = TextTheme(
    body1: body1,
    body2: body2,
    headline: headline,
    title: title,
    subtitle: subtitle,
  );
  static const TextStyle display1 = TextStyle(
    // h4 -> display1
    fontWeight: FontWeight.bold,
    fontSize: 36,
    letterSpacing: 0.4,
    height: 0.9,
    color: darkerText,
  );

  static const TextStyle headline = TextStyle(
    // h5 -> headline
    fontFamily: fontName,
    fontWeight: FontWeight.bold,
    fontSize: 24,
    letterSpacing: 0.27,
    color: darkerText,
  );

  static const TextStyle title = TextStyle(
    // h6 -> title
    fontFamily: fontName,
    fontWeight: FontWeight.bold,
    fontSize: 16,
    letterSpacing: 0.18,
    color: darkerText,
  );

  static const TextStyle subtitle = TextStyle(
    // subtitle2 -> subtitle
    fontFamily: fontName,
    fontWeight: FontWeight.w400,
    fontSize: 14,
    letterSpacing: -0.04,
    color: lightText,
  );

  static const TextStyle body2 = TextStyle(
    // body1 -> body2
    fontFamily: fontName,
    fontWeight: FontWeight.w400,
    fontSize: 14,
    letterSpacing: 0.2,
    color: darkText,
  );

  static const TextStyle body1 = TextStyle(
    // body2 -> body1
    fontFamily: fontName,
    fontWeight: FontWeight.w400,
    fontSize: 16,
    letterSpacing: -0.05,
    color: darkText,
  );

  static const TextStyle buttonText = TextStyle(
    // Caption -> caption
    fontFamily: fontName,
    fontWeight: FontWeight.w400,
    fontSize: 16,
    letterSpacing: 0.3,
    color: whiteTextColor, // was lightText
  );

  static const TextStyle balanceMain = TextStyle(
    fontFamily: fontName,
    fontWeight: FontWeight.bold,
    fontSize: 16,
    letterSpacing: -0.2,
    color: black,
  );
  static const TextStyle balanceSub = TextStyle(
    fontWeight: FontWeight.w400,
    fontFamily: fontName,
    fontSize: 14,
    color: black, // was lightText
  );
  static const cardShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(cardRadius)));
}
