import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../constants/assets_path.dart';

class ImageUtil {
  static Widget loadNetWorkImage(
      {required String url,
      BoxFit fit = BoxFit.cover,
      required double height,
      double? width,
      String placeHolder = AssetsPath.imgPlaceholder}) {
    Widget placeholder;
    if (placeHolder.endsWith('.svg')) {
      placeholder = SvgPicture.asset(
        placeHolder,
        height: height,
        width: width,
        fit: fit,
      );
    } else {
      placeholder = Image.asset(
        placeHolder,
        fit: fit,
        height: height,
        width: width,
      );
    }

    if (url.isEmpty) {
      return placeholder;
    }

    // Load network image
    if (url.contains('http')) {
      if (url.endsWith('.svg')) {
        return SvgPicture.network(
          url,
          fit: fit,
          height: height,
          width: width,
          placeholderBuilder: (context) {
            return placeholder;
          },
        );
      } else {
        return CachedNetworkImage(
          imageUrl: url,
          fit: fit,
          height: height,
          width: width,
          placeholder: (context, url) {
            return placeholder;
          },
          errorWidget: (ctx, url, error) {
            return placeholder;
          },
        );
      }
    }
    return placeholder;
  }

  static Widget loadAssetsImage({
    required String fileName,
    Key? key,
    double? width,
    double? height,
    Color? color,
    BoxFit fit = BoxFit.contain,
    Alignment alignment = Alignment.center,
    bool fullPath = false,
  }) {
    if (fileName.endsWith('.svg')) {
      return SvgPicture.asset(
        fullPath ? fileName : assetImg(fileName),
        width: width,
        height: height,
        fit: fit,
        color: color,
        alignment: alignment,
        key: key,
      );
    } else {
      return Image.asset(
        fullPath ? fileName : assetImg(fileName),
        width: width,
        height: height,
        fit: fit,
        color: color,
        alignment: alignment,
      );
    }
  }

}

String assetImg(String fileName) {
  return 'assets/images/$fileName';
}

String assetAnimation(String fileName) {
  return 'assets/lottie/$fileName';
}
