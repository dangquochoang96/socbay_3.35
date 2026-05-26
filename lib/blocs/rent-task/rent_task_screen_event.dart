abstract class RentTaskScreenEvent {
  const RentTaskScreenEvent();
}

class TaskScreenGetTaskEvent extends RentTaskScreenEvent {
  final bool isRefresh;

  const TaskScreenGetTaskEvent({this.isRefresh = false});
}

class TaskScreenGetTaskAvailableEvent extends RentTaskScreenEvent {}

class StaffTaskScreenGetTaskByDayEvent extends RentTaskScreenEvent {
  final bool isRefresh;
  const StaffTaskScreenGetTaskByDayEvent({this.isRefresh = false});
}

class StaffTaskScreenGetTaskAssigedEvent extends RentTaskScreenEvent {
  final bool isRefresh;
  final int page;
  const StaffTaskScreenGetTaskAssigedEvent({
    this.isRefresh = false,
    this.page = 0,
  });
}

class StaffTaskScreenGetTaskDoneEvent extends RentTaskScreenEvent {
  final bool isRefresh;

  const StaffTaskScreenGetTaskDoneEvent({this.isRefresh = false});
}

class BookingDeleteTaskEvent extends RentTaskScreenEvent {
  final int taskId;
  final String name;
  final String des;
  BookingDeleteTaskEvent(this.taskId, this.name, this.des);
}

class BookingDeleteTaskToDayEvent extends RentTaskScreenEvent {
  final int taskId;
  final String name;
  final String des;
  BookingDeleteTaskToDayEvent(this.taskId, this.name, this.des);
}

class StaffTaskScreenUpdateTaskDoneEvent extends RentTaskScreenEvent {
  final int taskId;
  final String name;
  final String noti;
  final String des;
  final String status;
  final String priority;
  final String timeStart;
  const StaffTaskScreenUpdateTaskDoneEvent(
    this.taskId,
    this.name,
    this.noti,
    this.des,
    this.status,
    this.priority,
    this.timeStart,
  );
}

class StaffTaskScreenUpdateTaskDayDoneEvent extends RentTaskScreenEvent {
  final int taskId;
  final String name;
  final String noti;
  final String des;
  final String status;
  final String priority;
  final String timeStart;
  const StaffTaskScreenUpdateTaskDayDoneEvent(
    this.taskId,
    this.name,
    this.noti,
    this.des,
    this.status,
    this.priority,
    this.timeStart,
  );
}
