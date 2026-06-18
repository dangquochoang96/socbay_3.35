import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:socbay/config/app_config.dart';
import 'package:socbay/utils/context_extension.dart';

import '../data/model/banner_model.dart';
import '../utils/image_util.dart';

class BannerSliderWidget extends StatefulWidget {
  const BannerSliderWidget({super.key, required this.banners});

  @override
  State<BannerSliderWidget> createState() => _SliderWidget();
  final List<BannerModel> banners;
}

class _SliderWidget extends State<BannerSliderWidget> {
  // final CarouselController _carouselController = CarouselController();

  @override
  Widget build(BuildContext context) {
    double width = context.width;
    return Visibility(
      visible: widget.banners.length > 1,
      replacement: ImageUtil.loadNetWorkImage(
        url: _bannerImageUrl(widget.banners[0].image),
        width: width,
        height: 200,
        fit: BoxFit.cover,
      ),
      child: CarouselSlider(
        options: CarouselOptions(
          height: 200.0,
          autoPlay: true,
          initialPage: 0,
          viewportFraction: 1.0,
          enlargeCenterPage: false,
          autoPlayAnimationDuration: const Duration(microseconds: 500),
        ),
        items: widget.banners.map((i) {
          return ImageUtil.loadNetWorkImage(
            url: _bannerImageUrl(i.image),
            width: width,
            height: 150,
            fit: BoxFit.cover,
          );
        }).toList(),
      ),
    );
  }

  String _bannerImageUrl(String? image) {
    if (image == null || image.isEmpty) {
      return '';
    }

    final uri = Uri.tryParse(image);
    if (uri != null && uri.hasScheme) {
      return image;
    }

    final path = image.startsWith('/') ? image : '/$image';
    return '$protocol${AppConfig.instance.values.apiUrl}$path';
  }
}
