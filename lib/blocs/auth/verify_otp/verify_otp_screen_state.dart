abstract class VerifyOtpScreenState {
  const VerifyOtpScreenState();
}

class VerifyOtpScreenInitialState extends VerifyOtpScreenState {}

class VerifyOtpScreenSetOtpState extends VerifyOtpScreenState {}

class VerifyOtpScreenLoginSuccessState extends VerifyOtpScreenState {}

class VerifyOtpScreenLogInFailureState extends VerifyOtpScreenState {
  final String message;

  VerifyOtpScreenLogInFailureState(this.message);
}

class VerifyOtpScreenRegisterSuccessState extends VerifyOtpScreenState {
  final String? error;
  const VerifyOtpScreenRegisterSuccessState({this.error});
}
