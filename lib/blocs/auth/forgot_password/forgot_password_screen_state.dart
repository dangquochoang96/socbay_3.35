abstract class ForgotPasswordScreenState {
  const ForgotPasswordScreenState();
}

class ForgotPasswordScreenInitialState extends ForgotPasswordScreenState {}

class CheckUserExistState extends ForgotPasswordScreenState {
  final String code;
  CheckUserExistState(this.code);
}
