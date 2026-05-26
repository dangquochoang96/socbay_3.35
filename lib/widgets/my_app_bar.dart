import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/constants.dart';
import '../utils/color_util.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final double titleFontSize;
  final Widget? titleWidget;
  final Widget? leadWidget;
  final List<Widget>? actionWidgets;
  final Color backgroundColor;
  final Color shadowColor;
  final Color leadColor;
  final bool isBackNavigation;
  final PreferredSizeWidget? bottom;
  final double? titleSpacing;
  final bool centerTitle;
  final bool showShadow;
  final VoidCallback? onBack;
  final VoidCallback? onTapTitleWidget;

  final Size barSize;
  final BorderRadius borderRadius;
  final SystemUiOverlayStyle systemOverlayStyle;

  MyAppBar({
    super.key,
    this.title = '',
    this.titleFontSize = 18,
    this.titleWidget,
    this.backgroundColor = ColorUtil.bangladeshGreen,
    this.shadowColor = Colors.white,
    this.leadColor = Colors.white,
    this.isBackNavigation = true,
    this.leadWidget,
    this.actionWidgets,
    this.bottom,
    this.titleSpacing = NavigationToolbar.kMiddleSpacing,
    this.centerTitle = true,
    this.showShadow = false,
    this.onBack,
    this.onTapTitleWidget,
    this.borderRadius = BorderRadius.zero,
    this.systemOverlayStyle = systemUiOverlayStyle,
  }) : barSize = Size.fromHeight(
         kToolbarHeight + (bottom?.preferredSize.height ?? 0.0),
       );

  @override
  Size get preferredSize => Size.fromHeight(barSize.height);

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(100),
      child: AppBar(
        shape: RoundedRectangleBorder(borderRadius: borderRadius),
        title: _buildAppTitle(context),
        leading: _buildLeadButton(context),
        systemOverlayStyle: systemOverlayStyle,
        actions: actionWidgets,
        centerTitle: centerTitle,
        backgroundColor: backgroundColor,
        automaticallyImplyLeading: false,
        elevation: showShadow ? 2 : 0,
        shadowColor: shadowColor,
        titleSpacing: titleSpacing,
        bottom: bottom,
      ),
    );
  }

  Widget _buildAppTitle(BuildContext context) {
    if (titleWidget != null) {
      return GestureDetector(onTap: onTapTitleWidget, child: titleWidget);
    } else {
      return Text(title, style: const TextStyle(fontSize: 18));
    }
  }

  Widget? _buildLeadButton(BuildContext context) {
    if (isBackNavigation && leadWidget == null) {
      return IconButton(
        tooltip: "Back",
        icon: Icon(Icons.arrow_back, color: leadColor),
        onPressed: () {
          if (onBack != null) {
            onBack!();
          } else {
            Navigator.of(context).pop();
          }
        },
      );
    } else {
      return leadWidget;
    }
  }
}
