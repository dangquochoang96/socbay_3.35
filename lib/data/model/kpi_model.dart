// To parse this JSON data, do
//
//     final kpIs = kpIsFromJson(jsonString);

import 'dart:convert';

KPIs kpIsFromJson(String str) => KPIs.fromJson(json.decode(str));
List<KPIs> kpIsFromJsonList(dynamic str) =>
    List<KPIs>.from(str.map((x) => KPIs.fromJson(x)));
String kpIsToJson(KPIs data) => json.encode(data.toJson());

class KPIDataResponse {
  final Map<String, List<KPIs>> data;

  KPIDataResponse({required this.data});

  factory KPIDataResponse.fromJson(Map<String, dynamic> json) {
    final Map<String, List<KPIs>> result = {};

    json.forEach((key, value) {
      if (value is List) {
        result[key] = List<KPIs>.from(
          value.map((item) => KPIs.fromJson(item as Map<String, dynamic>)),
        );
      }
    });

    return KPIDataResponse(data: result);
  }
}

class KPIs {
  String? id;
  String? name;
  String? unit;
  String? target;
  String? achieved;
  int? percent;
  int? salaryBonus;
  int? salaryAdvance;
  String? notes;
  String? month;

  KPIs({
    this.id,
    this.name,
    this.unit,
    this.target,
    this.achieved,
    this.percent,
    this.salaryBonus,
    this.salaryAdvance,
    this.notes,
    this.month,
  });

  factory KPIs.fromJson(Map<String, dynamic> json) => KPIs(
    id: json["id"],
    name: json["name"],
    unit: json["unit"],
    target: _parseToString(json["target"]),
    achieved: _parseToString(json["achieved"]),
    percent: json["percent"],
    salaryBonus: json["salary_bonus"],
    salaryAdvance: json["salary_advance"],
    notes: json["notes"],
    month: json["month"],
  );

  // Helper method to parse both int and string to string
  static String? _parseToString(dynamic value) {
    if (value == null) return null;
    return value.toString();
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "unit": unit,
    "target": target,
    "achieved": achieved,
    "percent": percent,
    "salary_bonus": salaryBonus,
    "salary_advance": salaryAdvance,
    "notes": notes,
    "month": month,
  };
}
