class NotificationResponse {
  final int? id;
  final int? app;
  final int? userId;
  final int? type;
  final String? title;
  final String? message;
  final String? image;
  final String? actionType;
  final String? actionValue;
  final int? priority;
  final String? source;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Compatibility getters for legacy code calling name, shortdes, des
  String? get name => title;
  String? get shortdes => message;
  String? get des => message;

  NotificationResponse({
    this.id,
    this.app,
    this.userId,
    this.type,
    this.title,
    this.message,
    this.image,
    this.actionType,
    this.actionValue,
    this.priority,
    this.source,
    this.createdAt,
    this.updatedAt,
  });

  factory NotificationResponse.fromJson(
    Map<String, dynamic> json,
  ) => NotificationResponse(
    id: json['id'] != null ? int.tryParse(json['id'].toString()) : null,
    app: json['app'] != null ? int.tryParse(json['app'].toString()) : null,
    userId: json['user_id'] != null
        ? int.tryParse(json['user_id'].toString())
        : null,
    type: json['type'] != null ? int.tryParse(json['type'].toString()) : null,
    title: (json['title'] ?? json['name']) as String?,
    message: (json['message'] ?? json['des'] ?? json['shortdes']) as String?,
    image: (json['image'] ?? json['img']) as String?,
    actionType: json['action_type'] as String?,
    actionValue: json['action_value'] as String?,
    priority: json['priority'] != null
        ? int.tryParse(json['priority'].toString())
        : null,
    source: json['source'] as String?,
    createdAt: json['created_at'] != null
        ? DateTime.tryParse(json['created_at'].toString())
        : null,
    updatedAt: json['updated_at'] != null
        ? DateTime.tryParse(json['updated_at'].toString())
        : null,
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'app': app,
    'user_id': userId,
    'type': type,
    'title': title,
    'message': message,
    'image': image,
    'action_type': actionType,
    'action_value': actionValue,
    'priority': priority,
    'source': source,
    'created_at': createdAt?.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
  };
}
