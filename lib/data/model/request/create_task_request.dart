class CreateTaskRequest {
  int type;
  String? name;
  String? des;
  int? status;
  int? priority;
  int? serviceId;
  String? timeStart;
  String? timeEnd;
  String? address;
  double? lat;
  double? lng;
  int? staffId;
  int? productId;
  int? customerId;
  String? video;
  List<String>? images;

  CreateTaskRequest({
    required this.type,
    this.name,
    this.des,
    this.status,
    this.priority,
    this.serviceId,
    this.timeStart,
    this.timeEnd,
    this.address,
    this.lat,
    this.lng,
    this.staffId,
    this.productId,
    this.video,
    this.images,
    this.customerId
  });
}
