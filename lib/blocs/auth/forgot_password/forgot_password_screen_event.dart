abstract class ForgotPasswordScreenEvent {
  const ForgotPasswordScreenEvent();
}

class ForgotPasswordScreenStartedEvent extends ForgotPasswordScreenEvent {}
class CheckUserExistEvent extends ForgotPasswordScreenEvent {
  final String phone;
  CheckUserExistEvent(this.phone);
}
