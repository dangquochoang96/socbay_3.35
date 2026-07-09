import 'dart:io';

import 'package:socbay/data/model/order_filter_core_model.dart';

abstract class StaffNewOrderEvent {
  const StaffNewOrderEvent();
}

class StaffNewOrderInitEvent extends StaffNewOrderEvent {}

class StaffNewOrderGetListProductsEvent extends StaffNewOrderEvent {}

class StaffNewOrderGetListProductsAllEvent extends StaffNewOrderEvent {}

class StaffCreateOrderEvent extends StaffNewOrderEvent {
  int? usernameId;
  String? saleId;
  int? productId;
  int? newProductId;
  int total = 0, chietKhau = 0, subSavePoint = 0, totalPay = 0, savePoint = 0;
  int paymentType = 1;
  String? vatAmount;
  String monthlyRent;
  String rentalPeriod;
  String deposits;
  DateTime rentalEndDate;
  List<OrderFilterCoreModel> lstNew = [];
  List<OrderFilterCoreModel> lstMaintain = [];
  List<String>? images;
  String? newAddress;
  String? newAddressSP;
  String? ghichu;
  int subType;
  double? cashAmount;
  double? transferAmount;
  StaffCreateOrderEvent(
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
    this.vatAmount,
    this.images,
    this.newAddress,
    this.newAddressSP,
    //new
    this.monthlyRent,
    this.rentalPeriod,
    this.deposits,
    this.rentalEndDate,
    this.ghichu,
    this.subType, {
    this.cashAmount,
    this.transferAmount,
  });
}

class StaffNewOrderUploadImageEvent extends StaffNewOrderEvent {
  final List<File> files;

  StaffNewOrderUploadImageEvent(this.files);
}

class StaffNewOrderUploadPaymentProofEvent extends StaffNewOrderEvent {
  final int orderId;
  final String notes;
  final List<File> files;
  final int? paymentStatus;

  StaffNewOrderUploadPaymentProofEvent({
    required this.orderId,
    required this.notes,
    required this.files,
    this.paymentStatus,
  });
}
