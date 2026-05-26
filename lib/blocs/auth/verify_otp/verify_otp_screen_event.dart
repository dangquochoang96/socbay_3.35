abstract class VerifyOtpScreenEvent {
  const VerifyOtpScreenEvent();
}

class VerifyOtpScreenStartedEvent extends VerifyOtpScreenEvent {}

class VerifyOtpScreenSetOtpEvent extends VerifyOtpScreenEvent {}

class VerifyOtpScreenRegisterEvent extends VerifyOtpScreenEvent {
  final String otp;
  const VerifyOtpScreenRegisterEvent({required this.otp});
}

class VerifyOtpScreenLoginEvent extends VerifyOtpScreenEvent {
  final String phone;
  final String password;

  VerifyOtpScreenLoginEvent({required this.phone, required this.password});
}
