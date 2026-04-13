import 'package:intl/intl.dart';

class OrderFilterCoreModel {
  final int? id;
  final String? orderDetailId;
  final String? orderId;
  String? name;
  final String? price;
  final String? firstId;
  final String? replaceDate;
  late String? replaceDatePromise;
  final String? createdAt;
  final String? updatedAt;
  final String? product;

  String createdDateConvert() {
    if (createdAt == null) {
      return "";
    }
    DateTime date = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z").parse(createdAt!);
    return DateFormat("dd/MM/yyyy").format(date);
  }

  OrderFilterCoreModel(
      {this.id,
      this.orderDetailId,
      this.orderId,
      this.name,
      this.price,
      this.firstId,
      this.replaceDate,
      this.createdAt,
      this.updatedAt,
      this.replaceDatePromise,
      this.product});

  factory OrderFilterCoreModel.fromJson(Map<String, dynamic> json) =>
      OrderFilterCoreModel(
        id: json['id'] as int?,
        orderDetailId: json['order_detail_id'] as String?,
        orderId: json['order_id'] as String?,
        name: json['name'] as String?,
        price: json['price'] as String?,
        firstId: json['first_id'] as String?,
        replaceDate: json['replace_date'].toString().contains("-0001") ||
                json['replace_date'] == null
            ? ""
            : DateFormat("dd/MM/yyyy")
                .format(DateTime.parse(json['replace_date'].toString()))
                .toString(),
        createdAt: json['created_at'] as String?,
        updatedAt: json['updated_at'] as String?,
        replaceDatePromise: json['replace_date_promise'] == null ||
                json['replace_date_promise'].toString().contains("-0001") ||
                json['replace_date_promise'].toString() == ""
            ? ""
            : DateFormat("dd/MM/yyyy")
                .format(DateTime.parse(json['replace_date_promise'].toString()))
                .toString(),
        product: json['product'] as String?,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'order_detail_id': orderDetailId,
        'order_id': orderId,
        'name': name,
        'price': price,
        'first_id': firstId,
        'replace_date': replaceDate,
        'created_at': createdAt,
        'updated_at': updatedAt,
        'replace_date_promise': replaceDatePromise,
        'product': product
      };
}
