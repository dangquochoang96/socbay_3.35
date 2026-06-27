import 'package:socbay/data/model/home_service_model.dart';
import 'package:socbay/data/model/task_model.dart';
import 'package:socbay/data/model/user_profile.dart';
import 'package:socbay/utils/parse_util.dart';

import 'order_model.dart';

class UserModel {
  final int? id;
  final String? username;
  final String? avatar;
  final String? companyAvatar;
  final String? email;
  final String? phone;
  final String? address;
  final String? password;
  final String? type;
  final String? typeStaff;
  final int? otp;
  final String? birthday;
  final int? status;
  final int? isAgency;
  final int? isAdmin;
  final int? sex;
  final int? point;
  final double? lat;
  final double? lng;
  final double? distance;
  final String? createdAt;
  final String? certification;
  final List<HomeServiceModel>? services;
  final String? cmt;
  final String? idCardImageFront;
  final String? idCardImageBack;
  final TaskModel? taskmodel;
  final OrderModel? ordermodel;
  final UserProfile? userProfile;

  UserModel({
    this.username,
    this.avatar,
    this.companyAvatar,
    this.email,
    this.phone,
    this.address,
    this.password,
    this.type,
    this.typeStaff,
    this.otp,
    this.id,
    this.birthday,
    this.status,
    this.isAgency,
    this.isAdmin,
    this.sex,
    this.point,
    this.lat,
    this.lng,
    this.distance,
    this.createdAt,
    this.certification,
    this.services,
    this.taskmodel,
    this.ordermodel,
    this.cmt,
    this.idCardImageFront,
    this.idCardImageBack,
    this.userProfile,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: Parse.toIntValue(json['id']),
    username: json['username'],
    avatar: json['avartar'],
    companyAvatar: json['company_avatar'],
    email: json['email'],
    phone: json['phone'] as String?,
    address: json['address'],
    password: json['password'],
    type: json['type'],
    typeStaff: json['type_staff'],
    otp: Parse.toIntValue(json['otp']),
    birthday: json['birthday'],
    status: Parse.toIntValue(json['status']),
    isAgency: Parse.toIntValue(json['is_agency']),
    isAdmin: Parse.toIntValue(json['is_admin']),
    sex: Parse.toIntValue(json['sex']),
    point: Parse.toIntValue(json['tich_diem']),
    lat: Parse.toDoubleValue(['lat']),
    lng: Parse.toDoubleValue(['lng']),
    distance: Parse.toDoubleValue(json['distance']),
    createdAt: json['created_at'],
    certification: json['certification'],
    services: ((json['service'] as List<HomeServiceModel>?)?.map(
      (e) => e,
    ))?.toList(),
    taskmodel: json["customer"] != null
        ? TaskModel.fromJson(json["customer"])
        : null,
    ordermodel: json["listProducts"] != null
        ? OrderModel.fromJson(json["listProducts"])
        : null,
    cmt: json['cmt'],
    idCardImageFront: json['id_card_image_front'],
    idCardImageBack: json['id_card_image_back'],
    userProfile: json["user_profile"] != null
        ? UserProfile.fromJson(json["user_profile"])
        : null,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'avatar': avatar,
    'company_avatar': companyAvatar,
    'birthday': birthday,
    'phone': phone,
    'address': address,
    'status': status,
    'is_agency': isAgency,
    'type': type,
    'type_staff': typeStaff,
    'is_admin': isAdmin,
    'sex': sex,
    'tich_diem': point,
    'lat': lat,
    'lng': lng,
    'distance': distance,
    'created_at': createdAt,
    'certification': certification,
    'services': services,
    'cmt': cmt,
    'idCardImageFront': idCardImageFront,
    'idCardImageBack': idCardImageBack,
    'user_profile': userProfile?.toJson(),
  };

  // bool isUserRole() => type == "2";
  // bool isUserCustomer() => type == "1";
  // bool isUserSale() => type == "3";

  bool isUserRole() => type == "2" && ["1", "3", "5"].contains(typeStaff);
  bool isUserCustomer() => type == "1" && typeStaff == "0";
  bool isUserSale() =>
      type == "2" && ["2", "4", "6", "7", "8"].contains(typeStaff);
}
