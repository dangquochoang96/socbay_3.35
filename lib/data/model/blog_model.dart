import 'package:intl/intl.dart';

class BlogModel {
  static const imageHost = 'https://geysereco.com';

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

  String get imageUrl {
    final value = image;
    if (value == null || value.isEmpty) {
      return "";
    }
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }
    return '$imageHost${value.startsWith('/') ? value : '/$value'}';
  }

  String createdDateConvert() {
    if (createdAt == null) {
      return "";
    }
    final formats = [
      "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'",
      'yyyy-MM-dd HH:mm:ss',
    ];
    for (final format in formats) {
      try {
        final date = DateFormat(format).parse(createdAt!);
        return DateFormat("dd/MM/yyyy").format(date);
      } catch (_) {}
    }
    return "";
  }

  BlogModel({
    this.id,
    this.categoryId,
    //this.app,
    this.name,
    this.image,
    this.status,
    this.shortdes,
    this.des,
    this.order,
    this.createdAt,
  });

  factory BlogModel.fromJson(Map<String, dynamic> json) => BlogModel(
    id: _toInt(json['id']),
    categoryId: _toStringList(json['category_id']),
    //app: json['app'] as int?,
    name: json['name'] as String?,
    image: json['image'] as String?,
    status: json['status'] as String?,
    shortdes: json['shortdes'] as String?,
    des: _normalizeHtmlUrls(json['des'] as String?),
    order: json['order']?.toString(),
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

  static int? _toInt(dynamic value) {
    if (value is int) {
      return value;
    }
    return int.tryParse(value?.toString() ?? "");
  }

  static List<String>? _toStringList(dynamic value) {
    if (value is List) {
      return value.map((item) => item.toString()).toList();
    }
    return null;
  }

  static String? _normalizeHtmlUrls(String? value) {
    if (value == null || value.isEmpty) {
      return value;
    }
    return value
        .replaceAll('src="/', 'src="$imageHost/')
        .replaceAll("src='/", "src='$imageHost/");
  }
}
