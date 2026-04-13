import 'package:socbay/data/model/user_profile.dart';

class LoginResponse {
  final String? accessToken;
  final String? tokenType;
  final String? expiresAt;
  final UserProfile? user;

  LoginResponse({this.accessToken, this.tokenType, this.expiresAt, this.user});

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
        accessToken: json['access_token'],
        tokenType: json['token_type'],
        expiresAt: json['expires_at'],
        user: json['user'] != null
            ? UserProfile.fromJson(json['user'] as Map<String, dynamic>)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'access_token': accessToken,
        'token_type': tokenType,
        'expires_at': expiresAt,
        'user': user,
      };
}
