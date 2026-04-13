

abstract class RentBookingServiceState{
  const RentBookingServiceState();
}

class StaffServiceScreenSaleInitialState extends RentBookingServiceState {}

class StaffServiceScreenSaleChangeTypeServiceState extends RentBookingServiceState {
  final String typeService;

  const StaffServiceScreenSaleChangeTypeServiceState(this.typeService);
}

class StaffServiceScreenSaleCreateTaskSuccessState extends RentBookingServiceState {
  final int id;
  final bool isSearch;

  const StaffServiceScreenSaleCreateTaskSuccessState(this.id, this.isSearch);
}

class StaffServiceScreenSaleCreateTaskFailedState extends RentBookingServiceState {
  final String message;

  const StaffServiceScreenSaleCreateTaskFailedState(this.message);
}


class StaffServiceScreenSaleUploadImageFailedState extends RentBookingServiceState {
  final String message;

  const StaffServiceScreenSaleUploadImageFailedState(this.message);
}


class StaffServiceScreenSaleUploadImageSuccessState extends RentBookingServiceState {
  final List<String> paths;

  const StaffServiceScreenSaleUploadImageSuccessState(this.paths);
}

class StaffServiceScreenSaleCheckCustomerSuccessState extends RentBookingServiceState {
  final String message;

  const StaffServiceScreenSaleCheckCustomerSuccessState(this.message);
}

class StaffServiceScreenSaleCheckCustomerFailedState extends RentBookingServiceState {
  final String message;

  const StaffServiceScreenSaleCheckCustomerFailedState(this.message);
}
class UserAddressScreenSaleCreateAddressSuccessState
    extends RentBookingServiceState {
  final String error;

  const UserAddressScreenSaleCreateAddressSuccessState({this.error = ""});
}
class UserAddressScreenSaleCreateAddressFailState
    extends RentBookingServiceState {
  final String error;

  const UserAddressScreenSaleCreateAddressFailState({this.error = ""});
}


