import 'dart:io';

import 'package:socbay/data/model/request/user_info_request.dart';

abstract class AccountInfoEvent {
  const AccountInfoEvent();
}

class AccountInfoInitEvent extends AccountInfoEvent {
  const AccountInfoInitEvent();
}

class AccountInfoUpdateUserEvent extends AccountInfoEvent {
  final UserInfoRequest userInfoRequest;
  const AccountInfoUpdateUserEvent(this.userInfoRequest);
}

class UploadImageEvent extends AccountInfoEvent {
  final File files;
  UploadImageEvent(this.files);
}
