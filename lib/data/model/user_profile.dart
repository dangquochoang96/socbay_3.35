// To parse this JSON data, do
//
//     final userProfile = userProfileFromJson(jsonString);

import 'dart:convert';

import 'package:socbay/data/model/kpi_model.dart';
import 'package:socbay/data/model/user_attendance_model.dart';
import 'package:socbay/data/model/user_model.dart';

UserProfile userProfileFromJson(String str) =>
    UserProfile.fromJson(json.decode(str));

List<UserProfile> userProfileListFromJson(dynamic str) =>
    List<UserProfile>.from(str.map((x) => UserProfile.fromJson(x)));

String userProfileToJson(UserProfile data) => json.encode(data.toJson());

class UserProfile {
  int? id;
  String? userId;
  String? bankInfo;
  String? bankQr;
  String? basicSalary;
  String? bhxh;
  String? totalIncome;
  String? typeStaff;
  String? typeContract;
  String? infoContract;
  String? monthContract;
  String? level;
  String? description;
  String? dayOff;
  KPIDataResponse? kpi;
  KPIDataResponse? endYearKPI;
  UserModel? user;
  UserAttendances? userAttendance;
  List<UserAttendances>? userAttendances;

  UserProfile({
    this.id,
    this.userId,
    this.bankInfo,
    this.bankQr,
    this.basicSalary,
    this.bhxh,
    this.totalIncome,
    this.typeStaff,
    this.typeContract,
    this.infoContract,
    this.monthContract,
    this.level,
    this.description,
    this.dayOff,
    this.kpi,
    this.endYearKPI,
    this.user,
    this.userAttendance,
    this.userAttendances,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    id: json["id"],
    userId: json["user_id"],
    bankInfo: json["bank_info"],
    bankQr: json["bank_qr"],
    basicSalary: json["basic_salary"],
    bhxh: json["bhxh"],
    totalIncome: json["total"],
    typeStaff: json["type_staff"],
    typeContract: json["type_contract"],
    infoContract: json["info_contract"],
    monthContract: json["month_contract"],
    level: json["level"],
    description: json["description"],
    dayOff: json["day_off"],
    kpi: json["kpis"] == null ? null : KPIDataResponse.fromJson(json["kpis"]),
    endYearKPI: json["late_year"] == null
        ? null
        : KPIDataResponse.fromJson(json["late_year"]),
    user: json["user"] == null ? null : UserModel.fromJson(json["user"]),
    userAttendance: json["user_attendance"] == null
        ? null
        : UserAttendances.fromJson(json["user_attendance"]),
    userAttendances: json["data_attendances"] == null
        ? null
        : userAttendancesListFromJson(json["data_attendances"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_id": userId,
    "bank_info": bankInfo,
    "bank_qr": bankQr,
    "basic_salary": basicSalary,
    "bhxh": bhxh,
    "total_income": totalIncome,
    "type_staff": typeStaff,
    "type_contract": typeContract,
    "info_contract": infoContract,
    "month_contract": monthContract,
    "level": level,
    "description": description,
    "day_off": dayOff,
    "kpi": kpi?.data,
    "late_year": endYearKPI?.data,
    "data_attendances": userAttendances != null
        ? List<dynamic>.from(userAttendances!.map((x) => x.toJson()))
        : null,
  };
}
