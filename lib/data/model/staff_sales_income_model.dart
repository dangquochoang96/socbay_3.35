class StaffSalesIncomeModel {
  String? totalOrder;
  String? totalPrice;
  String? totalChietKhau;
  String? totalTruTichDiem;
  String? totalOrderLapMay;
  String? totalPriceLapMay;
  String? totalOrderThayThe;
  String? totalPriceThayThe;
  String? totalOrderVsbd;
  String? totalPriceVsbd;
  String? totalOrderOnline;
  String? totalPriceOnline;
  String? totalOrderShip;
  String? totalPriceShip;
  String? totalOrderLocTongChinh;
  String? totalPriceLocTongChinh;
  String? totalOrderLocTongPhu;
  String? totalPriceLocTongPhu;
  String? type;
  String? status;

  StaffSalesIncomeModel({
    this.totalOrder,
    this.totalPrice,
    this.totalChietKhau,
    this.totalTruTichDiem,
    this.totalOrderLapMay,
    this.totalPriceLapMay,
    this.totalOrderThayThe,
    this.totalPriceThayThe,
    this.totalOrderVsbd,
    this.totalPriceVsbd,
    this.totalOrderOnline,
    this.totalPriceOnline,
    this.totalOrderShip,
    this.totalPriceShip,
    this.totalOrderLocTongChinh,
    this.totalPriceLocTongChinh,
    this.totalOrderLocTongPhu,
    this.totalPriceLocTongPhu,
    this.type,
    this.status,
  });
  factory StaffSalesIncomeModel.fromJson(Map<String, dynamic> json) =>
      StaffSalesIncomeModel(
        totalOrder: json["totalOrder"] as String?,
        totalPrice: json["totalPrice"] as String?,
        totalChietKhau: json["totalChietKhau"] as String?,
        totalTruTichDiem: json["totalTruTichDiem"] as String?,
        totalOrderLapMay: json["totalOrderLapMay"] as String?,
        totalPriceLapMay: json["totalPriceLapMay"] as String?,
        totalOrderThayThe: json["totalOrderThayThe"] as String?,
        totalPriceThayThe: json["totalPriceThayThe"] as String?,
        totalOrderVsbd: json["totalOrderVsbd"] as String?,
        totalPriceVsbd: json["totalPriceVsbd"] as String?,
        totalOrderOnline: json["totalOrderOnline"] as String?,
        totalPriceOnline: json["totalPriceOnline"] as String?,
        totalOrderShip: json["totalOrderShip"] as String?,
        totalPriceShip: json["totalPriceShip"] as String?,
        totalOrderLocTongChinh: json["totalOrderLocTongChinh"] as String?,
        totalPriceLocTongChinh: json["totalPriceLocTongChinh"] as String?,
        totalOrderLocTongPhu: json["totalOrderLocTongPhu"] as String?,
        totalPriceLocTongPhu: json["totalPriceLocTongPhu"] as String?,
        type: json["type"] as String?,
        status: json["status"] as String?,
      );
}
