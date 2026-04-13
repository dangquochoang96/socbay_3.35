import 'package:flutter/material.dart';
import 'package:socbay/application.dart';
import 'package:socbay/paths/images.dart';
import 'package:socbay/screens/history/history_screen.dart';
import 'package:socbay/screens/home/home_screen.dart';
import 'package:socbay/screens/my_task/task_screen.dart';
import 'package:socbay/screens/my_task/task_screen_sale.dart';
import 'package:socbay/screens/product_category/product_category_screen.dart';
import 'package:socbay/utils/image_util.dart';

import '../../utils/color_util.dart';

const imageSize = 24.0;

enum TabItem {
  home,
  history,
  booking,
  myTask,
  product,
}

extension TabItemExtension on TabItem {
  String getTitle() {
    switch (this) {
      case TabItem.home:
        return "Trang chủ";
      case TabItem.history:
        if(App.instance.userApp?.isUserCustomer()==true){
          return "Nhật ký";
        }else{
          return "Ds Công việc";
        }
      case TabItem.booking:
        return "Đặt lịch";
      case TabItem.myTask:
        return "Công việc";
      case TabItem.product:
        return "Sản phẩm";
    }
  }
}

List<BottomNavigationBarItem> getTabBarItems() {
  return [
    BottomNavigationBarItem(
      label: TabItem.home.getTitle(),
      icon: _icon(Images.iconHome, false),
      activeIcon: _icon(Images.iconHome, true),
      tooltip: TabItem.home.getTitle(),
    ),
    BottomNavigationBarItem(
      label: TabItem.history.getTitle(),
      icon: _icon(Images.iconHistory, false),
      activeIcon: _icon(Images.iconHistory, true),
      tooltip: TabItem.history.getTitle(),
    ),
    BottomNavigationBarItem(
      label: TabItem.product.getTitle(),
      icon: _icon(Images.iconProduct, false),
      activeIcon: _icon(Images.iconProduct, true),
      tooltip: TabItem.product.getTitle(),
    ),
  ];
}

Widget _icon(String path, isActive) {
  return ImageUtil.loadAssetsImage(
      fileName: path,
      width: imageSize,
      height: imageSize,
      color: isActive ? ColorUtil.bangladeshGreen : Colors.grey);
}

List<Widget> getTabBarWidgetItem(BuildContext context) {
  if (App.instance.userApp?.isUserCustomer() == true) {
    return [
      const HomeScreen(),
      const HistoryScreen(),
      const ProductCategoryScreen(),
    ];
  }else if(App.instance.userApp?.isUserSale() == true){
    return [
      const HomeScreen(),
      const TaskScreenSale(),
      const ProductCategoryScreen(),
    ];
  }
  else {
    return [
      const HomeScreen(),
      const TaskScreen(),
      const ProductCategoryScreen(),
    ];
  }
}
