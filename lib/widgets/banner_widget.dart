import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:socbay/utils/context_extension.dart';

import '../data/model/banner_model.dart';
import '../utils/image_util.dart';

class BannerSliderWidget extends StatefulWidget {
  const BannerSliderWidget({Key? key, required this.banners}) : super(key: key);

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
          url: widget.banners[0].image ?? '',
          width: width,
          height: 200,
          fit: BoxFit.cover),
      child: CarouselSlider(
        options: CarouselOptions(
            height: 200.0,
            autoPlay: true,
            initialPage: 0,
            viewportFraction: 1.0,
            enlargeCenterPage: false,
            autoPlayAnimationDuration: const Duration(microseconds: 500)),
        items: widget.banners.map((i) {
          return ImageUtil.loadNetWorkImage(
              url: i.image ?? '', width: width, height: 150, fit: BoxFit.cover);
        }).toList(),
      ),
    );
  }
}
