import 'package:decimal/decimal.dart';
import 'package:socbay/utils/parse_util.dart';

class TaskDetailActionModel{
  final int? id;
  final int? taskId;
  final String? name;
  final Decimal? price;
  final String? createAt;
  final String? updateAt;
  final String? maintainAt;//thời gian bảo dưỡng tiếp theo
  TaskDetailActionModel({
    this.id,
    this.taskId,
    this.name,
    this.price,
    this.createAt,
    this.updateAt,
    this.maintainAt
  });
  factory TaskDetailActionModel.fromJson(Map<String, dynamic> json)=> TaskDetailActionModel(
    id: Parse.toIntValue(json["id"]),
    taskId: Parse.toIntValue(json["task_id"]),
    name: json["name"],
    price: Decimal.parse(json["price"]),
    createAt: json["createAt"],
    updateAt: json["updateAt"],
    maintainAt: json["maintainAt"]
  );
  Map<String, dynamic> toJson()=>{
    "id": id,
    "task_id": taskId,
    "name": name,
    "price": price,
    "create_at": createAt,
    "update_at": updateAt,
    "maintain_at": maintainAt
  };
}