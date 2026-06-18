class UpdateStaffRequestModel {
  final String birthday;
  final String address;
  final String? certification;
  final String idCard;
  final String idCardImageFront;
  final String idCardImageBack;
  final List<int>? services;

  UpdateStaffRequestModel({
    required this.birthday,
    required this.address,
    this.certification,
    required this.idCard,
    required this.idCardImageFront,
    required this.idCardImageBack,
    this.services,
  });
}
