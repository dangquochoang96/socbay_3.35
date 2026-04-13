import 'package:socbay/data/model/order_detail_model.dart';
import 'package:socbay/data/model/user_profile.dart';
import 'package:socbay/utils/logger_util.dart';

class FeedBackModel {
  final int? id;
  final String? orderId;
  final String? userId;
  final String? customerId;
  final String? description;
  final String? status;
  final String? type;
  final String? createdAt;
  final String? updatedAt;
  final UserProfile? user;
  final UserProfile? customer;
  final OrderDetailModel? orderInfo;
  final List<String>? images;

  FeedBackModel(
      {this.id,
        this.orderId,
        this.userId,
        this.customerId,
        this.description,
        this.status,
        this.type,
        this.createdAt,
        this.updatedAt,
        this.user,
        this.customer,
        this.orderInfo,
        this.images
      });

  factory FeedBackModel.fromJson(Map<String, dynamic> json) => FeedBackModel(
    id: json['id'] as int?,
    orderId: json['order_id'] as String?,
    userId: json['user_id'] as String?,
    customerId: json['customer_id'] as String?,
    description: json['description'] as String?,
    status: json['status'] as String?,
    type: json['type'] as String?,
    createdAt: json['created_at'] as String?,
    updatedAt: json['updatedAt'] as String?,
    user: json['user'] != null
        ? UserProfile.fromJson(json['user'] as Map<String, dynamic>)
        : null,
    customer: json['customer'] != null
        ? UserProfile.fromJson(json['customer'] as Map<String, dynamic>)
        : null,
    orderInfo: json['order_info'] != null
        ? OrderDetailModel.fromJson(json['order_info'] as Map<String, dynamic>)
        : null,
      images: getImages(json["images"] as List<dynamic>?)
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'order_id': orderId,
    'user_id': userId,
    'customer_id': customerId,
    'description': description,
    'status': status,
    'type': type,
    'created_at': createdAt,
    'updated_at': updatedAt,
    'user': user,
    'customer': customer,
    'order_info': orderInfo,
  };
  String getStatus() {
    switch (status) {
      case "1":
        return "Chưa xử lý";
      case "2":
        return "Đã xử lý";
    }
    return "";
  }
  static List<String> getImages(List<dynamic>? images){
    List<String> imgs = [];
    if(images == null) {
      return imgs;
    }
    try{
      imgs = List<String>.from(images.map((e) => e["image_link"]));
    }catch(exception){
      LoggerUtil.log(exception.toString());
    }
    return imgs;
  }
}
