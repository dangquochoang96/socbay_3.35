import 'dart:io';

import 'package:socbay/data/model/request/create_task_request.dart';
import 'package:socbay/data/model/request/user_address_request.dart';

abstract class StaffServiceSaleScreenEvent {
  const StaffServiceSaleScreenEvent();
}

class StaffServiceScreenSaleChangeTypeServiceEvent
    extends StaffServiceSaleScreenEvent {
  final String typeService;

  StaffServiceScreenSaleChangeTypeServiceEvent(this.typeService);
}

class StaffServiceScreenSaleCreateTaskEvent
    extends StaffServiceSaleScreenEvent {
  final CreateTaskRequest createTaskRequest;
  final bool isSearch;
  final String? createTaskEndpoint;

  StaffServiceScreenSaleCreateTaskEvent(
    this.createTaskRequest,
    this.isSearch, {
    this.createTaskEndpoint,
  });
}

class StaffServiceScreenSaleUploadImageEvent
    extends StaffServiceSaleScreenEvent {
  final List<File> files;

  StaffServiceScreenSaleUploadImageEvent(this.files);
}

class StaffServiceSaleScreenCheckCustomerEvent
    extends StaffServiceSaleScreenEvent {
  final String phone;
  StaffServiceSaleScreenCheckCustomerEvent(this.phone);
}

class UserAddressScreenSaleCreateUserAddressEvent
    extends StaffServiceSaleScreenEvent {
  final UserAddressRequest userAddressRequest;

  const UserAddressScreenSaleCreateUserAddressEvent(this.userAddressRequest);
}
