abstract class NewPasswordScreenState {
  const NewPasswordScreenState();
}

class NewPasswordScreenInitialState extends NewPasswordScreenState {}

class NewPasswordScreenSubmitDoneState extends NewPasswordScreenState {
  final String? error;

  const NewPasswordScreenSubmitDoneState({this.error});
}
