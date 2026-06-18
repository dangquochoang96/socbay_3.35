import 'package:socbay/data/model/user_profile.dart';
import 'package:socbay/db/entity/users.dart';

abstract class Mapper<FROM, TO> {
  TO call(FROM object);
}

class UserProfileToUser implements Mapper<UserProfile, User> {
  @override
  User call(UserProfile object) {
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
    );
  }
}

class UserToUserProfile implements Mapper<User, UserProfile> {
  @override
  UserProfile call(User object) {
    return UserProfile(
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
    );
  }
}
