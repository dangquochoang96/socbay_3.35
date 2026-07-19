// To parse this JSON data, do
//
//     final warehouse = warehouseFromJson(jsonString);

import 'dart:convert';
import 'package:intl/intl.dart';

import 'package:socbay/data/model/product_model.dart';

Warehouse warehouseFromJson(String str) => Warehouse.fromJson(json.decode(str));
List<Warehouse> warehouseListFromJson(dynamic str) =>
    List<Warehouse>.from(str.map((x) => Warehouse.fromJson(x)));
String warehouseToJson(Warehouse data) => json.encode(data.toJson());

QuantityPrice quantityPriceFromJson(String str) =>
    QuantityPrice.fromJson(json.decode(str));
List<QuantityPrice> quantityPriceListFromJson(dynamic str) =>
    List<QuantityPrice>.from(str.map((x) => QuantityPrice.fromJson(x)));
String quantityPriceToJson(QuantityPrice data) => json.encode(data.toJson());

ListWarehouse listWarehouseFromJson(String str) =>
    ListWarehouse.fromJson(json.decode(str));
List<ListWarehouse> listWarehouselistFromJson(dynamic str) =>
    List<ListWarehouse>.from(str.map((x) => ListWarehouse.fromJson(x)));
String listWarehouseToJson(ListWarehouse data) => json.encode(data.toJson());

class QuantityPrice {
  String? price;
  dynamic quantity;

  QuantityPrice({this.price, this.quantity});

  factory QuantityPrice.fromJson(Map<String, dynamic> json) =>
      QuantityPrice(price: json["price"], quantity: json["quantity"]);

  Map<String, dynamic> toJson() => {"price": price, "quantity": quantity};

  // Helper methods để làm việc với quantity
  /// Trả về quantity dưới dạng int, null nếu không thể parse
  int? get quantityAsInt {
    if (quantity == null) return null;
    if (quantity is int) return quantity;
    if (quantity is String) {
      return int.tryParse(quantity);
    }
    return null;
  }

  /// Trả về quantity dưới dạng String
  String? get quantityAsString {
    if (quantity == null) return null;
    return quantity.toString();
  }

  /// Kiểm tra xem quantity có phải là số hợp lệ không
  bool get isValidQuantity {
    return quantityAsInt != null;
  }
}

class ListWarehouse {
  List<Warehouse>? dataWasehouse;
  List<OrderWarehouseHistories>? dataHistory;

  ListWarehouse({this.dataWasehouse, this.dataHistory});

  factory ListWarehouse.fromJson(Map<String, dynamic> json) => ListWarehouse(
    dataWasehouse: json["data_wasehouse"] == null
        ? null
        : warehouseListFromJson(json["data_wasehouse"]),
    dataHistory: json["data_history"] == null
        ? null
        : orderWarehouseHistoriesListFromJson(json["data_history"]),
  );

  Map<String, dynamic> toJson() => {
    "data_wasehouse": dataWasehouse?.map((x) => x.toJson()).toList(),
    "data_history": dataHistory?.map((x) => x.toJson()).toList(),
  };
}

class Warehouse {
  int id;
  String? userId;
  String? productId;
  String? quantityExist;
  String? quantityExport;
  List<QuantityPrice>? quantityPrices;
  String? createdAt;
  String? updatedAt;
  ProductModel? product;

  Warehouse({
    required this.id,
    this.userId,
    this.productId,
    this.quantityExist,
    this.quantityExport,
    this.quantityPrices,
    this.createdAt,
    this.updatedAt,
    this.product,
  });

  factory Warehouse.fromJson(Map<String, dynamic> json) => Warehouse(
    id: json["id"],
    userId: json["user_id"],
    productId: json["product_id"],
    quantityExist: json["quantity_exist"],
    quantityExport: json["quantity_export"],
    quantityPrices: json["quantity_prices"] == null
        ? null
        : quantityPriceListFromJson(json["quantity_prices"]),
    createdAt: json["created_at"],
    updatedAt: json["updated_at"],
    product: json["product"] == null
        ? null
        : ProductModel.fromJson(json["product"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_id": userId,
    "product_id": productId,
    "quantity_exist": quantityExist,
    "quantity_export": quantityExport,
    "quantity_prices": quantityPrices?.map((x) => x.toJson()).toList(),
    "created_at": createdAt,
    "updated_at": updatedAt,
    "product": product?.toJson(),
  };
}

OrderWarehouseHistories orderWarehouseHistoriesFromJson(String str) =>
    OrderWarehouseHistories.fromJson(json.decode(str));

List<OrderWarehouseHistories> orderWarehouseHistoriesListFromJson(
  dynamic json,
) => List<OrderWarehouseHistories>.from(
  json.map((x) => OrderWarehouseHistories.fromJson(x)),
);

String orderWarehouseHistoriesToJson(OrderWarehouseHistories data) =>
    json.encode(data.toJson());

class OrderWarehouseHistories {
  int? id;
  String? userId;
  DateTime? date;
  String? userName;
  String? userPhone;
  String? userAddress;
  String? vat;
  String? discount;
  String? totalAmount;
  List<WarehouseProduct>? products;
  String? notes;
  DateTime? createdAt;
  DateTime? updatedAt;

  OrderWarehouseHistories({
    this.id,
    this.userId,
    this.date,
    this.userName,
    this.userPhone,
    this.userAddress,
    this.vat,
    this.discount,
    this.totalAmount,
    this.products,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  factory OrderWarehouseHistories.fromJson(Map<String, dynamic> json) =>
      OrderWarehouseHistories(
        id: json["id"],
        userId: json["user_id"]?.toString(),
        date: json["date"] == null ? null : DateTime.tryParse(json["date"]),
        userName: json["user_name"],
        userPhone: json["user_phone"],
        userAddress: json["user_address"],
        vat: json["vat"]?.toString(),
        discount: json["discount"]?.toString(),
        totalAmount: json["total_amount"]?.toString(),
        products: json["products"] != null
            ? productsFromMap(json["products"])
            : null,
        notes: json["notes"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.tryParse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.tryParse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_id": userId,
    "date": date?.toIso8601String(),
    "user_name": userName,
    "user_phone": userPhone,
    "user_address": userAddress,
    "vat": vat,
    "discount": discount,
    "total_amount": totalAmount,
    "notes": notes,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };
}

WarehouseProduct productFromJson(String str) =>
    WarehouseProduct.fromJson(json.decode(str));

List<WarehouseProduct> productsFromMap(dynamic str) =>
    List<WarehouseProduct>.from(str.map((x) => WarehouseProduct.fromJson(x)));

String productToJson(WarehouseProduct data) => json.encode(data.toJson());

class WarehouseProduct {
  int? id;
  String? name;
  int? quantity;
  String? image;
  String? price;

  WarehouseProduct({this.id, this.name, this.quantity, this.image, this.price});

  factory WarehouseProduct.fromJson(Map<String, dynamic> json) =>
      WarehouseProduct(
        id: json["id"],
        name: json["name"],
        quantity: json["quantity"] is int
            ? json["quantity"]
            : int.tryParse(json["quantity"]?.toString() ?? '0'),
        image: json["image"],
        price: json["price"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "quantity": quantity,
    "image": image,
    "price": price,
  };
}

class Statistic {
  Statistic({
    this.totalOrder,
    this.totalPrice,
  });

  int? totalOrder;
  int? totalPrice;

  String formattedPrice() {
    final number = totalPrice ?? 0;
    return '${NumberFormat('#,###', 'vi_VN').format(number)} đ';
  }

  factory Statistic.fromJson(Map<String, dynamic> json) => Statistic(
        totalOrder: json["total_order"],
        totalPrice: json["total_price"] == null
            ? null
            : int.tryParse(json["total_price"].toString()),
      );

  Map<String, dynamic> toJson() => {
        "total_order": totalOrder,
        "total_price": totalPrice,
      };
}

class DestinationWarehouse {
  int id;
  String? name;
  String? address;

  DestinationWarehouse({
    required this.id,
    this.name,
    this.address,
  });

  factory DestinationWarehouse.fromJson(Map<String, dynamic> json) =>
      DestinationWarehouse(
        id: json["id"],
        name: json["name"],
        address: json["address"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "address": address,
      };
}

