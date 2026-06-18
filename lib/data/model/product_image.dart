class ProductImage {
  final int? id;
  final String? link;
  final String? productId;
  final String? alt;
  final String? thumbnail;
  final String? order;
  final String? createdAt;
  final String? updatedAt;

  ProductImage({
    this.id,
    this.link,
    this.productId,
    this.alt,
    this.thumbnail,
    this.order,
    this.createdAt,
    this.updatedAt,
  });

  factory ProductImage.fromJson(Map<String, dynamic> json) => ProductImage(
    id: json['id'] as int?,
    link: json['link'] as String?,
    productId: json['product_id'] as String?,
    alt: json['alt'] as String?,
    thumbnail: json['thumbnail'] as String?,
    order: json['order'] as String?,
    createdAt: json['created_at'] as String?,
    updatedAt: json['updated_at'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'link': link,
    'product_id': productId,
    'alt': alt,
    'thumbnail': thumbnail,
    'order': order,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };
}
