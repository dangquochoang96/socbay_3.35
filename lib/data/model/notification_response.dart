class NotificationResponse {
  final int? app;
  final String? name;
  final String? image;
  final String? shortdes;
  final String? des;
  final String? createdAt;

  NotificationResponse({
    this.app,
    this.name,
    this.image,
    this.shortdes,
    this.des,
    this.createdAt,
  });

  factory NotificationResponse.fromJson(Map<String, dynamic> json) =>
      NotificationResponse(
        app: json['id'] as int?,
        name: json['name'] as String?,
        image: json['img'] as String?,
        shortdes: json['shortdes'] as String?,
        des: json['des'] as String?,
        createdAt: json['created_at'] as String?,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'app': app,
    'name': name,
    'img': image,
    'shortdes': shortdes,
    'des': des,
    'created_at': createdAt,
  };
}
