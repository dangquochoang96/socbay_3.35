import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../utils/color_util.dart';

enum IndicatorType { spinKitWave }

class LoadingIndicator extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final double opacity;
  final double contentOpacity;
  final Color color;
  final String text;

  const LoadingIndicator(
      {super.key,
      required this.isLoading,
      required this.child,
      this.opacity = 0,
      this.contentOpacity = 0.5,
      this.color = Colors.grey,
      this.text = ''});

  final spinKit = const SpinKitRing(
    color: ColorUtil.white,
    lineWidth: 2.5,
    size: 32,
  );

  @override
  Widget build(BuildContext context) {
    final List<Widget> widgetList = [];
    widgetList.add(child);

    if (isLoading) {
      final modal = Stack(
        children: [
          Opacity(
            opacity: opacity,
            child: ModalBarrier(dismissible: false, color: color),
          ),
          Center(
            child: Container(
              width: text.isNotEmpty ? 200 : 100,
              height: text.isNotEmpty ? 100 : 100,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                color: ColorUtil.bangladeshGreen.withOpacity(0.5),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  spinKit,
                  Visibility(
                    visible: text.isNotEmpty,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        text,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
      widgetList.add(modal);
    }
    return Scaffold(
      body: Stack(
        children: widgetList,
      ),
    );
  }
}
