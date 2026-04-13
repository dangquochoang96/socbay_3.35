import 'package:flutter/material.dart';

import '../constants/constants.dart';
import '../utils/color_util.dart';
import 'button_widget.dart';

class HeaderCardWidget extends StatelessWidget {
  final String text;
  final bool isViewMore;
  final void Function()? onViewMore;

  const HeaderCardWidget({
    Key? key,
    required this.text,
    this.isViewMore = true,
    this.onViewMore,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: paddingHorizontal, vertical: 8),
      decoration: const BoxDecoration(
          color: ColorUtil.bangladeshGreen,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10), topRight: Radius.circular(10))),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  overflow: TextOverflow.ellipsis),
            ),
          ),
          const SizedBox(width: 6),
          if (isViewMore)
            ButtonWidget(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              onTap: onViewMore,
              child: const Text("Xem thêm",
                  style: TextStyle(
                      fontWeight: FontWeight.w300,
                      fontStyle: FontStyle.italic,
                      fontSize: 13,
                      color: Colors.white)),
            )
        ],
      ),
    );
  }
}
