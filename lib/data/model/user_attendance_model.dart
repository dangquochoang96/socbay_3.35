// To parse this JSON data, do
//
//     final workLeaveRequests = workLeaveRequestsFromJson(jsonString);
//     final leaveRequests = leaveRequestsFromJson(jsonString);
//     final businessTrips = businessTripsFromJson(jsonString);
//     final userAttendances = userAttendancesFromJson(jsonString);
//     final workSchedules = workSchedulesFromJson(jsonString);
//     final overtimeRequests = overtimeRequestsFromJson(jsonString);

import 'dart:convert';

import 'package:socbay/data/model/list_image_model.dart';
import 'package:socbay/data/model/user_model.dart';

TimeRequests workLeaveRequestsFromJson(String str) =>
    TimeRequests.fromJson(json.decode(str));
String workLeaveRequestsToJson(TimeRequests data) => json.encode(data.toJson());

TimeRequests leaveRequestsFromJson(String str) =>
    TimeRequests.fromJson(json.decode(str));
String leaveRequestsToJson(TimeRequests data) => json.encode(data.toJson());

TimeRequests businessTripsFromJson(String str) =>
    TimeRequests.fromJson(json.decode(str));
String businessTripsToJson(TimeRequests data) => json.encode(data.toJson());

UserAttendances userAttendancesFromJson(String str) =>
    UserAttendances.fromJson(json.decode(str));
String userAttendancesToJson(UserAttendances data) =>
    json.encode(data.toJson());

List<UserAttendances> userAttendancesListFromJson(dynamic str) =>
    List<UserAttendances>.from(str.map((x) => UserAttendances.fromJson(x)));

String userAttendancesListToJson(List<UserAttendances> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

WorkSchedules workSchedulesFromJson(String str) =>
    WorkSchedules.fromJson(json.decode(str));
String workSchedulesToJson(WorkSchedules data) => json.encode(data.toJson());

List<WorkSchedules> workSchedulesListFromJson(dynamic str) =>
    List<WorkSchedules>.from(str.map((x) => WorkSchedules.fromJson(x)));

TimeRequests overtimeRequestsFromJson(String str) =>
    TimeRequests.fromJson(json.decode(str));
String overtimeRequestsToJson(TimeRequests data) => json.encode(data.toJson());

List<TimeRequests> overtimeRequestsListFromJson(dynamic str) =>
    List<TimeRequests>.from(str.map((x) => TimeRequests.fromJson(x)));

List<CheckinLocation> checkinLocationListFromJson(dynamic str) =>
    List<CheckinLocation>.from(str.map((x) => CheckinLocation.fromJson(x)));

CheckinLogs checkinLogsFromJson(String str) =>
    CheckinLogs.fromJson(json.decode(str));

List<CheckinLogs> checkinLogsListFromJson(dynamic str) =>
    List<CheckinLogs>.from(str.map((x) => CheckinLogs.fromJson(x)));

String checkinLogsToJson(CheckinLogs data) => json.encode(data.toJson());

class CheckinLocation {
  String? latitude;
  String? longitude;
  CheckinLocation({this.latitude, this.longitude});
  factory CheckinLocation.fromJson(String json) => CheckinLocation(
    latitude: json.split(',')[0],
    longitude: json.split(',')[1],
  );
  String toJson() => '${latitude!},${longitude!}';
}

class UserAttendances {
  int id;
  String? userId;
  String? deviceId;
  String? month;
  String? year;
  List<WorkSchedules>? workSchedules;
  List<TimeRequests>? overtimeRequests;
  List<TimeRequests>? businessTrips;
  List<TimeRequests>? leaveRequests;
  List<TimeRequests>? workLeaveRequests;
  String? updatedAt;
  String? createdAt;

  UserAttendances({
    required this.id,
    this.userId,
    this.deviceId,
    this.month,
    this.year,
    this.workSchedules,
    this.overtimeRequests,
    this.businessTrips,
    this.leaveRequests,
    this.workLeaveRequests,
    this.updatedAt,
    this.createdAt,
  });

  factory UserAttendances.fromJson(Map<String, dynamic> json) =>
      UserAttendances(
        id: json["id"],
        userId: json["user_id"]?.toString(),
        deviceId: json["device_id"]?.toString(),
        month: json["month"]?.toString(),
        year: json["year"]?.toString(),
        workSchedules: json["work_schedules"] == null
            ? null
            : workSchedulesListFromJson(json["work_schedules"]),
        overtimeRequests: json["overtime_requests"] == null
            ? null
            : overtimeRequestsListFromJson(json["overtime_requests"]),
        businessTrips: json["business_trips"] == null
            ? null
            : overtimeRequestsListFromJson(json["business_trips"]),
        leaveRequests: json["leave_requests"] == null
            ? null
            : overtimeRequestsListFromJson(json["leave_requests"]),
        workLeaveRequests: json["work_leave_requests"] == null
            ? null
            : overtimeRequestsListFromJson(json["work_leave_requests"]),
        updatedAt: json["updated_at"],
        createdAt: json["created_at"],
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_id": userId,
    "device_id": deviceId,
    "month": month,
    "year": year,
    "updated_at": updatedAt,
    "created_at": createdAt,
  };
}

class TimeRequests {
  String? id;
  String? date;
  String? startDate;
  String? endDate;
  String? startTime;
  String? endTime;
  String? totalHours;
  String? totalActualHours;
  int? status;
  String? type;
  String? notes;
  String? totalTime;
  String? notesConfirm;
  UserModel? user;
  List<String>? images;

  TimeRequests({
    this.id,
    this.date,
    this.startDate,
    this.endDate,
    this.startTime,
    this.endTime,
    this.totalHours,
    this.totalActualHours,
    this.status,
    this.type,
    this.notes,
    this.totalTime,
    this.notesConfirm,
    this.user,
    this.images,
  });

  factory TimeRequests.fromJson(Map<String, dynamic> json) => TimeRequests(
    id: json["id"],
    date: json["date"] ?? "",
    startDate: json["start_date"] ?? "",
    endDate: json["end_date"] ?? "",
    startTime: json["start_time"],
    endTime: json["end_time"],
    totalHours: json["total_hours"],
    totalActualHours: json["total_actual_hours"],
    status: json["status"] ?? 0,
    type: json["type"] ?? "",
    notes: json["notes"],
    totalTime: json["total_time"] ?? "",
    notesConfirm: json["notes_confirm"] ?? "",
    user: json["user"] == null ? null : UserModel.fromJson(json["user"]),
    images: json['images'] == null ? null : List<String>.from(json["images"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "date": date,
    "startDate": startDate,
    "endDate": endDate,
    "startTime": startTime,
    "endTime": endTime,
    "totalHours": totalHours,
    "totalActualHours": totalActualHours,
    "status": status,
    "type": type,
    "notes": notes,
    "total_time": totalTime,
    "notes_confirm": notesConfirm,
  };
}

class WorkSchedules {
  int id;
  String? date;
  String? day;
  String? employeeCode;
  num? totalTime;
  num? breakTime;
  num? totalWorkHours;
  num? lateMinutes;
  num? earlyLeaveMinutes;
  num? workingDay;
  num? overtimeHours;
  num? companyOvertimeHours;
  num? isHoliday;
  String? notes;
  List<CheckinLogs>? checkinLogs;
  List<ReturnImages>? imageCheckin;
  List<CheckinLocation>? checkinLocation;

  WorkSchedules({
    required this.id,
    this.date,
    this.day,
    this.employeeCode,
    this.breakTime,
    this.totalWorkHours,
    this.lateMinutes,
    this.earlyLeaveMinutes,
    this.workingDay,
    this.overtimeHours,
    this.companyOvertimeHours,
    this.isHoliday,
    this.notes,
    this.checkinLogs,
    this.imageCheckin,
    this.checkinLocation,
  });

  factory WorkSchedules.fromJson(Map<String, dynamic> json) => WorkSchedules(
    id: json["id"],
    date: json["date"],
    day: json["day"],
    employeeCode: json["employee_code"],
    breakTime: json["break_time"],
    totalWorkHours: json["total_work_hours"],
    lateMinutes: json["late_minutes"],
    earlyLeaveMinutes: json["early_leave_minutes"],
    workingDay: (() {
      final val = json["working_day"];
      if (val == null) return 0;
      if (val is num) return val;
      if (val is String) {
        return num.tryParse(val) ?? 0;
      }
      return 0;
    })(),
    isHoliday: (() {
      final val = json["is_holiday"];
      if (val == null) return 0;
      if (val is num) return val;
      if (val is String) {
        return num.tryParse(val) ?? 0;
      }
      return 0;
    })(),
    overtimeHours: json["overtime_hours"],
    companyOvertimeHours: json["company_overtime_hours"] ?? 0,
    notes: json["notes"],
    checkinLogs: json["checkin_logs"] == null
        ? null
        : checkinLogsListFromJson(json["checkin_logs"]),
    imageCheckin: json["image_checkin"] == null
        ? null
        : listReturnImagesFromJson(json["image_checkin"]),
    checkinLocation: json["checkin_location"] == null
        ? null
        : checkinLocationListFromJson(json["checkin_location"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "date": date,
    "day": day,
    "employee_code": employeeCode,
    "break_time": breakTime,
    "total_work_hours": totalWorkHours,
    "late_minutes": lateMinutes,
    "early_leave_minutes": earlyLeaveMinutes,
    "working_day": workingDay,
    "overtime_hours": overtimeHours,
    "is_holiday": isHoliday,
    "notes": notes,
    "checkin_logs": checkinLogs,
    "image_checkin": imageCheckin,
    "checkin_location": checkinLocation,
  };
}

class CheckinLogs {
  int? id;
  String? time;
  String? type; //0: checkin, 1: checkout
  String? image;
  String? latitude;
  String? longitude;

  CheckinLogs({
    this.id,
    this.time,
    this.type,
    this.image,
    this.latitude,
    this.longitude,
  });

  factory CheckinLogs.fromJson(Map<String, dynamic> json) => CheckinLogs(
    id: json["id"],
    time: json["time"],
    type: json["type"],
    image: json["image"],
    latitude: json["latitude"],
    longitude: json["longitude"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "time": time,
    "type": type,
    "image": image,
    "latitude": latitude,
    "longitude": longitude,
  };
}
