class UserAddressRequest {
  UserAddressRequest({
    required this.name,
    required this.phone,
    //new
    this.birthday,
    this.cmt,
    this.idCardImageFront,
    this.idCardImageBack,
    this.typeStaff,
    this.type,
    this.services,

    this.address,
    this.lat,
    this.lng,
    this.isDefault,
    this.cityCode,
    this.stateCode,
    this.id,
    this.pass,
  });

  String name;
  String phone;
  String? address;
  num? lat;
  num? lng;
  int? isDefault;
  String? cityCode;
  String? stateCode;
  String? id;
  String? pass;
  //new
  String? typeStaff;
  String? type;
  String? birthday;
  String? cmt;
  String? idCardImageFront;
  String? idCardImageBack;
  List<int>? services;
}
