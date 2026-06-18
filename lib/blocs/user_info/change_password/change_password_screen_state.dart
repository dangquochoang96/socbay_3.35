abstract class ChangePasswordScreenState {
  const ChangePasswordScreenState();
}

class ChangePasswordScreenInitialState extends ChangePasswordScreenState {}

class ChangePasswordScreenDoneState extends ChangePasswordScreenState {
  final String? error;

  const ChangePasswordScreenDoneState({this.error});
}
