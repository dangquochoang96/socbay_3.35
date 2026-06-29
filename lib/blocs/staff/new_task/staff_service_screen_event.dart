import 'dart:io';

import 'package:socbay/data/model/request/create_task_request.dart';
import 'package:socbay/data/model/request/user_address_request.dart';

abstract class StaffServiceScreenEvent {
  const StaffServiceScreenEvent();
}

class StaffServiceScreenChangeTypeServiceEvent extends StaffServiceScreenEvent {
  final String typeService;

  StaffServiceScreenChangeTypeServiceEvent(this.typeService);
}

class StaffServiceScreenCreateTaskEvent extends StaffServiceScreenEvent {
  final CreateTaskRequest createTaskRequest;
  final bool isSearch;
  final String? createTaskEndpoint;

  StaffServiceScreenCreateTaskEvent(
    this.createTaskRequest,
    this.isSearch, {
    this.createTaskEndpoint,
  });
}

class StaffServiceScreenUserAddressEvent extends StaffServiceScreenEvent {}

class StaffServiceScreenUploadImageEvent extends StaffServiceScreenEvent {
  final List<File> files;

  StaffServiceScreenUploadImageEvent(this.files);
}

class StaffServiceScreenUploadFileEvent extends StaffServiceScreenEvent {}

class StaffServiceScreenCheckCustomerEvent extends StaffServiceScreenEvent {
  final String phone;
  StaffServiceScreenCheckCustomerEvent(this.phone);
}

class UserAddressScreenCreateUserAddressEvent extends StaffServiceScreenEvent {
  final UserAddressRequest userAddressRequest;

  const UserAddressScreenCreateUserAddressEvent(this.userAddressRequest);
}
