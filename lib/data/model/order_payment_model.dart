class OrderPaymentModel {
  final int? id;
  final String? orderId;
  final String? method;
  final String? amount;
  final String? transferContent;
  final String? qrUrl;
  final String? paymentStatus;
  final String? createdAt;
  final String? updatedAt;

  OrderPaymentModel({
    this.id,
    this.orderId,
    this.method,
    this.amount,
    this.transferContent,
    this.qrUrl,
    this.paymentStatus,
    this.createdAt,
    this.updatedAt,
  });

  factory OrderPaymentModel.fromJson(Map<String, dynamic> json) =>
      OrderPaymentModel(
        id: _asInt(json['id']),
        orderId: _asString(json['order_id']),
        method: _asString(json['method']),
        amount: _asString(json['amount']),
        transferContent: _asString(json['transfer_content']),
        qrUrl: _asString(json['qr_url']),
        paymentStatus: _asString(json['payment_status']),
        createdAt: _asString(json['created_at']),
        updatedAt: _asString(json['updated_at']),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'order_id': orderId,
    'method': method,
    'amount': amount,
    'transfer_content': transferContent,
    'qr_url': qrUrl,
    'payment_status': paymentStatus,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };
}

int? _asInt(dynamic value) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '');
}

String? _asString(dynamic value) => value?.toString();
