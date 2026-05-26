import 'package:socbay/data/model/request/update_task_request.dart';

abstract class StaffInfoScreenEvent {
  const StaffInfoScreenEvent();
}

class StaffInfoScreenListEvent extends StaffInfoScreenEvent {
  final bool isRefresh;

  const StaffInfoScreenListEvent({this.isRefresh = false});
}

class StaffInfoScreenStartedEvent extends StaffInfoScreenEvent {}

class StaffInfoScreenPickEvent extends StaffInfoScreenEvent {
  final UpdateTaskRequest updateTaskRequest;

  const StaffInfoScreenPickEvent(this.updateTaskRequest);
}

class StaffInfoScreenLikeStaffEvent extends StaffInfoScreenEvent {
  final int id;

  const StaffInfoScreenLikeStaffEvent(this.id);
}

class StaffInfoScreenUnLikeStaffEvent extends StaffInfoScreenEvent {
  final int id;

  const StaffInfoScreenUnLikeStaffEvent(this.id);
}
