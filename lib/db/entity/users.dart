import 'package:floor/floor.dart';

@entity
class User {
  @primaryKey
  final int id;
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
  final String? cmt;
  User(
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
    this.cmt,
  );
}
