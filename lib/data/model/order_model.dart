import 'package:socbay/data/model/machine_model.dart';
import 'package:socbay/data/model/order_filter_core_model.dart';
import 'package:socbay/data/model/product_model.dart';
import 'package:socbay/data/model/order_rent_model.dart';

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

  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
        id: json['id'] as int?,
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
        product: json['product'] != null
            ? MachineModel.fromJson(json['product'] as Map<String, dynamic>)
            : null,
        orderFilterCoresModel: (json['order_filter_cores'] as List<dynamic>?)
            ?.map(
                (e) => OrderFilterCoreModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        orderRent: json['orderRent'] != null
            ? OrderRent.fromJson(json['orderRent'] as Map<String, dynamic>)
            : null,
        proad: json['proad'] != null
            ? ProductModel.fromJson(json['proad'] as Map<String, dynamic>)
            : null,
      );

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
