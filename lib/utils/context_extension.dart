import 'package:flutter/material.dart';
import 'package:socbay/utils/theme_util.dart';

import 'color_util.dart';

extension MediaQueryValues on BuildContext {
  double get statusBarHeight => MediaQuery.of(this).viewPadding.top;

  double get width => MediaQuery.of(this).size.width;

  double get height => MediaQuery.of(this).size.height;

  void showSnackBar(
    String title, {
    Color? color,
    Duration? duration,
    TextStyle? style,
  }) {
    ScaffoldMessenger.of(this).showSnackBar(SnackBar(
      content: Text(
        title,
        style: const TextStyle(fontWeight: MyFontWeight.medium),
        textAlign: TextAlign.center,
      ),
      duration: duration ?? const Duration(milliseconds: 1500),
      width: 280.0,
      backgroundColor: color?.withOpacity(0.85),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
    ));
  }

  showSnackBarError(
    String message, {
    Duration? duration,
  }) {
    showSnackBar(
      message,
      color: ColorUtil.red,
      duration: duration,
      style: const TextStyle(color: Colors.white),
    );
  }

  showSnackBarSuccess(
    String message, {
    Duration? duration,
  }) {
    showSnackBar(
      message,
      color: ColorUtil.bangladeshGreen,
      duration: duration,
      style: const TextStyle(color: Colors.black),
    );
  }
}
