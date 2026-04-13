import 'package:flutter/material.dart';
import 'package:socbay/widgets/text_field_default.dart';

import '../../constants/constants.dart';
import '../../utils/color_util.dart';
import '../../utils/image_util.dart';
import '../button_widget.dart';

class CustomInputDialog {
  static void show(
    BuildContext context, {
    String title = '',
    String asset = '',
    String leftText = '',
    String rightText = '',
    bool isLeftPositive = false,
    bool isRightPositive = false,
    bool isShowTitle = true,
    bool isShowButtonClose = true,
    Function? leftAction,
    void Function(String value)? rightAction,
    Function? backListener,
    Color? colorBackground,
  }) {
    showDialog(
        barrierColor: Colors.black12.withOpacity(0.75),
        context: context,
        barrierDismissible: false,
        builder: (ctx) {
          return _CustomInputDialogWidget(
            context: ctx,
            title: title,
            asset: asset,
            leftText: leftText,
            rightText: rightText,
            isLeftPositive: isLeftPositive,
            isRightPositive: isRightPositive,
            isShowTitle: isShowTitle,
            isShowButtonClose: isShowButtonClose,
            leftAction: leftAction,
            rightAction: rightAction,
            backListener: backListener,
            colorBackground: colorBackground,
          );
        }).then((value) => backListener);
  }
}

class _CustomInputDialogWidget extends StatelessWidget {
  final BuildContext context;
  final String title;
  final String asset;
  final bool isLeftPositive;
  final bool isRightPositive;
  final bool isShowTitle;
  final bool isShowButtonClose;
  final String leftText;
  final String rightText;
  final Function? leftAction;
  final Function(String value)? rightAction;
  final Function? backListener;
  final Color? colorBackground;

  const _CustomInputDialogWidget(
      {required this.context,
      required this.title,
      required this.asset,
      required this.isLeftPositive,
      required this.isRightPositive,
      required this.isShowTitle,
      required this.isShowButtonClose,
      required this.leftText,
      required this.rightText,
      this.leftAction,
      this.rightAction,
      this.backListener,
      this.colorBackground});

  @override
  Widget build(BuildContext context) {
    TextEditingController _feedbackController = TextEditingController();
    return WillPopScope(
        child: Material(
          type: MaterialType.transparency,
          borderOnForeground: false,
          child: Center(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: colorBackground ?? ColorUtil.white,
              ),
              padding: const EdgeInsets.only(bottom: 20),
              margin: const EdgeInsets.symmetric(horizontal: paddingHorizontal),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isShowTitle)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 40),
                        Expanded(
                            child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            title,
                            style: const TextStyle(fontSize: 20),
                            textAlign: TextAlign.center,
                          ),
                        )),
                        Visibility(
                          visible: isShowButtonClose,
                          replacement: const SizedBox(width: 40),
                          child: ButtonWidget(
                              padding: const EdgeInsets.all(16),
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: ImageUtil.loadAssetsImage(
                                fileName: 'ic_close.svg',
                                color: ColorUtil.bangladeshGreen,
                              )),
                        )
                      ],
                    ),
                  title.isNotEmpty
                      ? const Divider(
                          color: ColorUtil.bangladeshGreen, height: 0)
                      : const SizedBox(),
                  const SizedBox(height: 16),
                  asset.isNotEmpty
                      ? ImageUtil.loadAssetsImage(fileName: asset)
                      : const SizedBox(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 16),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 400),
                          child: SingleChildScrollView(
                            child: TextFieldDefault(
                              controller: _feedbackController,
                              maxLines: 5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: rightText.isEmpty
                              ? MainAxisAlignment.center
                              : MainAxisAlignment.spaceBetween,
                          children: [
                            Visibility(
                                visible: leftText.isNotEmpty,
                                child: _buildButton(
                                    text: leftText,
                                    isPositive: isLeftPositive,
                                    action: leftAction)),
                            const SizedBox(width: 16),
                            Visibility(
                                visible: rightText.isNotEmpty,
                                child: _buildButton(
                                    text: rightText,
                                    isPositive: isRightPositive,
                                    action: rightAction)),
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
        onWillPop: () async {
          if (backListener != null) {
            backListener!();
            return false;
          }
          return false;
        });
  }

  Widget _buildButton({text, isPositive, action}) {
    return rightText.isNotEmpty
        ? Expanded(child: _button(isPositive, action, text))
        : SizedBox(
            width: 150,
            child: _button(isPositive, action, text),
          );
  }

  StatelessWidget _button(isPositive, action, text) {
    return ButtonWidget(
        color: isPositive ? ColorUtil.bangladeshGreen : Colors.grey,
        borderRadius: BorderRadius.circular(30),
        padding: const EdgeInsets.symmetric(vertical: 10),
        onTap: () {
          if (action == null) {
            Navigator.pop(context);
          } else {
            action();
          }
        },
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16, color: Colors.white),
        ));
  }
}
