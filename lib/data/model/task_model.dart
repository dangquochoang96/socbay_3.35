import 'package:socbay/data/model/product_model.dart';
import 'package:socbay/data/model/user_profile.dart';
import 'package:socbay/utils/logger_util.dart';
import 'package:socbay/utils/parse_util.dart';

class TaskModel {
  final int? id;
  final String? type;
  final String? name;
  final String? createdAt;
  final String? updatedAt;
  final String? status;
  final String? des;
  final String? noti;
  final String? priority;
  final String? timeStart;
  final String? timeEnd;
  final String? userId;
  final String? saleId;
  final String? userCreate;
  final String? userCustomer;
  final String? origin;
  final String? productId;
  final String? orderId;
  final ProductModel? productInfo;
  final UserProfile? staff;
  final UserProfile? customer;
  final List<String>? images;

  TaskModel({
    this.id,
    this.type,
    this.name,
    this.createdAt,
    this.updatedAt,
    this.status,
    this.des,
    this.noti,
    this.priority,
    this.timeStart,
    this.timeEnd,
    this.userId,
    this.saleId,
    this.userCreate,
    this.userCustomer,
    this.origin,
    this.productId,
    this.orderId,
    this.productInfo,
    this.staff,
    this.customer,
    this.images,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) => TaskModel(
    id: Parse.toIntValue(json["id"]),
    type: json["type"]?.toString(),
    name: json["name"]?.toString(),
    createdAt: json["created_at"]?.toString(),
    updatedAt: json["updated_at"]?.toString(),
    status: json["status"]?.toString(),
    des: json["des"]?.toString(),
    noti: json["noti"]?.toString(),
    priority: json["priority"]?.toString(),
    timeStart: json["time_start"]?.toString(),
    timeEnd: json["time_end"]?.toString(),
    saleId: json["sale_id"]?.toString(),
    userId: json["user_id"]?.toString(),
    userCreate: json["user_create"]?.toString(),
    userCustomer: json["user_customer"]?.toString(),
    origin: json["origin"]?.toString(),
    productId: json["product_id"]?.toString(),
    orderId: json["order_id"]?.toString(),
    productInfo: json["product_info"] != null
        ? ProductModel.fromJson(json["product_info"])
        : null,
    staff: json["staff"] != null
        ? UserProfile.fromJson(json["staff"] as Map<String, dynamic>)
        : null,
    customer: json["customer"] != null
        ? UserProfile.fromJson(json["customer"] as Map<String, dynamic>)
        : null,
    images: getImages(json["images"] as List<dynamic>?),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "type": type,
    "name": name,
    "status": status,
    "des": des,
    "noti": noti,
    "time_start": timeStart,
    "time_end": timeEnd,
    "staff": staff,
    "sale_id": saleId,
    "user_create": userCreate,
    "user_customer": userCustomer,
    "origin": origin,
    "order_id": orderId,
    "created_at": createdAt,
  };

  String getStatus() {
    switch (status) {
      case "1":
        return "Chưa giao cho ai";
      case "2":
        return "Đang thực hiện";
      case "3":
        return "Hoàn thành";
      case "4":
        return "Hủy";
      case "5":
        return "Đã giao";
    }
    return "";
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

  TaskModel? firstWhere(
    bool Function(dynamic task) param0, {
    required Null Function() orElse,
  }) {
    return null;
  }
}
