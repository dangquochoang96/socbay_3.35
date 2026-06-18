import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import 'package:nb_utils/nb_utils.dart';

// ignore: constant_identifier_names
const GOOGLE_MAP_PREFIX = 'https://www.google.com/maps/search/?api=1&query=';

bool get isAndroid => Platform.isAndroid;

Future<void> commonLaunchUrl(
  String url, {
  LaunchMode launchMode = LaunchMode.inAppWebView,
}) async {
  await launchUrl(Uri.parse(url), mode: launchMode).catchError((e) {
    toast('Invalid URL: $url');
    throw e;
  });
}
