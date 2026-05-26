class StaffOrderDetailModel {
  final int? id;
  final String? status;
  final String? type;
  final String? price;
  final String? chietKhau;
  final String? tichDiem;
  final String? truTichDiem;
  final String? ghichu;
  final String? rate;
  final String? comment;
  final String? userId; //id kỹ thuật
  final String? tvNextInsteadDate;
  final String? tvInsteadDate;

  StaffOrderDetailModel({
    this.id,
    this.status,
    this.userId,
    this.type,
    this.price,
    this.chietKhau,
    this.tichDiem,
    this.truTichDiem,
    this.ghichu,
    this.rate,
    this.comment,
    this.tvNextInsteadDate,
    this.tvInsteadDate,
  });

  factory StaffOrderDetailModel.fromJson(Map<String, dynamic> json) =>
      StaffOrderDetailModel(
        id: json['id'] as int?,
        status: json['status'] as String?,
        userId: json['user_id'] as String?,
        type: json['type'] as String?,
        price: json['price'] as String?,
        chietKhau: json['chiet_khau'] as String?,
        tichDiem: json['tich_diem'] as String?,
        truTichDiem: json['tru_tich_diem'] as String?,
        ghichu: json['ghichu'] as String?,
        rate: json['rate'] as String?,
        comment: json['comment'] as String?,
        tvNextInsteadDate: json['replace_date_promise'] as String?,
        tvInsteadDate: json['replace_date'] as String?,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'status': status,
    'user_id': userId,
    'type': type,
    'price': price,
    'chiet_khau': chietKhau,
    'tich_diem': tichDiem,
    'tru_tich_diem': truTichDiem,
    'ghichu': ghichu,
    'rate': rate,
    'comment': comment,
  };
}
