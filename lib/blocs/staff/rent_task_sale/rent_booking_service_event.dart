
import 'dart:io';

import 'package:socbay/data/model/request/create_task_request.dart';
import 'package:socbay/data/model/request/user_address_request.dart';

abstract class RentBookingServiceEvent {
  const RentBookingServiceEvent();
}

class StaffServiceScreenSaleChangeTypeServiceEvent extends RentBookingServiceEvent {
  final String typeService;

  StaffServiceScreenSaleChangeTypeServiceEvent(this.typeService);
}

class StaffServiceScreenSaleCreateTaskEvent extends RentBookingServiceEvent {
  final CreateTaskRequest createTaskRequest;
  final bool isSearch;

  StaffServiceScreenSaleCreateTaskEvent(this.createTaskRequest, this.isSearch);
}

class StaffServiceScreenSaleUploadImageEvent extends RentBookingServiceEvent {
  final List<File> files;

  StaffServiceScreenSaleUploadImageEvent(this.files);
}

class StaffServiceSaleScreenCheckCustomerEvent extends RentBookingServiceEvent {
  final String phone;
  StaffServiceSaleScreenCheckCustomerEvent(this.phone);
}

class UserAddressScreenSaleCreateUserAddressEvent extends RentBookingServiceEvent {
  final UserAddressRequest userAddressRequest;

  const UserAddressScreenSaleCreateUserAddressEvent(this.userAddressRequest);
}