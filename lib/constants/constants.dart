import 'package:flutter/services.dart';

import '../utils/color_util.dart';

class Constants {
  static const shortAnimationDuration = 300;
  static const longAnimationDuration = 500;
  static const debounceClick = 500;
  static const defaultApiLimit = 20;

  static const linkAppUrl = 'https://onelink.to/wtesp7';
}

const paddingHorizontal = 16.0;
const paddingVertical = 20.0;
const systemUiOverlayStyle = SystemUiOverlayStyle(
  statusBarColor: ColorUtil.bangladeshGreen,
  statusBarIconBrightness: Brightness.light, // For Android
  statusBarBrightness: Brightness.dark, // For iOS
);

const systemUiWhiteStyle = SystemUiOverlayStyle(
  statusBarColor: ColorUtil.white,
  statusBarIconBrightness: Brightness.light, // For Android
  statusBarBrightness: Brightness.dark, // For iOS
);
