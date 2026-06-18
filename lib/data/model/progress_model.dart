import '../../utils/parse_util.dart';

class ProgressModel {
  ProgressModel({
    this.id,
    this.taskId,
    this.userId,
    this.des,
    this.createdAt,
    this.updatedAt,
  });

  num? id;
  num? taskId;
  num? userId;
  String? des;
  String? createdAt;
  String? updatedAt;

  factory ProgressModel.fromJson(Map<String, dynamic> json) => ProgressModel(
    id: Parse.toNumValue(json["id"]),
    taskId: Parse.toNumValue(json["task_id"]),
    userId: Parse.toNumValue(json["user_id"]),
    des: json["des"],
    createdAt: json["created_at"],
    updatedAt: json["updated_at"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "task_id": taskId,
    "user_id": userId,
    "des": des,
    "created_at": createdAt,
    "updated_at": updatedAt,
  };
}
