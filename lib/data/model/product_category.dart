class ProductCategory {
  final int? id;
  final String? name;
  final String? image;
  final String? slug;
  final String? parentId;
  final String? order;
  final String? keyword;
  final String? metaDescription;
  final String? status;
  final String? createdAt;
  final String? updatedAt;

  // final int? app;
  // final int? isHot;
  // final int? isNew;
  // final List<ProductModel>? product;


  ProductCategory(
      {this.id,
      // this.app,
      // this.isHot,
      // this.isNew,
      this.name,
      this.image,
      this.slug,
      this.parentId,
      this.order,
      this.keyword,
      this.metaDescription,
      this.status,
      // this.product,
      this.createdAt,
      this.updatedAt});

  factory ProductCategory.fromJson(Map<String, dynamic> json) =>
      ProductCategory(
        id: json['id'] as int?,
        // app: json['app'] as int?,
        // isHot: json['is_hot'] as int?,
        // isNew: json['is_new'] as int?,
        name: json['name'] as String?,
        image: json['image'] as String?,
        slug: json['slug'] as String?,
        parentId: json['parent_id'] as String?,
        order: json['order'] as String?,
        keyword: json['keyword'] as String?,
        metaDescription: json['meta_description'] as String?,
        status: json['status'] as String?,
        // product: (json['product'] as List<dynamic>?)
        //     ?.map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
        //     .toList(),
        createdAt: json['created_at'] as String?,
        updatedAt: json['updated_at'] as String?,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        // 'app': app,
        // 'is_hot': isHot,
        // 'is_new': isNew,
        'name': name,
        'image': image,
        'slug': slug,
        'parent_id': parentId,
        'order': order,
        'keyword': keyword,
        'meta_description': metaDescription,
        'status': status,
        // 'product': product,
        'created_at': createdAt,
        'updated_at': updatedAt,
      };
}
