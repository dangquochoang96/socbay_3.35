import 'package:intl/intl.dart';
import 'package:socbay/data/model/order_filter_core_model.dart';
import 'package:socbay/data/model/order_payment_model.dart';
import 'package:socbay/data/model/user_model.dart';
import 'package:socbay/utils/logger_util.dart';

class OrderDetailModel {
  final int? id;
  final String? status;
  final String? userId;
  final String? type;
  final String? price;
  final String? chietKhau;
  final String? tichDiem;
  final String? truTichDiem;
  final String? vatAmount;
  final String? ghichu;
  final String? rate;
  final String? comment;
  final String? createdAt;
  final String? updatedAt;
  final String? origin;
  final String? typePayment;
  final String? paymentStatus;
  final String? saleId;
  final List<OrderFilterCoreModel>? orderFilterCoresModel;
  final String? tvNextInsteadDate;
  final String? tvInsteadDate;
  final DateTime? dateOrder;
  final UserModel? staff;
  final UserModel? user;
  final List<String>? images;
  final String? productId;
  final String? address;
  final List<OrderPaymentModel>? orderPayment;
  final String? code;
  final String? orderCode;
  OrderDetailModel({
    this.id,
    this.status,
    this.userId,
    this.type,
    this.price,
    this.chietKhau,
    this.tichDiem,
    this.truTichDiem,
    this.vatAmount,
    this.ghichu,
    this.rate,
    this.comment,
    this.createdAt,
    this.updatedAt,
    this.origin,
    this.typePayment,
    this.paymentStatus,
    this.saleId,
    this.orderFilterCoresModel,
    this.tvNextInsteadDate,
    this.tvInsteadDate,
    this.dateOrder,
    this.staff,
    this.user,
    this.images,
    this.productId,
    this.address,
    this.orderPayment,
    this.code,
    this.orderCode,
  });

  factory OrderDetailModel.fromJson(
    Map<String, dynamic> json,
  ) => OrderDetailModel(
    id: _asInt(json['id']),
    status: _asString(json['status']),
    userId: _asString(json['user_id']),
    type: _asString(json['type']),
    price: _asString(json['price']),
    chietKhau: _asString(json['chiet_khau']),
    tichDiem: _asString(json['tich_diem']),
    truTichDiem: _asString(json['tru_tich_diem']),
    vatAmount: _asString(json['vat']),
    ghichu: _asString(json['ghichu']),
    rate: _asString(json['rate']),
    comment: _asString(json['comment']),
    createdAt: _asString(json['created_at']),
    updatedAt: _asString(json['updated_at']),
    origin: _asString(json['origin']),
    typePayment: _asString(json['type_payment']),
    paymentStatus: _asString(json['overall_payment_status']),
    saleId: _asString(json['sale_id']),
    address: _asString(json['address']),
    orderFilterCoresModel: (json['order_filter_core'] as List<dynamic>?)
        ?.map((e) => OrderFilterCoreModel.fromJson(e as Map<String, dynamic>))
        .toList(),
    tvNextInsteadDate:
        _asString(json['replace_date_promise']) ??
        getNextInsteadDate(json['order_filter_core'] as List<dynamic>?),
    tvInsteadDate:
        _asString(json['replace_date']) ??
        getInsteadDate(json['order_filter_core'] as List<dynamic>?),
    dateOrder: getDateOrder(json['order_filter_core'] as List<dynamic>?),
    // staff: json["staff"] != null && json["staff"][0]["staff_info"] != null
    //     ? UserModel.fromJson(
    //         json["staff"][0]["staff_info"] as Map<String, dynamic>)
    //     : null,
    staff:
        json["staff"] != null &&
            json["staff"] is List &&
            json["staff"].isNotEmpty &&
            json["staff"][0]["staff_info"] != null
        ? UserModel.fromJson(
            json["staff"][0]["staff_info"] as Map<String, dynamic>,
          )
        : null,
    user: json["user"] != null
        ? UserModel.fromJson(json["user"] as Map<String, dynamic>)
        : null,
    images: getImages(json["images"] as List<dynamic>?),
    productId: getProductId(json['order_filter_core'] as List<dynamic>?),
    orderPayment: _getOrderPayments(
      json['order_payment'] ?? json['orderPayment'] ?? json['order_payments'],
    ),
    code: _asString(json['code']),
    orderCode: _asString(json['order_code'] ?? json['order_id']),
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'status': status,
    'user_id': userId,
    'type': type,
    'price': price,
    'chiet_khau': chietKhau,
    'tich_diem': tichDiem,
    'tru_tich_diem': truTichDiem,
    'vat': vatAmount,
    'ghichu': ghichu,
    'rate': rate,
    'comment': comment,
    'created_at': createdAt,
    'updated_at': updatedAt,
    'origin': origin,
    'type_payment': typePayment,
    'payment_status': paymentStatus,
    'sale_id': saleId,
    'order_filter_core': orderFilterCoresModel,
    'address': address,
    'order_payment': orderPayment?.map((x) => x.toJson()).toList(),
    'code': code,
    'order_code': orderCode,
  };

  static List<OrderPaymentModel>? _getOrderPayments(dynamic orderPayment) {
    if (orderPayment is List) {
      return orderPayment
          .map((e) => OrderPaymentModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    if (orderPayment is Map) {
      return [
        OrderPaymentModel.fromJson(Map<String, dynamic>.from(orderPayment)),
      ];
    }
    return null;
  }

  static int? _asInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '');
  }

  static String? _asString(dynamic value) => value?.toString();
  static String getNextInsteadDate(List<dynamic>? tvNextInsteadDate) {
    try {
      var lstOrderFilterCoresModel = tvNextInsteadDate
          ?.map((e) => OrderFilterCoreModel.fromJson(e as Map<String, dynamic>))
          .toList();
      List<DateTime> dateTimes = [];
      if (lstOrderFilterCoresModel == null) {
        return "";
      }
      DateFormat inputFormat = DateFormat("dd/MM/yyyy");
      if (lstOrderFilterCoresModel.isEmpty) {
        return "";
      } else {
        for (var element in lstOrderFilterCoresModel) {
          if (!element.replaceDatePromise!.contains("-0001") &&
              element.replaceDatePromise != "") {
            dateTimes.add(inputFormat.parse(element.replaceDatePromise!));
          }
        }
      }
      if (dateTimes.isEmpty) {
        return "";
      } else {
        dateTimes.sort((a, b) => a.compareTo(b));
      }
      DateTime date = DateTime.parse(dateTimes.first.toString());
      var lastDate = DateFormat("dd/MM/yyyy").format(date).toString();
      return lastDate;
    } catch (ex) {
      LoggerUtil.log(ex.toString());
      return "";
    }
  }

  static String getInsteadDate(List<dynamic>? tvNextInsteadDate) {
    try {
      var lstOrderFilterCoresModel = tvNextInsteadDate
          ?.map((e) => OrderFilterCoreModel.fromJson(e as Map<String, dynamic>))
          .toList();
      List<DateTime> dateTimes = [];
      if (lstOrderFilterCoresModel == null) {
        return "";
      }
      DateFormat inputFormat = DateFormat("dd/MM/yyyy");
      if (lstOrderFilterCoresModel.isEmpty) {
        return "";
      } else {
        for (var element in lstOrderFilterCoresModel) {
          if (!element.replaceDate!.contains("-0001") &&
              element.replaceDate != "") {
            dateTimes.add(inputFormat.parse(element.replaceDate!));
          }
        }
      }
      if (dateTimes.isEmpty) {
        return "";
      } else {
        dateTimes.sort((a, b) => a.compareTo(b));
      }
      DateTime date = DateTime.parse(dateTimes.last.toString());
      var lastDate = DateFormat("dd/MM/yyyy").format(date).toString();
      return lastDate;
    } catch (ex) {
      LoggerUtil.log(ex.toString());
      return "";
    }
  }

  static DateTime? getDateOrder(List<dynamic>? tvNextInsteadDate) {
    try {
      var lstOrderFilterCoresModel = tvNextInsteadDate
          ?.map((e) => OrderFilterCoreModel.fromJson(e as Map<String, dynamic>))
          .toList();
      List<DateTime> dateTimes = [];
      if (lstOrderFilterCoresModel == null) {
        return null;
      }
      //DateFormat inputFormat = DateFormat("dd/MM/yyyy");
      if (lstOrderFilterCoresModel.isEmpty) {
        return null;
      } else {
        for (var element in lstOrderFilterCoresModel) {
          if (!element.updatedAt!.contains("-0001") &&
              element.updatedAt != "") {
            dateTimes.add(DateTime.parse(element.updatedAt!));
          }
        }
      }
      if (dateTimes.isEmpty) {
        return null;
      } else {
        dateTimes.sort((a, b) => a.compareTo(b));
      }

      return dateTimes.last;
    } catch (ex) {
      LoggerUtil.log(ex.toString());
      return null;
    }
  }

  static List<String> getImages(List<dynamic>? images) {
    List<String> imgs = [];
    if (images == null) {
      return imgs;
    }
    try {
      imgs = List<String>.from(images.map((e) => e["image_link"]));
    } catch (exception) {
      LoggerUtil.log(exception.toString());
    }
    return imgs;
  }

  static String? getProductId(List<dynamic>? tvNextInsteadDate) {
    try {
      if (tvNextInsteadDate?[0]["order_detail"] != null) {
        return tvNextInsteadDate?[0]["order_detail"]["product_id"];
      }
      return "";
    } catch (ex) {
      LoggerUtil.log(ex.toString());
      return null;
    }
  }
}
