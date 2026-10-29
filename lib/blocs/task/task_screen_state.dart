abstract class TaskScreenState {}

class MyTaskScreenInitialState extends TaskScreenState {}

class BookingUpdateSuccessState extends TaskScreenState {}

class BookingUpdateTodaySuccessState extends TaskScreenState {}

class BookingUpdateErrorState extends TaskScreenState {}

class BookingUpdateTodayErrorState extends TaskScreenState {}

class BookingDeleteSuccessState extends TaskScreenState {}

class BookingDeleteTodaySuccessState extends TaskScreenState {}

class BookingDeleteErrorState extends TaskScreenState {}

class BookingDeleteTodayErrorState extends TaskScreenState {}

class AcceptContactedTaskSuccessState extends TaskScreenState {
  final String? message;
  AcceptContactedTaskSuccessState({this.message});
}

class AcceptContactedTaskErrorState extends TaskScreenState {
  final String? message;
  AcceptContactedTaskErrorState({this.message});
}
