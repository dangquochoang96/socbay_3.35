class RegisterRequestModel {
  final String username;
  final String? avatar;
  final String? email;
  final String phone;
  final String? address;
  final String password;
  final int? type;
  final int otp;

  RegisterRequestModel({
    required this.username,
    this.avatar,
    this.email,
    required this.phone,
    this.address,
    required this.password,
    this.type,
    required this.otp,
  });
}
