import 'package:socbay/data/model/order_filter_core_model.dart';
import 'dart:convert';

BillData billDataFromJson(String str) => BillData.fromJson(json.decode(str));

String billDataToJson(BillData data) => json.encode(data.toJson());

class BillData {
  int? usernameId;
  String? saleId;
  String? name;
  String? phone;
  String? address;
  String? addressSP;
  String? email;
  String? staff;
  List<OrderFilterCoreModel> lstNew;
  List<OrderFilterCoreModel> lstMaintain;
  int? productId;
  int? newProductId;
  int subSavePoint;
  int total;
  int discount;
  int totalPay;
  int savePoint;
  int paymentType;
  int? vat;
  List<String>? images;
  String? ghichu;

  BillData({
    this.usernameId,
    this.saleId,
    this.name,
    this.phone,
    this.address,
    this.addressSP,
    this.email,
    this.staff,
    required this.lstNew,
    required this.lstMaintain,
    this.productId,
    this.newProductId,
    required this.subSavePoint,
    required this.total,
    required this.discount,
    required this.totalPay,
    required this.savePoint,
    required this.paymentType,
    this.vat,
    this.images,
    this.ghichu,
  });

  factory BillData.fromJson(Map<String, dynamic> json) => BillData(
    usernameId: json["usernameId"],
    saleId: json["saleId"],
    name: json["name"],
    phone: json["phone"],
    address: json["address"],
    addressSP: json["addressSP"],
    email: json["email"],
    staff: json["staff"],
    lstNew: json["orderFilterCoresModel"] == null
        ? []
        : List<OrderFilterCoreModel>.from(
            json["orderFilterCoresModel"]!.map((x) => x),
          ),
    lstMaintain: json["orderFilterCoresModel"] == null
        ? []
        : List<OrderFilterCoreModel>.from(
            json["orderFilterCoresModel"]!.map((x) => x),
          ),
    productId: json["productId"],
    newProductId: json["newProductId"],
    subSavePoint: json["subSavePoint"],
    total: json["total"],
    discount: json["discount"],
    totalPay: json["totalPay"],
    savePoint: json["savePoint"],
    paymentType: json["paymentMethod"],
    vat: json["vat"],
    images: json["images"] == null
        ? []
        : List<String>.from(json["images"]!.map((x) => x)),
    ghichu: json["ghichu"],
  );

  Map<String, dynamic> toJson() => {
    "usernameId": usernameId,
    "saleId": saleId,
    "name": name,
    "phone": phone,
    "address": address,
    "addressSP": addressSP,
    "email": email,
    "staff": staff,
    "lstNew": List<dynamic>.from(lstNew.map((x) => x)),
    "lstMaintain": List<dynamic>.from(lstMaintain.map((x) => x)),
    "total": total,
    "discount": discount,
    "totalPay": totalPay,
    "savePoint": savePoint,
    "subSavePoint": subSavePoint,
    "paymentType": paymentType,
    "vat": vat,
    "images": images == null ? [] : List<dynamic>.from(images!.map((x) => x)),
    "ghichu": ghichu,
  };
}
