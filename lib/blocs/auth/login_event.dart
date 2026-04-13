abstract class LoginScreenEvent {}

class LoginEvent extends LoginScreenEvent {
  final String phone;
  final String password;

  LoginEvent(this.phone, this.password);
}
