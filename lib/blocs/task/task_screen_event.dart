import 'package:socbay/data/model/task_model.dart';

abstract class TaskScreenEvent {
  const TaskScreenEvent();
}

class TaskScreenGetTaskEvent extends TaskScreenEvent {
  final bool isRefresh;

  const TaskScreenGetTaskEvent({this.isRefresh = false});
}

class TaskScreenGetTaskAvailableEvent extends TaskScreenEvent {}

class StaffTaskScreenGetTaskByDayEvent extends TaskScreenEvent {
  final bool isRefresh;
  final String? status;
  final String? query;
  const StaffTaskScreenGetTaskByDayEvent({
    this.isRefresh = false,
    this.status,
    this.query,
  });
}

class StaffTaskScreenGetTaskAssigedEvent extends TaskScreenEvent {
  final bool isRefresh;
  final int page;
  final String? status;
  final String? query;
  const StaffTaskScreenGetTaskAssigedEvent({
    this.isRefresh = false,
    this.page = 0,
    this.status,
    this.query,
  });
}

class StaffTaskScreenGetTaskDoneEvent extends TaskScreenEvent {
  final bool isRefresh;

  const StaffTaskScreenGetTaskDoneEvent({this.isRefresh = false});
}

class BookingDeleteTaskEvent extends TaskScreenEvent {
  final int taskId;
  final String name;
  final String des;
  BookingDeleteTaskEvent(this.taskId, this.name, this.des);
}

class BookingDeleteTaskToDayEvent extends TaskScreenEvent {
  final int taskId;
  final String name;
  final String des;
  BookingDeleteTaskToDayEvent(this.taskId, this.name, this.des);
}

class StaffTaskScreenUpdateTaskDoneEvent extends TaskScreenEvent {
  final int taskId;
  final String name;
  final String noti;
  final String des;
  final String status;
  final String priority;
  final String timeStart;
  final String? address;
  const StaffTaskScreenUpdateTaskDoneEvent(
    this.taskId,
    this.name,
    this.noti,
    this.des,
    this.status,
    this.priority,
    this.timeStart, {
    this.address,
  });
}

class StaffTaskScreenUpdateTaskDayDoneEvent extends TaskScreenEvent {
  final int taskId;
  final String name;
  final String noti;
  final String des;
  final String status;
  final String priority;
  final String timeStart;
  final String? address;
  const StaffTaskScreenUpdateTaskDayDoneEvent(
    this.taskId,
    this.name,
    this.noti,
    this.des,
    this.status,
    this.priority,
    this.timeStart, {
    this.address,
  });
}

class StaffTaskScreenAssignTechnicianEvent extends TaskScreenEvent {
  final int taskId;
  final int staffId;
  final TaskModel taskModel;
  const StaffTaskScreenAssignTechnicianEvent({
    required this.taskId,
    required this.staffId,
    required this.taskModel,
  });
}
