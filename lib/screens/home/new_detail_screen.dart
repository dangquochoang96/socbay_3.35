import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:socbay/config/app_config.dart';
import 'package:socbay/constants/constants.dart';
import 'package:socbay/data/model/blog_model.dart';
import 'package:socbay/utils/color_util.dart';
import 'package:socbay/utils/image_util.dart';
import 'package:socbay/widgets/my_app_bar.dart';

class NewDetailScreen extends StatelessWidget {
  final BlogModel blogModel;

  const NewDetailScreen({
    super.key,
    required this.blogModel,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        isBackNavigation: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(
            horizontal: paddingHorizontal, vertical: paddingVertical),
        children: [
          ImageUtil.loadNetWorkImage(url: blogModel.image!=null? '$protocol${AppConfig.instance.values.apiUrl}${blogModel.image!}':"" , height: 200),
          const SizedBox(height: 16),
          Center(
            child: Text(
              blogModel.name ?? "",
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  color: ColorUtil.bangladeshGreen),
            ),
          ),
          Html(data: "${blogModel.des}")
        ],
      ),
    );
  }
}
