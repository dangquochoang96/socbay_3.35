class StaffSalesIncomeModel {
  String? totalOrder;
  String? totalPrice;
  String? totalChietKhau;
  String? totalTruTichDiem;
  String? type;
  String? status;

  StaffSalesIncomeModel({
    this.totalOrder,
    this.totalPrice,
    this.totalChietKhau,
    this.totalTruTichDiem,
    this.type,
    this.status,
  });
  factory StaffSalesIncomeModel.fromJson(Map<String, dynamic> json) => StaffSalesIncomeModel(
    totalOrder: json["totalOrder"] as String,
    totalPrice: json["totalPrice"] as String,
    totalChietKhau: json["totalChietKhau"] as String,
    totalTruTichDiem: json["totalTruTichDiem"] as String,
    type: json["type"] as String,
    status: json["status"] as String,
  );
}
