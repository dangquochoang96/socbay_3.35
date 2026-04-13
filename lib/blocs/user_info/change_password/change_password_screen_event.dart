import 'package:socbay/data/model/request/change_password_request.dart';

abstract class ChangePasswordScreenEvent{
  const ChangePasswordScreenEvent();
}

class ChangePasswordScreenSubmitChangeEvent extends ChangePasswordScreenEvent{
  final ChangePasswordRequest changePasswordRequest;
  const ChangePasswordScreenSubmitChangeEvent(this.changePasswordRequest);
}