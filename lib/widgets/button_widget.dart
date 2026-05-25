import 'package:flutter/material.dart';

class ButtonWidget extends StatelessWidget {
  final Function()? onTap;
  final Widget child;
  final Color color;
  final bool isEnabled;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;

  const ButtonWidget(
      {super.key,
      required this.onTap,
      required this.child,
      this.color = Colors.transparent,
      this.borderRadius,
      this.padding = EdgeInsets.zero,
      this.margin = EdgeInsets.zero,
      this.isEnabled = true});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin,
      child: Material(
        color: isEnabled ? color : Colors.transparent,
        borderRadius: borderRadius?? BorderRadius.circular(8),
        child: InkWell(
          splashColor: isEnabled ? null : Colors.transparent,
          enableFeedback: true,
          borderRadius: borderRadius ?? BorderRadius.circular(8),
          onTap: isEnabled ? onTap : () {},
          child: Ink(
            padding: padding,
            child: InkWell(
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
