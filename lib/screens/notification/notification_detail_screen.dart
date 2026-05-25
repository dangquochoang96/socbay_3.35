import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:full_screen_image_null_safe/full_screen_image_null_safe.dart';
import 'package:socbay/config/app_config.dart';
import 'package:socbay/constants/constants.dart';
import 'package:socbay/data/model/notification_response.dart';
import 'package:socbay/utils/color_util.dart';
import 'package:socbay/utils/context_extension.dart';
import 'package:socbay/utils/image_util.dart';
import 'package:socbay/widgets/my_app_bar.dart';

class NotificationDetailScreen extends StatelessWidget {
  const NotificationDetailScreen({
    super.key,
    required this.notificationResponse,
  });
  final NotificationResponse notificationResponse;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        title: "Chi tiết thông báo",
        centerTitle: true,
        isBackNavigation: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          // padding: const EdgeInsets.symmetric(
          //     horizontal: paddingHorizontal, vertical: paddingVertical),
          children: [
            FullScreenWidget(
              child: Hero(
                tag: notificationResponse.image!=null?'$protocol${AppConfig.instance.values.apiUrl}${notificationResponse.image}': "",
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: ImageUtil.loadNetWorkImage(
                      url: notificationResponse.image!=null? '$protocol${AppConfig.instance.values.apiUrl}${notificationResponse.image}':"", height: context.width - paddingHorizontal * 2, fit: BoxFit.contain),
                  //fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                notificationResponse.name ?? "",
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    color: ColorUtil.bangladeshGreen),
              ),
            ),
            const SizedBox(height: 16),
            Html(data: notificationResponse.des ?? ''),
          ],
        ),
      )
    );
  }
}
