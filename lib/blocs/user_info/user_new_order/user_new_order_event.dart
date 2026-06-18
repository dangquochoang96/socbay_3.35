import 'dart:io';

import 'package:socbay/data/model/order_filter_core_model.dart';

abstract class UserNewOrderEvent {
  const UserNewOrderEvent();
}

class UserNewOrderInitEvent extends UserNewOrderEvent {}

class UserNewOrderGetListProductsEvent extends UserNewOrderEvent {}

class UserNewOrderGetListProductsAllEvent extends UserNewOrderEvent {}

class UserCreateOrderEvent extends UserNewOrderEvent {
  int? productId;
  int? newProductId;
  int total = 0, chietKhau = 0, subSavePoint = 0, totalPay = 0, savePoint = 0;
  int paymentType = 1;
  List<OrderFilterCoreModel> lstNew = [];
  List<OrderFilterCoreModel> lstMaintain = [];
  List<String>? images;
  String? address;
  UserCreateOrderEvent(
    this.productId,
    this.newProductId,
    this.lstNew,
    this.lstMaintain,
    this.total,
    this.chietKhau,
    this.subSavePoint,
    this.totalPay,
    this.savePoint,
    this.paymentType,
    this.images,
  );
}

class UserNewOrderUploadImageEvent extends UserNewOrderEvent {
  final List<File> files;

  UserNewOrderUploadImageEvent(this.files);
}
