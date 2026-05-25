import 'package:flutter/cupertino.dart';
import 'package:socbay/utils/context_extension.dart';

import '../utils/color_util.dart';

class StatusBarColorWidget extends StatelessWidget {
  final Color color;

  const StatusBarColorWidget({
    super.key,
    this.color = ColorUtil.bangladeshGreen,
  });

  @override
  Widget build(BuildContext context) {
    return Container(color: color, height: context.statusBarHeight);
  }
}
