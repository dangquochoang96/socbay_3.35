import 'package:flutter/cupertino.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:socbay/constants/constants.dart';

import '../utils/color_util.dart';

class IndicatorLoadMore extends StatelessWidget {
  final EdgeInsets? padding;

  const IndicatorLoadMore({super.key, this.padding});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.symmetric(vertical: paddingVertical),
      child: const SpinKitRing(
        color: ColorUtil.bangladeshGreen,
        lineWidth: 2,
        size: 22,
      ),
    );
  }
}
