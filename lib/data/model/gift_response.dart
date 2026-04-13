import 'package:socbay/utils/parse_util.dart';

class GiftResponse {
  final int? id;
  final String? name;
  final String? slug;
  final String? shortDescription;
  final String? description;
  final String? image;
  final int? status;
  final int? point;
  final int? order;
  final String? createdAt;

  GiftResponse(
      {this.id,
      this.name,
      this.slug,
      this.shortDescription,
      this.description,
      this.image,
      this.status,
      this.point,
      this.order,
      this.createdAt});

  factory GiftResponse.fromJson(Map<String, dynamic> json) => GiftResponse(
        id: Parse.toIntValue(json['id']),
        name: json['name'] as String?,
        slug: json['slug'] as String?,
        shortDescription: json['short_description'] as String?,
        description: json['description'] as String?,
        image: json['image'] as String?,
        status: Parse.toIntValue(json['status']),
        point: Parse.toIntValue(json['point']),
        order: Parse.toIntValue(json['order']),
        createdAt: json['created_at'] as String?,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'name': name,
        'slug': slug,
        'short_description': shortDescription,
        'description': description,
        'image': image,
        'status': status,
        'point': point,
        'order': order,
        'created_at': createdAt,
      };
}
