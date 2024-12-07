import 'package:flutter/material.dart';

class AppTextStyle {
  static const MINI_BOLD_DESCRIPTION_TEXT = TextStyle(
    fontSize: 13,
    color: Colors.black,
    letterSpacing: 3,
    fontWeight: FontWeight.w600,
  );
  static const MIDDLE_BUTTON_TEXT = TextStyle(
      fontSize: 20,
      // letterSpacing: 5,
      color: Colors.white,
      fontWeight: FontWeight.w500);

  static const MIDDLE_BUTTON_TEXT_BOLD = TextStyle(
      fontSize: 16,
      // letterSpacing: 5,
      color: Colors.white,
      fontWeight: FontWeight.bold);

  static const MINI_DESCRIPTION_TEXT =
      TextStyle(fontSize: 13, color: Colors.black87, letterSpacing: 3);

  static const MINI_DEFAULT_DESCRIPTION_TEXT =
      TextStyle(fontSize: 13, color: Colors.black);

  static const MINI_DESCRIPTION_BOLD =
      TextStyle(fontSize: 13, color: Colors.black, fontWeight: FontWeight.w600);
}
