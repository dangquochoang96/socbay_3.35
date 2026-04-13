class NewPasswordRequest {
  String phone;
  String newPassword;
  String newPasswordConfirm;
  String otp;

  NewPasswordRequest({
    required this.phone,
    required this.newPassword,
    required this.newPasswordConfirm,
    required this.otp,
  });
}
