import 'package:socbay/data/model/machine_model.dart';
import 'package:socbay/data/model/product_image.dart';

class ProductModel {
  final int? id;
  final String? userId;
  final String? name;
  final String? productCode;
  final String? soCapLoc;
  final String? slug;
  final String? lng;
  final String? meta;
  final String? content;
  final String? createdAt;
  final String? updatedAt;
  final List<ProductImage>? images;
  final MachineModel? machineModel;
  final String? address;

  ProductModel({
    this.id,
    this.userId,
    this.name,
    this.productCode,
    this.soCapLoc,
    this.slug,
    this.lng,
    this.meta,
    this.content,
    this.createdAt,
    this.updatedAt,
    this.machineModel,
    this.address,
    this.images,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
    id: json['id'] as int?,
    userId: json['user_id'] as String?,
    name: json["name"] as String?,
    productCode: json['product_code'] as String?,
    soCapLoc: json['so_cap_loc'] as String?,
    lng: json['lng'] as String?,
    slug: json['slug'] as String?,
    meta: json['meta'] as String?,
    content: json['content'] as String?,
    createdAt: json['created_at'] as String?,
    updatedAt: json['updated_at'] as String?,
    address: json['address'] as String?,
    machineModel: json["product"] != null
        ? MachineModel.fromJson(json["product"])
        : null,
    images: (json['product_images'] as List<dynamic>?)
        ?.map((e) => ProductImage.fromJson(e as Map<String, dynamic>))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'user_id': userId,
    'product_code': productCode,
    'so_cap_loc': soCapLoc,
    'slug': slug,
    'meta': meta,
    'lng': lng,
    'content': content,
    'created_at': createdAt,
    'updated_at': updatedAt,
    'product_images': images,
    'address': address,
  };
}
