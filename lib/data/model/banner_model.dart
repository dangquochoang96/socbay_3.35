class BannerModel {
  final int? id;
  final String? image;
  final String? link;
  final String? title;
  final String? description;
  final int? app;
  final int? status;
  final String? typeAction;
  final String? typeFilter;
  final String? createdAt;

  BannerModel({
    this.id,
    this.image,
    this.link,
    this.title,
    this.description,
    this.app,
    this.status,
    this.typeAction,
    this.typeFilter,
    this.createdAt,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) => BannerModel(
    id: json['id'] as int?,
    image: (json['image'] ?? json['banner'])?.toString(),
    link: json['link'] as String?,
    title: json['title'] as String?,
    description: json['description'] as String?,
    app: json['app'] as int?,
    status: json['status'] as int?,
    typeAction: json['type_action'] as String?,
    typeFilter: json['type_filter'] as String?,
    createdAt: json['created_at'] as String?,
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'image': image,
    'link': link,
    'title': title,
    'description': description,
    'app': app,
    'status': status,
    'type_action': typeAction,
    'type_filter': typeFilter,
    'created_at': createdAt,
  };
}
