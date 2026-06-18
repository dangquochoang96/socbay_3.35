import 'package:flutter/material.dart';
import 'package:socbay/utils/color_util.dart';

class DefaultOutlinedButton extends StatelessWidget {
  final void Function() onPressed;
  final String? text;
  final Widget? child;
  final EdgeInsetsGeometry padding;
  final Color? textColor;

  const DefaultOutlinedButton({
    super.key,
    required this.onPressed,
    this.text,
    this.child,
    this.textColor = ColorUtil.bangladeshGreen,
    this.padding = const EdgeInsets.symmetric(horizontal: 12),
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: ColorUtil.bangladeshGreen),
        padding: padding,
      ),
      child: child ?? Text('$text', style: TextStyle(color: textColor)),
    );
  }
}

class DefaultButton extends StatelessWidget {
  const DefaultButton({
    super.key,
    required this.onPressed,
    this.color = ColorUtil.bangladeshGreen,
    this.textColor = Colors.white,
    this.padding = EdgeInsets.zero,
    this.enabled = true,
    this.text,
    this.child,
    this.borderRadius,
    this.width,
    this.height,
  });
  final void Function()? onPressed;
  final String? text;
  final Widget? child;
  final EdgeInsetsGeometry padding;
  final Color color;
  final Color textColor;
  final BorderRadius? borderRadius;
  final double? width;
  final double? height;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: TextButton(
        onPressed: enabled ? onPressed : null,
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius ?? BorderRadius.circular(8),
          ),
          backgroundColor: enabled ? color : ColorUtil.silverChalice,
          padding: padding,
        ),
        child: child ?? Text('$text', style: TextStyle(color: textColor)),
      ),
    );
  }
}
