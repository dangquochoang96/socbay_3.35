import 'package:socbay/data/model/request/new_password_request.dart';

abstract class NewPasswordScreenEvent {
  const NewPasswordScreenEvent();
}

class NewPasswordScreenSubmitEvent extends NewPasswordScreenEvent {
  final NewPasswordRequest newPasswordRequest;
  const NewPasswordScreenSubmitEvent(this.newPasswordRequest);
}
