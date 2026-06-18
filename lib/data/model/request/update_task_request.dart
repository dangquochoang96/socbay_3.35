class UpdateTaskRequest {
  UpdateTaskRequest({
    this.type,
    this.name,
    this.des,
    this.status,
    this.priority,
    this.serviceId,
    this.timeStart,
    this.timeEnd,
    this.staffId,
    this.saleId,
    this.customerId,
    this.orderId,
    this.products,
    this.images,
  });

  final int? type;
  final String? name;
  final String? des;
  final int? status;
  final int? priority;
  final int? serviceId;
  final String? timeStart;
  final String? timeEnd;
  final int? staffId;
  final int? saleId;
  final int? customerId;
  final int? orderId;
  final int? products;
  List<String>? images;

  factory UpdateTaskRequest.fromJson(Map<String, dynamic> json) =>
      UpdateTaskRequest(
        type: json["type"],
        name: json["name"],
        des: json["des"],
        status: json["status"],
        priority: json["priority"],
        serviceId: json["service_id"],
        timeStart: json["time_start"],
        timeEnd: json["time_end"],
        staffId: json["staff_id"],
        saleId: json["sale_id"],
        customerId: json["customer_id"],
        orderId: json["order_id"],
        products: json["product_id"],
      );

  Map<String, dynamic> toJson() => {
    "type": type,
    "name": name,
    "des": des,
    "status": status,
    "priority": priority,
    "service_id": serviceId,
    "time_start": timeStart,
    "time_end": timeEnd,
    "staff_id": staffId,
    "sale_id": saleId,
    "customer_id": customerId,
    "order_id": orderId,
    "product_id": products,
  };
}
