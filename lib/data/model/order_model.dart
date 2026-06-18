import 'package:socbay/data/model/machine_model.dart';
import 'package:socbay/data/model/order_filter_core_model.dart';
import 'package:socbay/data/model/product_model.dart';
import 'package:socbay/data/model/order_rent_model.dart';

int? _asInt(dynamic value) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '');
}

Map<String, dynamic>? _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return null;
}

List<dynamic>? _asList(dynamic value) {
  if (value is List<dynamic>) return value;
  if (value is List) return List<dynamic>.from(value);
  return null;
}

class OrderModel {
  final int? id;
  final String? orderId;
  final String? createdAt;
  final String? ngaymua;
  final String? updatedAt;
  final String? productId;
  final String? price;
  final String? count;
  final String? filterCoreLevel;
  final String? address;
  final String? orderTypeLabel;
  final MachineModel? product;
  final List<OrderFilterCoreModel>? orderFilterCoresModel;
  final OrderRent? orderRent;
  final ProductModel? proad;

  OrderModel({
    this.id,
    this.orderId,
    this.createdAt,
    this.ngaymua,
    this.updatedAt,
    this.productId,
    this.price,
    this.count,
    this.filterCoreLevel,
    this.product,
    this.orderRent,
    this.proad,
    this.address,
    this.orderTypeLabel,
    this.orderFilterCoresModel,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final productJson = _asMap(json['product']);
    final orderFilterCoresJson = _asList(json['order_filter_cores']);
    final orderRentJson = _asMap(json['orderRent']);
    final proadJson = _asMap(json['proad']);

    return OrderModel(
      id: _asInt(json['id']),
      orderId: json['order_id'] as String?,
      createdAt: json['created_at'] as String?,
      ngaymua: json['ngaymua'] as String?,
      updatedAt: json['updated_at'] as String?,
      productId: json['product_id'] as String?,
      price: json['price'] as String?,
      count: json['count'] as String?,
      filterCoreLevel: json['filter_core_level'] as String?,
      address: json['address'] as String?,
      orderTypeLabel: json['order_type_label'] as String?,
      product: productJson != null ? MachineModel.fromJson(productJson) : null,
      orderFilterCoresModel: orderFilterCoresJson
          ?.map(_asMap)
          .whereType<Map<String, dynamic>>()
          .map((e) => OrderFilterCoreModel.fromJson(e))
          .toList(),
      orderRent: orderRentJson != null
          ? OrderRent.fromJson(orderRentJson)
          : null,
      proad: proadJson != null ? ProductModel.fromJson(proadJson) : null,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'order_id': orderId,
    'created_at': createdAt,
    'ngaymua': ngaymua,
    'updated_at': updatedAt,
    'product_id': productId,
    'price': price,
    'count': count,
    'filter_core_level': filterCoreLevel,
    'product': product,
    'proad': proad,
    'address': address,
    'order_type_label': orderTypeLabel,
    'order_filter_core': orderFilterCoresModel,
    'order_rent': orderRent,
  };
}
