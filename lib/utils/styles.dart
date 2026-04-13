import 'package:flutter/material.dart';

class MyStyles {
  late ThemeData themeData;

  MyStyles(this.themeData);

  factory MyStyles.of(BuildContext context) {
    return MyStyles(Theme.of(context));
  }

}
