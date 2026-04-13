class UserInfoRequest {
  String? username;
  String? avatar;
  String? email;
  String? phone;
  String? address;
  String? certification;
  String? password;
  String? birthday;
  //new
  String? cmt;
  String? idCardImageFront;
  String? idCardImageBack;

  UserInfoRequest({
    this.username,
    this.avatar,
    this.email,
    this.phone,
    this.address,
    this.certification,
    this.password,
    this.birthday,
    //new
    this.cmt,
    this.idCardImageFront,
    this.idCardImageBack,
  });
}
