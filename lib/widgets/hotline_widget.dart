import 'package:flutter/material.dart';
import 'package:socbay/utils/color_util.dart';
import 'package:socbay/widgets/my_rich_text.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/app_localization.dart';

class HotlineWidget extends StatelessWidget {
  const HotlineWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70,
      child: Center(
        child: MyRichText(
          firstText: "${l("Hotline")}: ",
          secondText: l("0963456911"),
          firstTextStyle: const TextStyle(
            color: Colors.grey,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          secondTextStyle: const TextStyle(
            color: ColorUtil.bangladeshGreen,
            fontSize: 15,
            decoration: TextDecoration.underline,
            fontWeight: FontWeight.bold,
          ),
          onTapSecond: () async {
            const url = "tel:0963456911";
            await launchUrl(Uri.parse(url));
          },
        ),
      ),
    );
  }
}
