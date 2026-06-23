// To parse this JSON data, do
//
//     final retailOrder = retailOrderFromJson(jsonString);

import 'dart:convert';

import 'package:socbay/data/model/list_image_model.dart';
import 'package:socbay/data/model/product_model.dart';
import 'package:socbay/data/model/retail_warehouse_model.dart';
import 'package:socbay/data/model/user_model.dart';

List<RetailOrder> listRetailOrderFromJson(dynamic str) =>
    List<RetailOrder>.from(str.map((x) => RetailOrder.fromJson(x)));
RetailOrder retailOrderFromJson(String str) =>
    RetailOrder.fromJson(json.decode(str));
String retailOrderToJson(RetailOrder data) => json.encode(data.toJson());

String? _asString(dynamic value) => value?.toString();

List<NotesTag> listNotesTagFromJson(List<dynamic> json) {
  return json.map((x) => NotesTag.fromJson(x)).toList();
}

class NotesTag {
  String? userId;
  String? createdBy;
  String? noteText;
  NotesTag({this.userId, this.createdBy, this.noteText});
  factory NotesTag.fromJson(Map<String, dynamic> json) => NotesTag(
    userId: json["user_id"],
    createdBy: json["created_by"],
    noteText: json["note_text"],
  );
  Map<String, dynamic> toJson() => {
    "user_id": userId,
    "created_by": createdBy,
    "note_text": noteText,
  };
}

class RetailOrder {
  int? id;
  String? code;
  String? codeIndex;
  String? customerId;
  String? userId;
  String? saleId;
  String? orderDate;
  String? type;
  String? status;
  String? note;
  String? isExpress;
  List<ReturnImages>? notesFiles;
  List<NotesTag>? notesTags;
  String? orderUserName;
  String? orderUserAddress;
  String? orderUserPhone;
  String? orderUserNote;
  String? userHouse;
  String? userCommune;
  String? userDistrict;
  String? userCity;
  String? typeDiscount;
  String? discount;
  String? vat;
  String? billImage;
  dynamic shipmentAssignmentStatus;
  String? userAssignName;
  List<ReturnImages>? returnImages;
  List<ReturnImages>? imagesConfirm;
  DateTime? createdAt;
  DateTime? updatedAt;
  UserModel? customer;
  UserModel? users;
  UserModel? sale;
  List<RetailOrderDetails>? orderdetails;
  List<RetailPayment>? retailPayment;
  List<StatusLogs>? statusLogs;
  RetailOrderPack? retailOrderPack;
  RetailOrderShipment? retailOrderShipment;
  RetailOrderWarehouse? retailOrderWarehouse;

  RetailOrder({
    this.id,
    this.code,
    this.codeIndex,
    this.customerId,
    this.userId,
    this.saleId,
    this.orderDate,
    this.type,
    this.status,
    this.note,
    this.isExpress,
    this.notesFiles,
    this.notesTags,
    this.orderUserName,
    this.orderUserAddress,
    this.orderUserPhone,
    this.orderUserNote,
    this.userHouse,
    this.userCommune,
    this.userDistrict,
    this.userCity,
    this.typeDiscount,
    this.discount,
    this.vat,
    this.billImage,
    this.shipmentAssignmentStatus,
    this.userAssignName,
    this.imagesConfirm,
    this.returnImages,
    this.createdAt,
    this.updatedAt,
    this.customer,
    this.users,
    this.sale,
    this.orderdetails,
    this.retailPayment,
    this.statusLogs,
    this.retailOrderPack,
    this.retailOrderShipment,
    this.retailOrderWarehouse,
  });

  String get statusText {
    switch (status) {
      case '-1':
        return 'Đã hủy';
      case '0':
        return 'Chưa xác nhận';
      case '1':
        return 'Đã xác nhận';
      case '2':
        return 'Đang đóng hàng';
      case '3':
        return 'Đang chuẩn bị giao hàng';
      case '4':
        return 'Hàng đang được giao';
      case '5':
        return 'Đã giao hàng thành công';
      case '6':
        return 'Giao hàng thất bại';
      case '7':
        return 'Hủy trong quá trình SX';
      case '8':
        return 'Hủy trong quá trình ĐG';
      case '9':
        return 'Hủy trong quá trình Ship';
      default:
        return 'Đang xử lý';
    }
  }

  factory RetailOrder.fromJson(Map<String, dynamic> json) => RetailOrder(
    id: json["id"],
    code: json["code"],
    codeIndex: _asString(json["code_index"]),
    customerId: _asString(json["customer_id"]),
    userId: _asString(json["user_id"]),
    saleId: _asString(json["sale_id"]),
    orderDate: json["order_date"],
    type: json["type"]?.toString(),
    status: json["status"]?.toString(),
    note: json["notes"],
    isExpress: json["is_express"]?.toString(),
    notesFiles: json["notes_files"] == null
        ? null
        : listReturnImagesFromJson(json["notes_files"]),
    notesTags: json["notes_tags"] == null
        ? null
        : listNotesTagFromJson(json["notes_tags"]),
    orderUserName: _asString(json["order_user_name"]),
    orderUserAddress: _asString(json["order_user_address"]),
    orderUserPhone: _asString(json["order_user_phone"]),
    orderUserNote: _asString(json["order_user_note"]),
    userHouse: _asString(json["user_house"]),
    userCommune: _asString(json["user_commune"]),
    userDistrict: _asString(json["user_district"]),
    userCity: _asString(json["user_city"]),
    typeDiscount: json["type_discount"]?.toString(),
    discount: json["discount"]?.toString(),
    vat: json["vat"]?.toString(),
    billImage: _asString(json["bill_image"]),
    shipmentAssignmentStatus: json["shipment_assignment_status"]?.toString(),
    userAssignName: json["assigned_user_name"]?.toString(),
    returnImages: json["return_images"] == null
        ? null
        : listReturnImagesFromJson(json["return_images"]),
    imagesConfirm: json["image_confirm"] == null
        ? null
        : listReturnImagesFromJson(json["image_confirm"]),
    createdAt: json["created_at"] == null
        ? null
        : DateTime.tryParse(json["created_at"]),
    updatedAt: json["updated_at"] == null
        ? null
        : DateTime.parse(json["updated_at"]),
    customer: json["customer"] != null
        ? UserModel.fromJson(json["customer"])
        : null,
    users: json["users"] != null ? UserModel.fromJson(json["users"]) : null,
    sale: json["sale"] != null ? UserModel.fromJson(json["sale"]) : null,
    orderdetails: json["orderdetails"] != null
        ? listRetailOrderDetailFromJson(json["orderdetails"])
        : null,
    retailPayment: json["retail_payment"] != null
        ? listRetailPaymentFromJson(json["retail_payment"])
        : null,
    statusLogs: json["status_logs"] != null
        ? listStatusLogsFromJson(json["status_logs"])
        : null,
    retailOrderPack: json["pack"] != null
        ? RetailOrderPack.fromJson(json["pack"])
        : null,
    retailOrderShipment: json["shipment"] != null
        ? RetailOrderShipment.fromJson(json["shipment"])
        : null,
    retailOrderWarehouse: json["retail_warehouse"] != null
        ? RetailOrderWarehouse.fromJson(json["retail_warehouse"])
        : null,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "code": code,
    "code_index": codeIndex,
    "customer_id": customerId,
    "user_id": userId,
    "sale_id": saleId,
    "order_date": orderDate,
    "type": type,
    "status": status,
    "note": note,
    "is_express": isExpress,
    "order_user_name": orderUserName,
    "order_user_address": orderUserAddress,
    "order_user_phone": orderUserPhone,
    "order_user_note": orderUserNote,
    "user_house": userHouse,
    "user_commune": userCommune,
    "user_district": userDistrict,
    "user_city": userCity,
    "type_discount": typeDiscount,
    "discount": discount,
    "vat": vat,
    "bill_image": billImage,
    "shipment_assignment_status": shipmentAssignmentStatus,
    "assigned_user_name": userAssignName,
  };
}

List<RetailOrderDetails> listRetailOrderDetailFromJson(dynamic str) =>
    List<RetailOrderDetails>.from(
      str.map((x) => RetailOrderDetails.fromJson(x)),
    );
RetailOrderDetails retailOrderDetailFromJson(String str) =>
    RetailOrderDetails.fromJson(json.decode(str));
String retailOrderDetailToJson(RetailOrderDetails data) =>
    json.encode(data.toJson());

class RetailOrderDetails {
  int? id;
  String? orderId;
  String? productId;
  String? quantity;
  String? unitPrice;
  String? amount;
  String? type;
  ProductModel? product;

  RetailOrderDetails({
    this.id,
    this.orderId,
    this.productId,
    this.quantity,
    this.unitPrice,
    this.amount,
    this.type,
    this.product,
  });

  String get typeText {
    switch (type) {
      case '0':
        return 'Bộ';
      case '1':
        return 'Cái';
      default:
        return 'Bộ';
    }
  }

  factory RetailOrderDetails.fromJson(Map<String, dynamic> json) =>
      RetailOrderDetails(
        id: json["id"],
        orderId: _asString(json["order_id"]),
        productId: _asString(json["product_id"]),
        quantity: _asString(json["quantity"]),
        unitPrice: _asString(json["unit_price"]),
        amount: _asString(json["amount"]),
        type: _asString(json["type"]),
        product: json["product"] != null
            ? ProductModel.fromJson(json["product"])
            : null,
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "order_id": orderId,
    "product_id": productId,
    "quantity": quantity,
    "unit_price": unitPrice,
    "amount": amount,
    "type": type,
    "product": product?.toJson(),
  };
}

List<RetailPayment> listRetailPaymentFromJson(dynamic str) =>
    List<RetailPayment>.from(str.map((x) => RetailPayment.fromJson(x)));
RetailPayment retailPaymentFromJson(String str) =>
    RetailPayment.fromJson(json.decode(str));
String retailPaymentToJson(RetailPayment data) => json.encode(data.toJson());

class RetailPayment {
  String? retailOrderId;
  String? amount;
  String? notes;

  RetailPayment({this.retailOrderId, this.amount, this.notes});

  factory RetailPayment.fromJson(Map<String, dynamic> json) => RetailPayment(
    retailOrderId: _asString(json["retail_order_id"]),
    amount: _asString(json["amount"]),
    notes: _asString(json["notes"]),
  );

  Map<String, dynamic> toJson() => {
    "retail_order_id": retailOrderId,
    "amount": amount,
    "notes": notes,
  };
}

List<StatusLogs> listStatusLogsFromJson(dynamic str) =>
    List<StatusLogs>.from(str.map((x) => StatusLogs.fromJson(x)));
StatusLogs statusLogsFromJson(String str) =>
    StatusLogs.fromJson(json.decode(str));
String statusLogsToJson(StatusLogs data) => json.encode(data.toJson());

class StatusLogs {
  String? retailOrderId;
  String? status;
  String? createdAt;

  StatusLogs({this.retailOrderId, this.status, this.createdAt});

  String get statusText {
    switch (status) {
      case '-1':
        return 'Đã hủy';
      case '0':
        return 'Chưa xác nhận';
      case '1':
        return 'Đã xác nhận';
      case '2':
        return 'Đang đóng hàng';
      case '3':
        return 'Đang chuẩn bị giao hàng';
      case '4':
        return 'Hàng đang được giao';
      case '5':
        return 'Đã giao hàng thành công';
      case '6':
        return 'Giao hàng thất bại';
      case '7':
        return 'Hủy trong quá trình SX';
      case '8':
        return 'Hủy trong quá trình ĐG';
      case '9':
        return 'Hủy trong quá trình Ship';
      default:
        return 'Đang xử lý';
    }
  }

  factory StatusLogs.fromJson(Map<String, dynamic> json) => StatusLogs(
    retailOrderId: _asString(json["retail_order_id"]),
    status: _asString(json["status"]),
    createdAt: _asString(json["created_at"]),
  );

  Map<String, dynamic> toJson() => {
    "retail_order_id": retailOrderId,
    "status": status,
    "created_at": createdAt,
  };
}

List<RetailPaymentUser> listRetailPaymentUserFromJson(dynamic str) =>
    List<RetailPaymentUser>.from(str.map((x) => RetailPaymentUser.fromJson(x)));
RetailPaymentUser retailPaymentUserFromJson(String str) =>
    RetailPaymentUser.fromJson(json.decode(str));
String retailPaymentUserToJson(RetailPaymentUser data) =>
    json.encode(data.toJson());

class RetailPaymentUser {
  String? userId;
  String? status;
  String? amount;
  String? notes;
  DateTime? createdAt;
  List<RetailPaymentUserImages>? retailPaymentUserImages;

  RetailPaymentUser({
    this.userId,
    this.status,
    this.amount,
    this.notes,
    this.createdAt,
    this.retailPaymentUserImages,
  });

  factory RetailPaymentUser.fromJson(Map<String, dynamic> json) =>
      RetailPaymentUser(
        userId: _asString(json["user_id"]),
        status: _asString(json["status"]),
        amount: _asString(json["amount"]),
        notes: _asString(json["notes"]),
        createdAt: json["created_at"] == null
            ? null
            : DateTime.tryParse(json["created_at"]),
        retailPaymentUserImages: json["images"] != null
            ? listRetailPaymentUserImagesFromJson(json["images"])
            : null,
      );

  Map<String, dynamic> toJson() => {
    "user_id": userId,
    "status": status,
    "amount": amount,
    "notes": notes,
  };
}

List<RetailPaymentUserImages> listRetailPaymentUserImagesFromJson(
  dynamic str,
) => List<RetailPaymentUserImages>.from(
  str.map((x) => RetailPaymentUserImages.fromJson(x)),
);
RetailPaymentUserImages retailPaymentUserImagesFromJson(String str) =>
    RetailPaymentUserImages.fromJson(json.decode(str));
String retailPaymentUserImagesToJson(RetailPaymentUserImages data) =>
    json.encode(data.toJson());

class RetailPaymentUserImages {
  String? paymentUserId;
  String? imageBill;

  RetailPaymentUserImages({this.paymentUserId, this.imageBill});

  factory RetailPaymentUserImages.fromJson(Map<String, dynamic> json) =>
      RetailPaymentUserImages(
        paymentUserId: _asString(json["payment_user_id"]),
        imageBill: _asString(json["image_bill"]),
      );

  Map<String, dynamic> toJson() => {
    "payment_user_id": paymentUserId,
    "image_bill": imageBill,
  };
}
