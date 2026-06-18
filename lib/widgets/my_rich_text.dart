import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyRichText extends StatelessWidget {
  const MyRichText({
    super.key,
    required this.firstText,
    required this.secondText,
    required this.firstTextStyle,
    required this.secondTextStyle,
    this.onTapSecond,
    this.flexStart = 0,
    this.flexEnd = 1,
    this.mainAxisAlignment = MainAxisAlignment.center,
  });
  final String firstText;
  final String secondText;
  final TextStyle firstTextStyle;
  final TextStyle secondTextStyle;
  final void Function()? onTapSecond;
  final MainAxisAlignment mainAxisAlignment;
  final int flexStart;
  final int flexEnd;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: mainAxisAlignment,
      children: [
        Flexible(
          flex: flexStart,
          child: Text(firstText, style: firstTextStyle),
        ),
        Flexible(
          flex: flexEnd,
          child: GestureDetector(
            onTap: onTapSecond,
            child: Text(secondText, style: secondTextStyle),
          ),
        ),
      ],
    );
  }
}
