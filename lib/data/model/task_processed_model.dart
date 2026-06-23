import 'package:decimal/decimal.dart';
import 'package:socbay/data/model/user_model.dart';
import 'package:socbay/utils/parse_util.dart';

import 'task_detail_action_model.dart';

class TaskProcessedModel {
  late final int? id; // id task
  late final Decimal? totalPrice; // tổng tiền ban đầu
  late final Decimal? discount; // chiết khấu
  late final int? subPoint; // số tích điểm được sử dụng để thanh toán
  late final Decimal? totalPriced; // tổng tiền cuối cùng phải trả
  late final UserModel? staff; // thông tin thợ
  late final List<String>? images; // danh sách hóa đơn của đơn hàng
  late final List<TaskDetailActionModel>? progress;
  late final String? createdAt; // ngày tạo
  late final String? updatedAt; // ngày cập nhật
  TaskProcessedModel({
    this.id,
    this.totalPrice,
    this.discount,
    this.subPoint,
    this.totalPriced,
    this.staff,
    this.images,
    this.progress,
    this.createdAt,
    this.updatedAt,
  });
  factory TaskProcessedModel.fromJson(Map<String, dynamic> json) =>
      TaskProcessedModel(
        id: Parse.toIntValue(json["id"]),
        totalPrice: Decimal.parse(json["total_price"]),
        discount: Decimal.parse(json["discount"]),
        subPoint: int.parse(json["sub_point"]),
        totalPriced: Decimal.parse(json["total_priced"]),
        staff: json["staff"] != null
            ? UserModel.fromJson(json["staff"] as Map<String, dynamic>)
            : null,
        images: json["images"] != null
            ? (json["images"].map<String>((e) => e.toString())).toList()
            : null,
        progress: json["progress"] != null
            ? (json["progress"].map<TaskDetailActionModel>(
                (e) =>
                    TaskDetailActionModel.fromJson(e as Map<String, dynamic>),
              )).toList()
            : null,
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "total_price": totalPrice,
    "discount": discount,
    "sub_point": subPoint,
    "total_priced": totalPriced,
    "staff": staff,
    "images": List<String>.from(images!.map((e) => e)),
    "progress": List<TaskDetailActionModel>.from(
      progress!.map((e) => e.toString()),
    ),
    "created_at": createdAt,
    "updated_at": updatedAt,
  };
}
