import 'dart:convert';

import 'package:socbay/data/model/user_model.dart';
import 'package:socbay/db/entity/users.dart';

abstract class Mapper<FROM, TO> {
  TO call(FROM object);
}

class UserModelToUser implements Mapper<UserModel, User> {
  @override
  User call(UserModel object) {
    return User(
      object.username,
      object.avatar,
      object.email,
      object.phone,
      object.address,
      object.password,
      object.type,
      object.typeStaff,
      object.otp,
      object.id!,
      object.birthday,
      object.status,
      object.isAgency,
      object.isAdmin,
      object.sex,
      object.point,
      object.lat,
      object.lng,
      object.distance,
      object.createdAt,
      object.certification,
      object.cmt,
      jsonEncode(object.roles),
      jsonEncode(object.permissions),
    );
  }
}

class UserToUserModel implements Mapper<User, UserModel> {
  static List<String> _decodeList(String? raw) {
    if (raw == null || raw.isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded
            .map((e) => e?.toString().trim() ?? '')
            .where((s) => s.isNotEmpty)
            .toList();
      }
    } catch (_) {}
    return const [];
  }

  @override
  UserModel call(User object) {
    return UserModel(
      username: object.username,
      avatar: object.avatar,
      email: object.email,
      phone: object.phone,
      address: object.address,
      password: object.password,
      type: object.type,
      typeStaff: object.typeStaff,
      otp: object.otp,
      id: object.id,
      birthday: object.birthday,
      status: object.status,
      isAgency: object.isAgency,
      isAdmin: object.isAdmin,
      sex: object.sex,
      point: object.point,
      lat: object.lat,
      lng: object.lng,
      distance: object.distance,
      createdAt: object.createdAt,
      certification: object.certification,
      cmt: object.cmt,
      roles: _decodeList(object.roles),
      permissions: _decodeList(object.permissions),
    );
  }
}
