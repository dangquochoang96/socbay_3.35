abstract class LoginScreenState {}

class LoginInitialState extends LoginScreenState {}

class LogInSuccessState extends LoginScreenState {}

class LogInFailureState extends LoginScreenState {
  final String message;

  LogInFailureState(this.message);
}
