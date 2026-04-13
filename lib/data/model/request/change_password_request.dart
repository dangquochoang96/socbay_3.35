class ChangePasswordRequest {
  String oldPassword;
  String password;
  String rePassword;


  ChangePasswordRequest({
    required this.oldPassword,
    required this.password,
    required this.rePassword,
  });
}
