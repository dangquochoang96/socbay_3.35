class TechnicianTimelineModel {
  final int id;
  final String? username;
  final String? phone;
  final String? address;
  final String? avatar;
  final List<TimelineTaskModel> tasks;

  TechnicianTimelineModel({
    required this.id,
    this.username,
    this.phone,
    this.address,
    this.avatar,
    required this.tasks,
  });

  factory TechnicianTimelineModel.fromJson(Map<String, dynamic> json) {
    return TechnicianTimelineModel(
      id: json['id'] ?? 0,
      username: json['username']?.toString(),
      phone: json['phone']?.toString(),
      address: json['address']?.toString(),
      avatar: json['avartar']?.toString(), // JSON chứa khóa 'avartar'
      tasks: (json['tasks'] as List?)
              ?.map((e) => TimelineTaskModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class TimelineTaskModel {
  final int id;
  final String? taskType; // "service" hoặc "rent"
  final String? name;
  final String? des;
  final String? status;
  final String? statusName;
  final String? priority;
  final String? timeStart; // Ví dụ: "2026-06-26 08:52:00"
  final String? timeEnd;
  final String? duration;
  final String? customerName;
  final String? customerPhone;
  final String? address;

  TimelineTaskModel({
    required this.id,
    this.taskType,
    this.name,
    this.des,
    this.status,
    this.statusName,
    this.priority,
    this.timeStart,
    this.timeEnd,
    this.duration,
    this.customerName,
    this.customerPhone,
    this.address,
  });

  factory TimelineTaskModel.fromJson(Map<String, dynamic> json) {
    return TimelineTaskModel(
      id: json['id'] ?? 0,
      taskType: json['task_type']?.toString(),
      name: json['name']?.toString(),
      des: json['des']?.toString(),
      status: json['status']?.toString(),
      statusName: json['status_name']?.toString(),
      priority: json['priority']?.toString(),
      timeStart: json['time_start']?.toString(),
      timeEnd: json['time_end']?.toString(),
      duration: json['duration']?.toString(),
      customerName: json['customer_name']?.toString(),
      customerPhone: json['customer_phone']?.toString(),
      address: json['address']?.toString(),
    );
  }
}
