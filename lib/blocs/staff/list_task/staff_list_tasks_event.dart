abstract class StaffListTasksEvent {}

class StaffListTasksInitEvent extends StaffListTasksEvent {}

class StaffListTasksCurrentDayEvent extends StaffListTasksEvent {
  final bool isRefresh;
  StaffListTasksCurrentDayEvent({this.isRefresh = false});
}

class StaffListTasksAssignedEvent extends StaffListTasksEvent {}

class StaffListTasksCompletedEvent extends StaffListTasksEvent {}

class StaffListTasksNewEvent extends StaffListTasksEvent {}
