import 'package:socbay/data/model/user_model.dart';
import 'package:socbay/utils/parse_util.dart';

class LoginResponse {
  final String? accessToken;
  final String? tokenType;
  final int? expiresIn;
  final UserModel? user;

  LoginResponse({this.accessToken, this.tokenType, this.expiresIn, this.user});

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
    accessToken: json['access_token'],
    tokenType: json['token_type'],
    expiresIn: json['expires_in'] != null
        ? Parse.toIntValue(json['expires_in'])
        : null,
    user: json['user'] != null
        ? UserModel.fromJson(json['user'] as Map<String, dynamic>)
        : null,
  );

  Map<String, dynamic> toJson() => {
    'access_token': accessToken,
    'token_type': tokenType,
    'expires_in': expiresIn,
    'user': user,
  };
}
