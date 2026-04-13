class UserAddress {
  UserAddress({
    this.id,
    this.userId,
    this.name,
    this.phone,
    this.address,
    this.lat,
    this.lng,
    this.isDefault,
    this.stateCode,
    this.cityCode,
    this.createdAt,
  });

  String? id;
  int? userId;
  String? name;
  String? phone;
  String? address;
  double? lat;
  double? lng;
  int? isDefault;
  String? stateCode;
  String? cityCode;
  String? createdAt;

  bool isDefaultAddress() => isDefault == 1;

  factory UserAddress.fromJson(Map<String, dynamic> json) => UserAddress(
        id: json["id"]?.toString(),
        userId: json["user_id"],
        name: json["name"],
        phone: json["phone"],
        address: json["address"],
        lat: json["lat"].toDouble(),
        lng: json["lng"].toDouble(),
        isDefault: json["is_default"],
        stateCode: json["state_code"],
        cityCode: json["city_code"],
        createdAt: json["created_at"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "name": name,
        "phone": phone,
        "address": address,
        "lat": lat,
        "lng": lng,
        "is_default": isDefault,
        "state_code": stateCode,
        "city_code": cityCode,
        "created_at": createdAt,
      };
}
