// To parse this JSON data, do
//
//     final retailOrderPackDetail = retailOrderPackDetailFromJson(jsonString);
//     final retailOrderPack = retailOrderPackFromJson(jsonString);
//     final retailOrderWarehouse = retailOrderWarehouseFromJson(jsonString);

import 'dart:convert';

import 'package:socbay/data/model/list_image_model.dart';
import 'package:socbay/data/model/retail_order_model.dart';
import 'package:socbay/data/model/user_profile.dart';

//RetailOrderShipmentUserImage
RetailOrderShipmentUserImage retailOrderShipmentUserImageFromJson(String str) =>
    RetailOrderShipmentUserImage.fromJson(json.decode(str));
String retailOrderShipmentUserImageToJson(RetailOrderShipmentUserImage data) =>
    json.encode(data.toJson());
//RetailOrderShipmentAssign
List<RetailOrderShipmentAssign> listRetailOrderShipmentAssignFromJson(
  dynamic str,
) => List<RetailOrderShipmentAssign>.from(
  str.map((x) => RetailOrderShipmentAssign.fromJson(x)),
);
RetailOrderShipmentAssign retailOrderShipmentAssignFromJson(String str) =>
    RetailOrderShipmentAssign.fromJson(json.decode(str));
String retailOrderShipmentAssignToJson(RetailOrderShipmentAssign data) =>
    json.encode(data.toJson());
//RetailOrderShipment
List<RetailOrderShipment> listRetailOrderShipmentFromJson(dynamic str) =>
    List<RetailOrderShipment>.from(
      str.map((x) => RetailOrderShipment.fromJson(x)),
    );
RetailOrderShipment retailOrderShipmentFromJson(String str) =>
    RetailOrderShipment.fromJson(json.decode(str));
String retailOrderShipmentToJson(RetailOrderShipment data) =>
    json.encode(data.toJson());
//RetailOrderAssUserWarehouse
List<RetailOrderAssUserWarehouse> listRetailOrderAssUserWarehouseFromJson(
  dynamic str,
) => List<RetailOrderAssUserWarehouse>.from(
  str.map((x) => RetailOrderAssUserWarehouse.fromJson(x)),
);
RetailOrderAssUserWarehouse retailOrderAssUserWarehouseFromJson(String str) =>
    RetailOrderAssUserWarehouse.fromJson(json.decode(str));
String retailOrderAssUserWarehouseToJson(RetailOrderAssUserWarehouse data) =>
    json.encode(data.toJson());
//RetailOrderAssUserPack
RetailOrderAssUserPack retailOrderAssUserPackFromJson(String str) =>
    RetailOrderAssUserPack.fromJson(json.decode(str));
String retailOrderAssUserPackToJson(RetailOrderAssUserPack data) =>
    json.encode(data.toJson());
//RetailOrderPackDetail
RetailOrderPackDetail retailOrderPackDetailFromJson(String str) =>
    RetailOrderPackDetail.fromJson(json.decode(str));
String retailOrderPackDetailToJson(RetailOrderPackDetail data) =>
    json.encode(data.toJson());
//RetailOrderPack
List<RetailOrderPack> listRetailOrderPackFromJson(dynamic str) =>
    List<RetailOrderPack>.from(str.map((x) => RetailOrderPack.fromJson(x)));
RetailOrderPack retailOrderPackFromJson(String str) =>
    RetailOrderPack.fromJson(json.decode(str));
String retailOrderPackToJson(RetailOrderPack data) =>
    json.encode(data.toJson());

String? _asString(dynamic value) => value?.toString();
//RetailOrderWarehouse
List<RetailOrderWarehouse> listRetailOrderWarehouseFromJson(dynamic str) =>
    List<RetailOrderWarehouse>.from(
      str.map((x) => RetailOrderWarehouse.fromJson(x)),
    );
RetailOrderWarehouse retailOrderWarehouseFromJson(String str) =>
    RetailOrderWarehouse.fromJson(json.decode(str));
String retailOrderWarehouseToJson(RetailOrderWarehouse data) =>
    json.encode(data.toJson());

class RetailOrderShipmentUserImage {
  int? id;
  String? retailShipmentAssigmentUserId;
  String? image;
  String? createdAt;

  RetailOrderShipmentUserImage({
    this.id,
    this.retailShipmentAssigmentUserId,
    this.image,
    this.createdAt,
  });

  factory RetailOrderShipmentUserImage.fromJson(Map<String, dynamic> json) =>
      RetailOrderShipmentUserImage(
        id: json["id"],
        retailShipmentAssigmentUserId: _asString(
          json["retail_shipment_assigment_user_id"],
        ),
        image: _asString(json["image"]),
        createdAt: _asString(json["created_at"]),
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "retail_shipment_assigment_user_id": retailShipmentAssigmentUserId,
    "image": image,
    "created_at": createdAt,
  };
}

class RetailOrderShipmentAssign {
  int? id;
  String? retailShipmentId;
  String? userId;
  String? numberPackage;
  String? pickupAddress;
  String? pickUpLat;
  String? pickUpLng;
  String? deliveryAddress;
  String? deliveryLat;
  String? deliveryLng;
  String? distance;
  String? baseShippingFee;
  String? codFee;
  String? pickupFee;
  String? note;
  String? createdAt;
  List<RetailOrderShipmentUserImage>? images;
  UserProfile? user;

  RetailOrderShipmentAssign({
    this.id,
    this.retailShipmentId,
    this.userId,
    this.numberPackage,
    this.pickupAddress,
    this.pickUpLat,
    this.pickUpLng,
    this.deliveryAddress,
    this.deliveryLat,
    this.deliveryLng,
    this.distance,
    this.baseShippingFee,
    this.codFee,
    this.pickupFee,
    this.note,
    this.createdAt,
    this.images,
    this.user,
  });

  factory RetailOrderShipmentAssign.fromJson(Map<String, dynamic> json) =>
      RetailOrderShipmentAssign(
        id: json["id"],
        retailShipmentId: _asString(json["retail_shipment_id"]),
        userId: _asString(json["user_id"]),
        numberPackage: _asString(json["number_package"]),
        pickupAddress: _asString(json["pickup_address"]),
        pickUpLat: _asString(json["pickup_lat"]),
        pickUpLng: _asString(json["pickup_lng"]),
        deliveryAddress: _asString(json["delivery_address"]),
        deliveryLat: _asString(json["delivery_lat"]),
        deliveryLng: _asString(json["delivery_lng"]),
        distance: _asString(json["distance_km"]),
        baseShippingFee: _asString(json["base_shipping_fee"]),
        codFee: _asString(json["cod_fee"]),
        pickupFee: _asString(json["pickup_fee"]),
        note: _asString(json["note"]),
        createdAt: _asString(json["created_at"]),
        images: json["ass_user_images"] == null
            ? []
            : List<RetailOrderShipmentUserImage>.from(
                json["ass_user_images"].map(
                  (x) => RetailOrderShipmentUserImage.fromJson(x),
                ),
              ),
        user: json["user"] == null ? null : UserProfile.fromJson(json["user"]),
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "retail_shipment_id": retailShipmentId,
    "user_id": userId,
    "number_package": numberPackage,
    "pickup_address": pickupAddress,
    "pickup_lat": pickUpLat,
    "pickup_lng": pickUpLng,
    "delivery_address": deliveryAddress,
    "delivery_lat": deliveryLat,
    "delivery_lng": deliveryLng,
    "distance_km": distance,
    "base_shipping_fee": baseShippingFee,
    "cod_fee": codFee,
    "pickup_fee": pickupFee,
    "note": note,
    "created_at": createdAt,
  };
}

class RetailOrderShipment {
  int? id;
  String? retailOrderId;
  String? type;
  String? status;
  String? pickupAddress;
  String? pickUpLat;
  String? pickUpLng;
  String? deliveryAddress;
  String? deliveryLat;
  String? deliveryLng;
  String? distance;
  String? baseShippingFee;
  String? codFee;
  String? pickupFee;
  String? createdAt;
  RetailOrder? retailOrder;
  List<RetailOrderShipmentAssign>? shipmentUsers;

  RetailOrderShipment({
    this.id,
    this.retailOrderId,
    this.type,
    this.status,
    this.pickupAddress,
    this.pickUpLat,
    this.pickUpLng,
    this.deliveryAddress,
    this.deliveryLat,
    this.deliveryLng,
    this.distance,
    this.baseShippingFee,
    this.codFee,
    this.pickupFee,
    this.createdAt,
    this.retailOrder,
    this.shipmentUsers,
  });

  String get statusText {
    switch (status) {
      case '0':
        return 'Đang phân công Shipper';
      case '1':
        return 'Đang giao hàng';
      case '2':
        return 'Giao hàng thành công';
      case '3':
        return 'Giao hàng thất bại';
      case '4':
        return 'Đơn hàng đã khôi phục';
      case '5':
        return 'Đơn hàng đã hoàn trả';
      default:
        return 'Đang xử lý';
    }
  }

  factory RetailOrderShipment.fromJson(Map<String, dynamic> json) =>
      RetailOrderShipment(
        id: json["id"],
        retailOrderId: _asString(json["retail_order_id"]),
        type: _asString(json["type"]),
        status: _asString(json["status"]),
        pickupAddress: _asString(json["pickup_address"]),
        pickUpLat: _asString(json["pickup_lat"]),
        pickUpLng: _asString(json["pickup_lng"]),
        deliveryAddress: _asString(json["delivery_address"]),
        deliveryLat: _asString(json["delivery_lat"]),
        deliveryLng: _asString(json["delivery_lng"]),
        distance: _asString(json["distance_km"]),
        baseShippingFee: _asString(json["base_shipping_fee"]),
        codFee: _asString(json["cod_fee"]),
        pickupFee: _asString(json["pickup_fee"]),
        createdAt: _asString(json["created_at"]),
        retailOrder: json["retail_order"] != null
            ? RetailOrder.fromJson(json["retail_order"])
            : null,
        shipmentUsers: json["shipment_users"] != null
            ? listRetailOrderShipmentAssignFromJson(json["shipment_users"])
            : [],
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "retail_order_id": retailOrderId,
    "type": type,
    "status": status,
    "pickup_address": pickupAddress,
    "pickup_lat": pickUpLat,
    "pickup_lng": pickUpLng,
    "delivery_address": deliveryAddress,
    "delivery_lat": deliveryLat,
    "delivery_lng": deliveryLng,
    "distance_km": distance,
    "base_shipping_fee": baseShippingFee,
    "cod_fee": codFee,
    "pickup_fee": pickupFee,
    "created_at": createdAt,
  };
}

class RetailOrderAssUserWarehouse {
  int? id;
  String? retailOrderWarehousesId;
  String? retailOrderDetailId;
  String? userId;
  List<ReturnImages>? images;
  String? quantity;
  String? status;
  UserProfile? user;
  RetailOrderDetails? retailOrderDetail;

  RetailOrderAssUserWarehouse({
    this.id,
    this.retailOrderWarehousesId,
    this.retailOrderDetailId,
    this.userId,
    this.images,
    this.quantity,
    this.status,
    this.user,
    this.retailOrderDetail,
  });

  String get statusText {
    switch (status) {
      case '0':
        return 'Đang thực hiện';
      case '1':
        return 'Hoàn thành';
      default:
        return 'Đang xử lý';
    }
  }

  factory RetailOrderAssUserWarehouse.fromJson(Map<String, dynamic> json) =>
      RetailOrderAssUserWarehouse(
        id: json["id"],
        retailOrderWarehousesId: _asString(json["retail_order_warehouses_id"]),
        retailOrderDetailId: _asString(json["retail_order_detail_id"]),
        userId: _asString(json["user_id"]),
        images: json["images"] == null
            ? null
            : listReturnImagesFromJson(json["images"]),
        quantity: _asString(json["quantity"]),
        status: _asString(json["status"]),
        user: json["user"] == null ? null : UserProfile.fromJson(json["user"]),
        retailOrderDetail: json.containsKey('order_detail')
            ? RetailOrderDetails.fromJson(json["order_detail"])
            : null,
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "retail_order_warehouses_id": retailOrderWarehousesId,
    "retail_order_detail_id": retailOrderDetailId,
    "user_id": userId,
    "quantity": quantity,
    "status": status,
  };
}

class RetailOrderAssUserPack {
  int? id;
  String? retailAssignmentPackId;
  String? retailOrderDetailId;
  String? userId;
  String? quantity;
  String? status;
  UserProfile? user;
  RetailOrderDetails? retailOrderDetail;
  RetailOrderPack? pack;

  RetailOrderAssUserPack({
    this.id,
    this.retailAssignmentPackId,
    this.retailOrderDetailId,
    this.userId,
    this.quantity,
    this.status,
    this.user,
    this.retailOrderDetail,
    this.pack,
  });

  String get statusText {
    switch (status) {
      case '0':
        return 'Đang thực hiện';
      case '1':
        return 'Hoàn thành';
      default:
        return 'Đang xử lý';
    }
  }

  factory RetailOrderAssUserPack.fromJson(Map<String, dynamic> json) =>
      RetailOrderAssUserPack(
        id: json["id"],
        retailAssignmentPackId: _asString(json["retail_assignment_pack_id"]),
        retailOrderDetailId: _asString(json["retail_order_detail_id"]),
        userId: _asString(json["user_id"]),
        quantity: _asString(json["quantity"]),
        status: _asString(json["status"]),
        user: json["user"] == null ? null : UserProfile.fromJson(json["user"]),
        retailOrderDetail: json["order_detail"] != null
            ? RetailOrderDetails.fromJson(json["order_detail"])
            : null,
        pack: json["pack"] != null
            ? RetailOrderPack.fromJson(json["pack"])
            : null,
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "retail_order_warehouses_id": retailAssignmentPackId,
    "retail_order_detail_id": retailOrderDetailId,
    "user_id": userId,
    "quantity": quantity,
    "status": status,
  };
}

class RetailOrderPackDetail {
  int? id;
  String? retailPackId;
  String? packageNumber;
  String? weight;
  String? length;
  String? width;
  String? height;
  // String? imageUrl;
  List<ReturnImages>? imagesUrl;
  String? note;
  DateTime? createdAt;
  RetailOrderPack? pack;

  RetailOrderPackDetail({
    this.id,
    this.retailPackId,
    this.packageNumber,
    this.weight,
    this.length,
    this.width,
    this.height,
    // this.imageUrl,
    this.imagesUrl,
    this.note,
    this.createdAt,
  });

  factory RetailOrderPackDetail.fromJson(Map<String, dynamic> json) =>
      RetailOrderPackDetail(
        id: json["id"],
        retailPackId: _asString(json["retail_pack_id"]),
        packageNumber: _asString(json["package_number"]),
        weight: _asString(json["weight"]),
        length: _asString(json["length"]),
        width: _asString(json["width"]),
        height: _asString(json["height"]),
        // imageUrl: json["image_url"],
        imagesUrl: json["image_urls"] == null
            ? null
            : listReturnImagesFromJson(json["image_urls"]),
        note: _asString(json["note"]),
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "retail_pack_id": retailPackId,
    "package_number": packageNumber,
    "weight": weight,
    "length": length,
    "width": width,
    "height": height,
    // "image_url": imageUrl,
    "note": note,
  };
}

class RetailOrderPack {
  int? id;
  String? retailOrderId;
  String? type;
  String? status;
  RetailOrder? retailOrder;
  List<RetailOrderAssUserPack>? assUsers;
  List<RetailOrderPackDetail>? packDetail;

  RetailOrderPack({
    this.id,
    this.retailOrderId,
    this.type,
    this.status,
    this.retailOrder,
    this.assUsers,
    this.packDetail,
  });

  String get statusText {
    switch (status) {
      case '-1':
        return 'Hủy trong quá trình ĐG';
      case '0':
        return 'Đang phân công đóng gói';
      case '1':
        return 'Đang thực hiện đóng gói';
      case '2':
        return 'Hoàn thành đóng gói';
      default:
        return 'Đang xử lý';
    }
  }

  factory RetailOrderPack.fromJson(
    Map<String, dynamic> json,
  ) => RetailOrderPack(
    id: json["id"],
    retailOrderId: _asString(json["retail_order_id"]),
    type: _asString(json["type"]),
    status: _asString(json["status"]),
    retailOrder: json["retail_order"] == null
        ? null
        : RetailOrder.fromJson(json["retail_order"]),
    assUsers: json["ass_users"] == null
        ? []
        : List<RetailOrderAssUserPack>.from(
            json["ass_users"].map((x) => RetailOrderAssUserPack.fromJson(x)),
          ),
    packDetail: json["pack_detail"] == null
        ? []
        : List<RetailOrderPackDetail>.from(
            json["pack_detail"].map((x) => RetailOrderPackDetail.fromJson(x)),
          ),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "retail_order_id": retailOrderId,
    "type": type,
    "status": status,
  };
}

class RetailOrderWarehouse {
  int? id;
  String? retailOrderId;
  String? type;
  String? status;
  RetailOrder? retailOrder;
  List<RetailOrderAssUserWarehouse>? assUsers;

  RetailOrderWarehouse({
    this.id,
    this.retailOrderId,
    this.type,
    this.status,
    this.retailOrder,
    this.assUsers,
  });

  String get statusText {
    switch (status) {
      case '-1':
        return 'Đã hủy';
      case '0':
        return 'Đang phân công';
      case '1':
        return 'Đang thực hiện';
      case '2':
        return 'Hoàn thành';
      default:
        return 'Đang xử lý';
    }
  }

  factory RetailOrderWarehouse.fromJson(Map<String, dynamic> json) =>
      RetailOrderWarehouse(
        id: json["id"],
        retailOrderId: _asString(json["retail_order_id"]),
        type: _asString(json["type"]),
        status: _asString(json["status"]),
        retailOrder: json["retail_order"] != null
            ? RetailOrder.fromJson(json["retail_order"])
            : null,
        assUsers: json["ass_users"] != null
            ? listRetailOrderAssUserWarehouseFromJson(json["ass_users"])
            : [],
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "retail_order_id": retailOrderId,
    "type": type,
    "status": status,
  };
}
