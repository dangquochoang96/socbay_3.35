import 'package:socbay/data/model/home_service_model.dart';
import 'package:socbay/data/model/task_model.dart';
import 'package:socbay/utils/parse_util.dart';

import 'order_model.dart';

class UserProfile {
  final int? id;
  final String? username;
  final String? avatar;
  final String? email;
  final String? phone;
  final String? address;
  final String? password;
  final String? type;
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

  UserProfile({
    this.username,
    this.avatar,
    this.email,
    this.phone,
    this.address,
    this.password,
    this.type,
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
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    id: Parse.toIntValue(json['id']),
    username: json['username'],
    avatar: json['avartar'],
    email: json['email'],
    phone: json['phone'] as String?,
    address: json['address'],
    password: json['password'],
    type: json['type'],
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
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'avatar': avatar,
    'birthday': birthday,
    'phone': phone,
    'address': address,
    'status': status,
    'is_agency': isAgency,
    'type': type,
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
  };

  bool isUserRole() => type == "2";
  bool isUserCustomer() => type == "1";
  bool isUserSale() => type == "3";
}
