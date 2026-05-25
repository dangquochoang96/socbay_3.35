import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/color_util.dart';

const BorderRadius borderTextField = BorderRadius.all(Radius.circular(8));

const OutlineInputBorder _outlineInputBorder = OutlineInputBorder(
  borderRadius: borderTextField,
  borderSide: BorderSide(width: 1, color: ColorUtil.bangladeshGreen),
);

class TextFieldDefault extends StatefulWidget {
  final TextEditingController? controller;
  final int millisecondDurationDebounce;
  final void Function(String)? onChanged;
  final void Function(String)? onChangedDebounce;
  final void Function(String)? onSubmitted;
  final TextStyle? style;
  final InputDecoration decoration;

  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final FocusNode? focusNode;
  final Color? cursorColor;
  final TextInputAction? textInputAction;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? hintText;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final TextAlign textAlign;
  final EdgeInsets? contentPadding;
  final bool autoFocus;
  final bool enabled;
  final Widget? label;

  const TextFieldDefault({
    super.key,
    this.decoration = const InputDecoration(),
    this.millisecondDurationDebounce = 500,
    this.autoFocus = false,
    this.enabled = true,
    this.textAlign = TextAlign.start,
    this.controller,
    this.onChanged,
    this.onChangedDebounce,
    this.onSubmitted,
    this.style,
    this.focusNode,
    this.cursorColor,
    this.textInputAction,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.keyboardType,
    this.inputFormatters,
    this.hintText,
    this.suffixIcon,
    this.prefixIcon,
    this.contentPadding,
    this.label,
  });

  @override
  State<StatefulWidget> createState() => _TextFiledDebounceState();
}

class _TextFiledDebounceState extends State<TextFieldDefault> {
  Timer? _debounce;

  @override
  Widget build(BuildContext context) {
    return TextField(
      enabled: widget.enabled,
      textInputAction: widget.textInputAction,
      autofocus: widget.autoFocus,
      textAlign: widget.textAlign,
      keyboardType: widget.keyboardType,
      inputFormatters: widget.inputFormatters,
      cursorColor: widget.cursorColor ?? ColorUtil.bangladeshGreen,
      focusNode: widget.focusNode,
      controller: widget.controller,
      maxLines: widget.maxLines,
      maxLength: widget.maxLength,
      minLines: widget.minLines,
      onChanged: (String s) {
        widget.onChanged != null ? widget.onChanged!(s) : null;
        if (widget.onChangedDebounce != null) {
          if (_debounce?.isActive ?? false) _debounce?.cancel();
          _debounce = Timer(
              Duration(milliseconds: widget.millisecondDurationDebounce), () {
            widget.onChangedDebounce!(s);
          });
        }
      },
      onSubmitted: widget.onSubmitted,
      style: widget.style,
      decoration: widget.decoration.copyWith(
        label: widget.label,
        counterText: '',
        fillColor: ColorUtil.transparent,
        contentPadding: widget.contentPadding ??
            const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
        disabledBorder: _outlineInputBorder,
        border: _outlineInputBorder,
        enabledBorder: _outlineInputBorder,
        focusedBorder: _outlineInputBorder.copyWith(
          borderSide: const BorderSide(width: 1, color: ColorUtil.primary),
        ),
        filled: true,
        hintStyle:
            const TextStyle(color: ColorUtil.silverChalice, fontSize: 14),
        hintText: widget.hintText,
        suffixIcon: widget.suffixIcon,
        prefixIcon: widget.prefixIcon,
      ),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
