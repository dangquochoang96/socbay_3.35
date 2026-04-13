import 'package:intl/intl.dart';

class BlogModel {
  final int? id;
  final List<String>? categoryId;
  //final int? app;
  final String? name;
  final String? image;
  final String? status;
  final String? shortdes;
  final String? des;
  final String? order;
  final String? createdAt;

  String createdDateConvert() {
    if (createdAt == null) {
      return "";
    }
    DateTime date = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z").parse(createdAt!);
    return DateFormat("dd/MM/yyyy").format(date);
  }

  BlogModel(
      {this.id,
      this.categoryId,
      //this.app,
      this.name,
      this.image,
      this.status,
      this.shortdes,
      this.des,
      this.order,
      this.createdAt});

  factory BlogModel.fromJson(Map<String, dynamic> json) => BlogModel(
        id: json['id'] as int?,
        categoryId: json['category_id'] as List<String>?,
        //app: json['app'] as int?,
        name: json['name'] as String?,
        image: json['image'] as String?,
        status: json['status'] as String?,
        shortdes: json['shortdes'] as String?,
        des: json['des'] as String?,
        order: json['order'] as String?,
        createdAt: json['created_at'] as String?,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'category_id': categoryId,
        //'app': app,
        'name': name,
        'image': image,
        'status': status,
        'shortdes': shortdes,
        'des': des,
        'order': order,
        'created_at': createdAt,
      };
}
